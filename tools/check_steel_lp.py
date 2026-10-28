"""Independently verify the original steelmaking LP with SciPy/HiGHS.

Reads numeric constants from both MATLAB scripts. Does not run MATLAB or Excel.
Requires NumPy and SciPy.
"""

import json
import re
from pathlib import Path

import numpy as np
from scipy.optimize import linprog


def matlab_matrix(text, name):
    """Read the simple literal matrices used by these two archived scripts."""
    match = re.search(rf"(?m)^{re.escape(name)}\s*=\s*\[([^\]]*)\]", text)
    if match is None:
        raise ValueError(f"Missing literal matrix {name}")
    literal = re.sub(r"%[^\r\n]*", "", match.group(1)).strip()
    rows = [row.strip() for row in re.split(r"[;\r\n]+", literal) if row.strip()]
    return np.array([[float(value) for value in row.split()] for row in rows])


def source_model(path):
    text = path.read_text()
    return {
        "f": matlab_matrix(text, "f").ravel(),
        "A": matlab_matrix(text, "A"),
        "b": matlab_matrix(text, "b").ravel(),
        "lb": matlab_matrix(text, "lb").ravel(),
    }


def verify():
    root = Path(__file__).resolve().parents[1]
    source = root / "src/steelmaking_lp"
    first = source_model(source / "optimization_assignment.m")
    second = source_model(source / "optimization_assignment_different_formulation.m")
    permutation = np.arange(12).reshape(3, 4).T.ravel()
    np.testing.assert_array_equal(second["f"], first["f"][permutation])
    np.testing.assert_array_equal(second["A"], first["A"][:, permutation])
    np.testing.assert_array_equal(second["b"], first["b"])
    np.testing.assert_array_equal(second["lb"], first["lb"][permutation])
    assert first["A"].shape == (7, 12)

    results = []
    for model in (first, second):
        result = linprog(
            model["f"], A_ub=model["A"], b_ub=model["b"],
            bounds=list(zip(model["lb"], [None] * 12)), method="highs",
        )
        assert result.success, result.message
        assert np.all(model["A"] @ result.x <= model["b"] + 1e-7)
        assert np.all(result.x >= model["lb"] - 1e-7)
        np.testing.assert_allclose(result.fun, 4300, atol=1e-7)
        results.append(result)

    # A dual-feasible certificate yields the same bound as a feasible primal.
    dual = np.array([-0.1, -0.1125, -0.15, -0.3, 0, -10, -10])
    assert np.all(dual <= 0)
    assert np.all(first["A"].T @ dual <= first["f"] + 1e-9)
    dual_bound = float(first["b"] @ dual)
    np.testing.assert_allclose(results[0].fun, dual_bound, atol=1e-7)

    # Both historical snapshots are feasible and achieve the dual bound.
    historical_hours = (
        [[10, 15, 0], [0, 0, 10], [30, 0, 0], [0, 15, 10]],
        [[0, 20, 0], [0, 0, 10], [0, 0, 10], [40, 10, 0]],
    )
    for hours in historical_hours:
        x = np.array(hours).T.ravel()
        assert np.all(x >= 0)
        assert np.all(first["A"] @ x <= first["b"] + 1e-7)
        np.testing.assert_allclose(first["f"] @ x, dual_bound, atol=1e-7)

    print(json.dumps({
        "column_permutation_equivalent": True,
        "optimal_cost": float(results[0].fun),
        "dual_bound": dual_bound,
        "historical_allocations_verified": len(historical_hours),
        "multiple_optimal_allocations": True,
        "matlab_or_excel_executed": False,
    }, indent=2))


if __name__ == "__main__":
    verify()

"""Check the unrestricted supermarket-location model independently of MATLAB.

Uses binary whole-workstation assignments and site-opening decisions, a linked
LP relaxation, and an exact integer-arithmetic site-subset certificate.
Requires Python 3, NumPy, and SciPy >= 1.9. No MATLAB/PSO execution is performed.
"""

import argparse
import csv
from decimal import Decimal
import hashlib
from itertools import combinations
import json
from pathlib import Path
import re

import numpy as np
import scipy
from scipy.optimize import Bounds, LinearConstraint, linprog, milp


def literal_vector(text, name):
    match = re.search(rf"(?m)^{re.escape(name)}\s*=\s*\[([^\]]+)\]", text)
    if match is None:
        raise ValueError(f"Missing source vector {name}")
    return [Decimal(value) for value in match.group(1).split()]


def literal_scalar(text, name):
    match = re.search(rf"(?m)^{re.escape(name)}\s*=\s*([\d.]+)\s*;", text)
    if match is None:
        raise ValueError(f"Missing source scalar {name}")
    return Decimal(match.group(1))


def exact_integer(value):
    if value != value.to_integral_value():
        raise ValueError("Source value is not exact in the selected integer scale")
    return int(value)


def grouped_assignment(assignment, sites):
    return {
        str(site): [w + 1 for w, assigned in enumerate(assignment) if assigned == site]
        for site in sites
    }


def verify(root):
    source_path = root / "src/supermarket_pso/supermarket_swarm_optimization.m"
    source_bytes = source_path.read_bytes()
    text = source_bytes.decode()
    demand = [exact_integer(value) for value in literal_vector(text, "dw")]
    capacity = exact_integer(literal_scalar(text, "SC"))
    installation_tenths = exact_integer(10 * literal_scalar(text, "SIC"))
    shipment_unit_cost = literal_scalar(text, "SUC")
    xw, yw, xs, ys = [literal_vector(text, name) for name in ("xw", "yw", "Xs", "Ys")]
    workstations, sites = len(demand), len(xs)
    assert workstations == exact_integer(literal_scalar(text, "W"))
    assert sites == exact_integer(literal_scalar(text, "S"))
    assert len(yw) == workstations and len(ys) == sites
    assert capacity > 0 and all(value > 0 for value in demand)
    # Every objective coefficient is represented exactly in tenths of one euro.
    shipment_tenths = [
        [exact_integer(20 * shipment_unit_cost * demand[w]
                       * (abs(xw[w] - xs[s]) + abs(yw[w] - ys[s])))
         for s in range(sites)]
        for w in range(workstations)
    ]
    n_assignment = workstations * sites
    n_variables = n_assignment + sites
    c = np.array([value for row in shipment_tenths for value in row]
                 + [installation_tenths] * sites, dtype=float)
    equalities = np.zeros((workstations, n_variables))
    for w in range(workstations):
        equalities[w, w * sites:(w + 1) * sites] = 1
    inequalities = np.zeros((sites + n_assignment, n_variables))
    for s in range(sites):
        inequalities[s, s:n_assignment:sites] = demand
        inequalities[s, n_assignment + s] = -capacity
    # Explicit assignment-to-opening links strengthen the continuous relaxation.
    for w in range(workstations):
        for s in range(sites):
            row = sites + w * sites + s
            inequalities[row, w * sites + s] = 1
            inequalities[row, n_assignment + s] = -1
    constraints = [
        LinearConstraint(equalities, np.ones(workstations), np.ones(workstations)),
        LinearConstraint(inequalities, -np.inf, np.zeros(len(inequalities))),
    ]
    result = milp(c, integrality=np.ones(n_variables), bounds=Bounds(0, 1),
                  constraints=constraints, options={"mip_rel_gap": 0})
    if not result.success:
        raise RuntimeError(result.message)
    binary = np.rint(result.x).astype(int)
    np.testing.assert_allclose(result.x, binary, atol=1e-6)
    assert np.all(binary >= 0) and np.all(binary <= 1)
    np.testing.assert_array_equal(equalities @ binary, np.ones(workstations))
    assert np.all(inequalities @ binary <= 0)
    assignment = (binary[:n_assignment].reshape(workstations, sites).argmax(axis=1) + 1).tolist()
    opened = (np.flatnonzero(binary[n_assignment:]) + 1).tolist()
    loads = [sum(demand[w] for w, assigned in enumerate(assignment) if assigned == s + 1)
             for s in range(sites)]
    shipment_cost = sum(shipment_tenths[w][assigned - 1] for w, assigned in enumerate(assignment))
    opening_cost = installation_tenths * len(opened)
    total_tenths = shipment_cost + opening_cost
    np.testing.assert_allclose(result.fun, total_tenths, atol=1e-5)
    np.testing.assert_allclose(result.mip_dual_bound, total_tenths, atol=1e-5)
    assert result.mip_gap <= 1e-9

    relaxation = linprog(c, A_ub=inequalities, b_ub=np.zeros(len(inequalities)),
                        A_eq=equalities, b_eq=np.ones(workstations),
                        bounds=(0, 1), method="highs")
    if not relaxation.success:
        raise RuntimeError(relaxation.message)
    dual_bound = float(relaxation.eqlin.marginals.sum() + relaxation.upper.marginals.sum())
    np.testing.assert_allclose(relaxation.fun, dual_bound, atol=1e-5)
    assert np.all(inequalities @ relaxation.x <= 1e-7)
    np.testing.assert_allclose(equalities @ relaxation.x, np.ones(workstations), atol=1e-7)
    assert np.all(relaxation.x >= -1e-7) and np.all(relaxation.x <= 1 + 1e-7)
    dual_gradient = (equalities.T @ relaxation.eqlin.marginals
                     + inequalities.T @ relaxation.ineqlin.marginals
                     + relaxation.lower.marginals + relaxation.upper.marginals)
    np.testing.assert_allclose(dual_gradient, c, atol=1e-6)
    assert np.all(relaxation.ineqlin.marginals <= 1e-7)
    assert np.all(relaxation.upper.marginals <= 1e-7)
    assert np.all(relaxation.lower.marginals >= -1e-7)

    # A capacity-free nearest-site cost is a lower bound for each open subset.
    # Evaluate all subsets with enough aggregate capacity using Python integers.
    subset_bounds = []
    skipped = 0
    for count in range(1, sites + 1):
        for subset in combinations(range(sites), count):
            if capacity * count < sum(demand):
                skipped += 1
                continue
            nearest = [min(subset, key=lambda s: shipment_tenths[w][s])
                       for w in range(workstations)]
            nearest_loads = [sum(demand[w] for w, assigned in enumerate(nearest) if assigned == s)
                             for s in range(sites)]
            nearest_shipment = sum(shipment_tenths[w][assigned] for w, assigned in enumerate(nearest))
            bound = installation_tenths * count + nearest_shipment
            subset_bounds.append({
                "opened_sites": [s + 1 for s in subset],
                "lower_bound_tenths": bound,
                "lower_bound": bound / 10,
                "nearest_assignment_1based": [s + 1 for s in nearest],
                "nearest_loads": nearest_loads,
                "nearest_assignment_capacity_feasible": all(value <= capacity for value in nearest_loads),
            })
    winner = min(subset_bounds, key=lambda row: row["lower_bound_tenths"])
    assert winner["nearest_assignment_capacity_feasible"]
    assert winner["lower_bound_tenths"] == total_tenths

    trace_path = root / "data/recorded-pso-convergence.csv"
    with trace_path.open(newline="") as stream:
        trace = list(csv.DictReader(stream))
    recorded_tenths = exact_integer(10 * Decimal(trace[-1]["recorded_model_cost"]))
    return {
        "schema_version": 1,
        "source": {
            "path": str(source_path.relative_to(root)),
            "sha256": hashlib.sha256(source_bytes).hexdigest(),
        },
        "model": {
            "workstations": workstations, "candidate_sites": sites,
            "total_demand": sum(demand), "capacity_per_site": capacity,
            "installation_cost_per_site": installation_tenths / 10,
            "shipment_unit_cost": float(shipment_unit_cost),
            "shipment_metric": "Demand-weighted round-trip Manhattan distance, matching the source cost expression",
            "assignment_scope": "Each entire workstation is assigned to one open site; any subset of candidate sites may open",
            "decoder_difference": "The original PSO decoder can only open a prefix of site indices and uses contiguous workstation groups",
        },
        "solver": {
            "backend": "HiGHS bundled with SciPy",
            "scipy_version": scipy.__version__, "numpy_version": np.__version__,
            "requested_milp_relative_gap": 0,
        },
        "milp": {
            "optimal_cost": total_tenths / 10,
            "optimal_cost_tenths": total_tenths,
            "dual_bound": float(result.mip_dual_bound / 10),
            "relative_gap": float(result.mip_gap),
            "status": int(result.status), "message": result.message,
            "branch_and_bound_nodes": int(result.mip_node_count),
            "opened_sites": opened, "assignment_1based": assignment,
            "workstation_groups": grouped_assignment(assignment, opened),
            "loads_by_site": loads,
            "installation_cost": opening_cost / 10,
            "shipment_cost": shipment_cost / 10,
        },
        "linked_lp_relaxation": {
            "scope": "Relax both assignment and opening binaries to [0,1], retaining capacity links and x[w,s] <= y[s]",
            "lower_bound": float(relaxation.fun / 10),
            "dual_bound": dual_bound / 10,
            "primal_and_dual_feasibility_checked": True,
            "certifies_integer_optimum_by_itself": False,
        },
        "exact_site_subset_certificate": {
            "cost_unit": "One tenth of one euro; all bounds computed with Python integer arithmetic",
            "minimum_sites_by_aggregate_capacity": (sum(demand) + capacity - 1) // capacity,
            "subsets_excluded_by_aggregate_capacity": skipped,
            "subsets_with_sufficient_capacity": subset_bounds,
            "winning_opened_sites": winner["opened_sites"],
            "global_lower_bound_tenths": winner["lower_bound_tenths"],
            "winning_nearest_assignment_capacity_feasible": True,
            "whole_workstation_solution_attains_global_lower_bound": True,
            "conclusion": "The feasible winning nearest-site assignment attains the smallest lower bound over every possible open subset, certifying global optimality independently of floating-point MILP output",
        },
        "recorded_pso_comparison": {
            "trace_path": str(trace_path.relative_to(root)),
            "trace_sha256": hashlib.sha256(trace_path.read_bytes()).hexdigest(),
            "final_recorded_cost": recorded_tenths / 10,
            "absolute_gap_above_unrestricted_optimum": (recorded_tenths - total_tenths) / 10,
            "percent_above_unrestricted_optimum": 100 * (recorded_tenths - total_tenths) / total_tenths,
            "actual_historical_assignment_verified": False,
        },
        "matlab_or_pso_executed": False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="JSON output path; defaults to data/supermarket-milp-check.json")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    data = verify(root)
    output = args.output if args.output else root / "data/supermarket-milp-check.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(data, indent=2, allow_nan=False) + "\n")
    print(json.dumps({
        "optimal_cost": data["milp"]["optimal_cost"],
        "opened_sites": data["milp"]["opened_sites"],
        "linked_lp_lower_bound": data["linked_lp_relaxation"]["lower_bound"],
        "exact_integer_certificate": True,
        "recorded_pso_cost": data["recorded_pso_comparison"]["final_recorded_cost"],
        "matlab_or_pso_executed": False,
    }, indent=2))


if __name__ == "__main__":
    main()

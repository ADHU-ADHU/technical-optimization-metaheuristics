"""Exactly check the supermarket PSO's contiguous-prefix assignment model.

Run with Python 3 (standard library only)::

    python tools/check_supermarket_partition.py

This reads literal inputs from the preserved MATLAB script without executing
MATLAB. It enumerates every nonempty contiguous station partition assigned to
the first k supermarket sites, subject to every site's capacity. That is the
baseline random-key decoder's feasible search space, not an unrestricted
facility-location model with arbitrary site subsets or station assignments.

Coordinates and costs are scaled by ten and evaluated as integers, so the
enumeration and cost comparisons do not depend on floating-point tolerances.
The JSON result is written to standard output; redirect it to save a record.
"""

from decimal import Decimal
from hashlib import sha256
from itertools import combinations
import json
from pathlib import Path
import re


NUMBER = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


def integer(value, name):
    """Require an exact integer, including for scaled decimal literals."""
    if value != value.to_integral_value():
        raise ValueError(f"{name} must be an exact integer, got {value}")
    return int(value)


def scalar(text, name):
    """Read a scalar literal; never evaluate MATLAB expressions."""
    match = re.search(rf"(?m)^\s*{re.escape(name)}\s*=\s*({NUMBER})\s*;", text)
    if match is None:
        raise ValueError(f"Missing scalar literal {name}")
    return Decimal(match.group(1))


def vector(text, name):
    """Read the simple one-row numeric vector literals in this source."""
    match = re.search(rf"(?m)^\s*{re.escape(name)}\s*=\s*\[([^\]]*)\]\s*;", text)
    if match is None:
        raise ValueError(f"Missing vector literal {name}")
    tokens = re.split(r"[\s,]+", match.group(1).strip())
    if not tokens or any(re.fullmatch(NUMBER, token) is None for token in tokens):
        raise ValueError(f"{name} contains more than a numeric row vector")
    return [Decimal(token) for token in tokens]


def source_model(path):
    """Parse and validate the input constants used by the archived PSO."""
    source_bytes = path.read_bytes()
    text = re.sub(r"%[^\r\n]*", "", source_bytes.decode("utf-8"))
    stations = integer(scalar(text, "W"), "W")
    sites = integer(scalar(text, "S"), "S")
    capacity = integer(scalar(text, "SC"), "SC")
    installation = scalar(text, "SIC")
    shipment = scalar(text, "SUC")
    # The preserved script's fitness expression hard-codes 1000 and 1 even
    # though it also declares SIC and SUC. Reject a mismatched declaration.
    if installation != 1000 or shipment != 1:
        raise ValueError("The archived PSO fitness embeds SIC=1000 and SUC=1")
    demand = [integer(value, "dw") for value in vector(text, "dw")]
    coordinates = {
        name: [integer(value * 10, name + " * 10") for value in vector(text, name)]
        for name in ("xw", "yw", "Xs", "Ys")
    }
    if any(len(coordinates[name]) != stations for name in ("xw", "yw")):
        raise ValueError("Workstation coordinate count does not match W")
    if any(len(coordinates[name]) != sites for name in ("Xs", "Ys")):
        raise ValueError("Supermarket coordinate count does not match S")
    if len(demand) != stations or any(value <= 0 for value in demand):
        raise ValueError("Expected W positive integer demands")
    if capacity <= 0 or sites <= 0:
        raise ValueError("Capacity and site count must be positive")
    return {
        "stations": stations,
        "sites": sites,
        "capacity": capacity,
        "demand": demand,
        "installation_cost_tenths": integer(installation * 10, "SIC * 10"),
        "shipment_unit_cost": integer(shipment, "SUC"),
        "coordinates_tenths": coordinates,
        "source_sha256": sha256(source_bytes).hexdigest(),
    }


def enumerate_partitions(model):
    """Evaluate all feasible nonempty contiguous groups on prefix sites."""
    n, s = model["stations"], model["sites"]
    demand, capacity = model["demand"], model["capacity"]
    xy = model["coordinates_tenths"]
    minimum_sites = (sum(demand) + capacity - 1) // capacity
    if minimum_sites > s:
        raise ValueError("Total demand exceeds the combined site capacity")
    by_site_count = []
    for k in range(minimum_sites, min(s, n) + 1):
        examined = feasible = ties = 0
        best = None
        for cuts in combinations(range(1, n), k - 1):
            examined += 1
            bounds = (0,) + cuts + (n,)
            loads = [sum(demand[bounds[j]:bounds[j + 1]]) for j in range(k)]
            if any(load > capacity for load in loads):
                continue
            feasible += 1
            shipment_tenths = sum(
                model["shipment_unit_cost"] * demand[w] * 2 * (
                    abs(xy["Xs"][j] - xy["xw"][w])
                    + abs(xy["Ys"][j] - xy["yw"][w])
                )
                for j in range(k)
                for w in range(bounds[j], bounds[j + 1])
            )
            installation_tenths = k * model["installation_cost_tenths"]
            total_tenths = shipment_tenths + installation_tenths
            if best is None or total_tenths < best["total_cost_tenths"]:
                ties = 1
                best = {
                    "total_cost_tenths": total_tenths,
                    "total_cost": total_tenths / 10,
                    "shipment_cost_tenths": shipment_tenths,
                    "shipment_cost": shipment_tenths / 10,
                    "installation_cost": installation_tenths / 10,
                    "cuts_after_station_1based": list(cuts),
                    "station_groups_1based_inclusive": [
                        [bounds[j] + 1, bounds[j + 1]] for j in range(k)
                    ],
                    "supermarket_loads": loads,
                    "open_site_indices_1based": list(range(1, k + 1)),
                }
            elif total_tenths == best["total_cost_tenths"]:
                ties += 1
        by_site_count.append({
            "open_sites": k,
            "partitions_examined": examined,
            "capacity_feasible_partitions": feasible,
            "optimal_partition_count": ties,
            "best": best,
        })
    candidates = [item for item in by_site_count if item["best"] is not None]
    if not candidates:
        raise ValueError("No capacity-feasible contiguous-prefix partition exists")
    winner = min(candidates, key=lambda item: item["best"]["total_cost_tenths"])
    return minimum_sites, by_site_count, winner


def verify():
    root = Path(__file__).resolve().parents[1]
    relative_source = "src/supermarket_pso/supermarket_swarm_optimization.m"
    model = source_model(root / relative_source)
    minimum_sites, by_site_count, winner = enumerate_partitions(model)
    result = {
        "schema_version": 1,
        "method": "Exhaustive enumeration with exact integer tenth-unit costs",
        "scope": (
            "Nonempty contiguous workstation groups assigned in order to "
            "the first k supermarket sites, matching the baseline PSO decoder. "
            "This does not establish an optimum for unrestricted site subsets "
            "or arbitrary workstation assignments."
        ),
        "matlab_executed": False,
        "source": {"path": relative_source, "sha256": model.pop("source_sha256")},
        "model_inputs": model,
        "capacity_lower_bound_open_sites": minimum_sites,
        "excluded_smaller_site_counts": list(range(1, minimum_sites)),
        "exclusion_reason": "Combined capacity is below total demand",
        "partitions_examined": sum(item["partitions_examined"] for item in by_site_count),
        "capacity_feasible_partitions": sum(
            item["capacity_feasible_partitions"] for item in by_site_count
        ),
        "results_by_open_site_count": by_site_count,
        "optimal_open_sites": winner["open_sites"],
        "optimum_within_scope": winner["best"],
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    verify()

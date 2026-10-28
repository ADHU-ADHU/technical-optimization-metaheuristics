# Steelmaking production planning with linear programming

This model allocates operating hours across three machines to meet weekly demand for four sizes of steel girder at minimum cost. It provides a continuous linear programming example alongside the repository's metaheuristic implementations.

## Model inputs

Production rates are in metres per operating hour.

| Girder size | Machine A | Machine B | Machine C | Weekly demand (m) |
| --- | ---: | ---: | ---: | ---: |
| Small | 300 | 600 | 800 | 12,000 |
| Medium | 250 | 400 | 800 | 8,000 |
| Large | 200 | 350 | 600 | 6,000 |
| Extra-large | 100 | 200 | 300 | 6,000 |

| Machine | Operating cost ($/hour) | Available hours/week |
| --- | ---: | ---: |
| A | 30 | 50 |
| B | 50 | 30 |
| C | 80 | 20 |

Let $h_{ij}\geq0$ denote operating hours for girder size $i$ on machine $j$, with production rate $r_{ij}$, hourly cost $c_j$, demand $d_i$, and availability $H_j$.

$$\min_h \sum_j c_j\sum_i h_{ij}$$

subject to:

$$\sum_j r_{ij}h_{ij}\geq d_i\quad\text{for each girder size}$$

$$\sum_i h_{ij}\leq H_j\quad\text{for each machine}$$

There are 12 continuous decision variables, four demand constraints, three machine-time constraints, and nonnegativity bounds. The model allocates aggregate weekly hours; setup times, switching costs, and the detailed sequence of production are outside its scope.

## Equivalent MATLAB formulations

Both original scripts call [`linprog`](https://www.mathworks.com/help/optim/ug/linprog.html), requiring MATLAB and Optimization Toolbox:

- [`optimization_assignment.m`](../src/steelmaking_lp/optimization_assignment.m) groups variables by machine, then girder size.
- [`optimization_assignment_different_formulation.m`](../src/steelmaking_lp/optimization_assignment_different_formulation.m) groups variables by girder size, then machine.

The second script permutes the columns of the first model. The objective, constraints, and feasible allocations remain equivalent. Run one script at a time; both clear the workspace before solving.

Convert the returned vector `x` into rows of girder sizes and columns A/B/C:

```matlab
% After optimization_assignment.m:
hours_by_size_machine = reshape(x,4,3);

% After optimization_assignment_different_formulation.m:
hours_by_size_machine = reshape(x,3,4).';
```

## Optimal cost and multiple solutions

The archived MATLAB and Excel results report a minimum weekly operating cost of **$4,300**. An independent SciPy/HiGHS check confirmed this optimum for both source formulations. MATLAB and Excel Solver were not rerun during repository preparation.

One optimal allocation, saved in the supplied workbook, is:

| Girder size | A hours | B hours | C hours |
| --- | ---: | ---: | ---: |
| Small | 0 | 20 | 0 |
| Medium | 0 | 0 | 10 |
| Large | 0 | 0 | 10 |
| Extra-large | 40 | 10 | 0 |
| **Total** | **40** | **30** | **20** |

It meets every demand exactly, leaves 10 hours unused on A, and costs $30(40)+50(30)+80(20)=4,300$.

Multiple optimal allocations exist. The archived report's Excel table shows a different feasible allocation with the same machine-hour totals and $4,300 cost. The saved workbook matches the report's second MATLAB allocation. These snapshots therefore agree on cost without containing identical hour allocations. A solver can return another optimal allocation depending on its algorithm and variable order.

## Workbook and verification

The [Excel workbook](../data/steelmaking-production-plan.xlsx) retains its original sheet, formulas, cached results, formatting, and Solver configuration. Its saved absolute directory metadata was removed; [workbook provenance](../data/workbook-provenance.json) records the change and checksums.

On sheet `List1`, Solver minimizes `D32` by changing `M7:O10`, subject to `D17:D20 >= F17:F20`, `D25:D27 <= F25:F27`, and nonnegative hours. The saved engine is Simplex LP. Cached values are historical results, not evidence of a fresh Solver run.

For the independent source-matrix, column-permutation, feasibility, and primal/dual checks:

```bash
python3 tools/check_steel_lp.py
```

This optional check requires NumPy and SciPy and does not execute MATLAB.

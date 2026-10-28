# Exact verification of supermarket location

The recorded PSO cost of **€8,071.20 is globally optimal within the original decoder's allocation space**. The broader capacity-constrained location model has a lower global optimum of **€7,349.60**. Both statements use the same 30 workstation demands, five candidate coordinates, capacity 60, installation cost €1,000 per open site, and round-trip Manhattan shipment cost from the preserved MATLAB source.

| Check | Allowed decisions | Result |
| --- | --- | ---: |
| Exact partition enumeration | Nonempty contiguous station groups on sites `1..k`, as represented by the baseline PSO decoder | **€8,071.20** |
| Binary mixed-integer linear program (MILP) | Any subset of sites; each workstation assigned wholly to one open site | **€7,349.60** |
| Independent site-subset certificate | Exact nearest-site lower bounds for every subset with enough total capacity | **€7,349.60**, attained by a feasible assignment |
| Continuous LP relaxation of the MILP | Fractional openings and workstation assignments permitted | **€6,960.941538**, a lower bound |

These are new mathematical checks of the supplied model, separate from the historical PSO and SA runs. No MATLAB optimizer was rerun, and the original scripts have not been changed.

## Original decoder: an exact check

Demand totals 186, so at least four sites of capacity 60 must open. The decoder assigns workstation 1 to site 1, processes workstations in order, and can either retain the current site or advance to its immediate successor. It cannot skip a candidate site or return to an earlier one.

The [partition checker](../tools/check_supermarket_partition.py) enumerates every way to cut the 30 stations into four or five nonempty consecutive groups and assigns those groups to the first four or five sites. Coordinates and costs are scaled by ten and evaluated with integers.

| Open prefix | Partitions checked | Capacity-feasible | Minimum cost |
| --- | ---: | ---: | ---: |
| Sites 1–4 | 3,654 | 121 | €8,524.80 |
| Sites 1–5 | 23,751 | 3,515 | **€8,071.20** |

The unique optimal partition uses station groups `1–6`, `7–12`, `13–18`, `19–24`, and `25–30`, with loads `[41, 28, 32, 41, 44]`. This matches the cost and loads reported for PSO in the presentation. The archived convergence figure alone contains no assignments, but the exact enumeration supplies a feasible allocation attaining that cost.

## Full location model as a MILP

Let `y[s]` be 1 if site `s` opens and `x[w,s]` be 1 if workstation `w` is assigned to it. Define the shipment coefficient:

```text
c[w,s] = 2 × demand[w] × (|xw[w] − Xs[s]| + |yw[w] − Ys[s]|)
```

The model has 150 binary assignment variables and five binary opening variables:

```text
minimize  1000 Σs y[s] + Σw,s c[w,s] x[w,s]

subject to
  Σs x[w,s] = 1                         for each workstation w
  Σw demand[w] x[w,s] ≤ 60 y[s]         for each candidate site s
  x[w,s] ≤ y[s]                        for every w,s
  x[w,s], y[s] ∈ {0,1}
```

The [MILP checker](../tools/check_supermarket_milp.py) parses the numerical literals from the original PSO script and solves this model using [SciPy `milp`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.milp.html) with HiGHS. It checks assignment, capacity, opening links, integrality, and recomputed cost. The final objective and solver lower bound both equal **€7,349.60**, with **zero MIP gap**.

| Open site | Workstations supplied | Demand | Capacity |
| --- | --- | ---: | ---: |
| 1 | 1–6 | 41 | 60 |
| 2 | 7–15 | 43 | 60 |
| 4 | 16–24 | 58 | 60 |
| 5 | 25–30 | 44 | 60 |

Installation costs **€4,000**, and shipment costs **€3,349.60**. The groups happen to be contiguous, but the model does not impose that restriction. Site 3 stays closed: the original prefix decoder cannot represent this choice.

Relative to this broader optimum, the archived PSO value is **€721.60 higher**, or about **9.82%**. This difference comes from the feasible allocation space, rather than a failure to optimize the original encoding.

## A finite, exact certificate

The demand bound leaves only six potentially feasible opening subsets: five ways to choose four sites and one way to choose all five. For each subset, ignoring capacity and assigning every station to its nearest open site gives a lower bound on any capacity-feasible allocation for that subset.

| Open sites | Installation + nearest-site shipment lower bound |
| --- | ---: |
| 1, 2, 3, 4 | €7,907.20 |
| 1, 2, 3, 5 | €7,501.60 |
| **1, 2, 4, 5** | **€7,349.60** |
| 1, 3, 4, 5 | €7,412.00 |
| 2, 3, 4, 5 | €7,808.80 |
| 1, 2, 3, 4, 5 | €8,071.20 |

Every lower bound is at least €7,349.60. The nearest-site allocation for sites 1, 2, 4, 5 also satisfies every capacity, so it attains that lower bound. This proves global optimality for this instance independently of the MILP solver's floating-point termination status. The checker evaluates these costs in integer tenths.

## Why ordinary LP gives a different number

Relaxing all binary variables to the interval `[0,1]` produces a continuous linear program, solved separately with [SciPy `linprog`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.linprog.html). Its minimum is **€6,960.941538**. Fractional openings and split workstation assignments are allowed in this relaxation, so its solution is a lower bound, not an implementable discrete location plan. MILP is needed to enforce whole assignments and open/closed decisions.

## Reproduce

From the repository root:

```bash
# Standard library only
python3 tools/check_supermarket_partition.py > /tmp/supermarket-partition-check.json

# Python 3 with NumPy and SciPy >= 1.9
python3 tools/check_supermarket_milp.py --output /tmp/supermarket-milp-check.json
```

The committed records are [partition results](../data/supermarket-partition-check.json) and [MILP, LP, and subset results](../data/supermarket-milp-check.json). Both identify the source by SHA-256. See [setup](setup.md) for a Python environment and the [supermarket guide](supermarket-location.md) for the recorded SA/PSO comparison and source limitations.

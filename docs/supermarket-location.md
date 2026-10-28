# Assembly-line supermarket location

These experiments use simulated annealing (SA) and a custom particle swarm optimizer (PSO) to assign material demand from 30 workstations to line-side supermarkets. The goal is to balance installation cost against material shipment cost while respecting supermarket capacity.

## Model

The workstations lie along a straight assembly line at coordinates `(0,0), (2,0), …, (58,0)`. Their total demand is **186 units**. Five candidate supermarkets lie at x-coordinates `5.8, 17.4, 29, 40.6, 52.2`, all at y = 5. Each has capacity **60 units**.

The cost model uses:

- **€1,000** installation cost per supermarket.
- Shipment unit cost **€1**, multiplied by station demand and round-trip Manhattan distance.
- An infinite objective penalty when the final supermarket exceeds capacity.

For assignment `a(w)`, the total cost is:

```text
1,000 × number of open supermarkets
+ Σw [demand(w) × 2 × (|Xs(a(w)) − xw(w)| + |Ys(a(w)) − yw(w)|)]
```

The coordinate length unit is not specified. These are costs within the supplied model. The capacity bound `ceil(186/60) = 4` gives a minimum possible supermarket count; it does not certify an optimizer's result.

The baseline decoder processes stations in order. It assigns workstation 1 to supermarket 1, then either continues using the current supermarket or advances to the next one according to a random-key threshold and remaining capacity. This produces contiguous workstation groups and opens a prefix of supermarket indices. It does not explore every possible subset of candidate sites.

## Simulated annealing experiments

Start with [Exponential_Cooling.m](../src/supermarket_sa/Exponential_Cooling.m). Every variant is a standalone script with embedded model inputs.

The basic neighborhood replaces one random key for a station from 2 through 30. SA accepts improvements and can accept a worse candidate with probability `exp(−Δcost/T)`. The table records the code's actual settings; `k` counts temperature levels.

| Script | Initial / final temperature | Moves per level | Candidate threshold | Cooling and additional moves |
| --- | --- | --- | --- | --- |
| [Exponential_Cooling.m](../src/supermarket_sa/Exponential_Cooling.m) | 1,000 / 1 | 50 | 0.5 | `T ← 0.99T` |
| [Exponential2.m](../src/supermarket_sa/Exponential2.m) | 1,000 / 1 | 50 | 0.5 | `T ← T0 × 0.99^k` |
| [Hyperbolic.m](../src/supermarket_sa/Hyperbolic.m) | 100,000 / 1 | 500 | 0.5 | `T ← T × 0.99^k`; compounded geometric cooling despite its filename |
| [linearcooling.m](../src/supermarket_sa/linearcooling.m) | 100 / 1 | 1 | 0.7 | `T ← T0 − 0.8k` |
| [fastcooling.m](../src/supermarket_sa/fastcooling.m) | 1,000 / 2 | 50 | 0.6 | `T ← T0/(1 + 0.95k)`; preferential acceptance of fewer supermarkets |
| [withmutation.m](../src/supermarket_sa/withmutation.m) | 1,000 / 1 | 50 | 0.5 | `T ← T − 1`; 30% probability of swapping assignment labels and keys |
| [reversemutation.m](../src/supermarket_sa/reversemutation.m) | 1,000 / 1 | 50 | 0.6 | `T ← T0 × 0.99^k`; 10% assignment-segment reversal; preferential acceptance of fewer supermarkets |

Initial decoding uses threshold 0.5 in every variant. The two exponential scripts implement equivalent geometric schedules. The linear script's inner loop is commented out, so it makes one move per temperature level.

SA outputs temperature, current cost and supermarket-count plots, together with the terminal solution `sol`, assignment `aswstosup` and recomputed `final_cost`. The cost trace samples once per temperature level, rather than once per candidate evaluation. The scripts do not maintain a separate best-ever solution.

## Custom particle swarm optimization

[supermarket_swarm_optimization.m](../src/supermarket_pso/supermarket_swarm_optimization.m) implements PSO directly:

- 100 particles with 30 random-key coordinates.
- 200 iterations; cognitive and social coefficients both 1.
- Inertia decreases from 0.9 toward 0.4.
- The same threshold-0.5 decoder and numerical cost model as the SA baseline.

Outputs include best cost `g_best(31)`, workstation assignment `g_aswstosup`, supermarket loads `g_td` and convergence vector `cost_every_iteration`. The saved [convergence figure](../data/supermarket-pso-convergence.fig) is also included. This implementation does not call MATLAB's `particleswarm` solver.

## Interpreting comparisons

The original scripts are preserved. Before treating outputs as benchmark results, account for these implementation details:

- Swap and reversal variants change decoded assignments without recalculating capacity loads. Reversal also leaves the random-key representation unchanged. Validate their final loads independently.
- SA reports the current terminal state, and its plotted cost omits the capacity penalty. A finite plot value alone does not establish feasibility or best-so-far performance.
- PSO compares a full particle row against a scalar best cost when updating incumbents. It also leaves positions and velocities unclamped and hard-codes cost coefficients in its fitness expression.
- Runs have no fixed random seed. The variants use different move budgets, thresholds and acceptance rules, so the traces do not establish a controlled algorithm ranking.

All these scripts use base MATLAB operations. No new MATLAB runs were performed while preparing this repository, and no global-optimality claim is made.

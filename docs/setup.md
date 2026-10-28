# Setup and execution

## Requirements

The assembly-line GA and supermarket SA/PSO implementations use ordinary **base MATLAB** operations. They implement the search loops directly and do not call the Global Optimization Toolbox `ga` or `particleswarm` solvers.

The two steelmaking models use `linprog` and require **MATLAB Optimization Toolbox**. The optional independent LP check uses **Python 3, NumPy, and SciPy**. No Simulink model, external dataset, or GPU is required by these cases.

MATLAB was unavailable during repository preparation. The original scripts have been inspected and preserved, but their execution on a particular MATLAB release has not been newly verified.

## MATLAB entry points

Open MATLAB in the repository root. Run one case at a time:

| Command | Original script | Main outputs |
| --- | --- | --- |
| `run_assembly_ga` | [Uniform-crossover baseline](../src/assembly_line_ga/uniformcrossover.m) | `finalTP`, `finalTS`, `finalAsTaSt`, convergence histories and figure |
| `run_supermarket_sa` | [Exponential cooling](../src/supermarket_sa/Exponential_Cooling.m) | `sol`, `aswstosup`, `final_cost`, temperature and cost figures |
| `run_supermarket_pso` | [Custom supermarket PSO](../src/supermarket_pso/supermarket_swarm_optimization.m) | `g_best`, `g_aswstosup`, `g_td`, `cost_every_iteration` and figure |
| `run_steel_lp` | [Machine-first LP formulation](../src/steelmaking_lp/optimization_assignment.m) | `x`, `fval`, and a displayed 4-by-3 hour-allocation matrix |

The entry scripts locate source files relative to their own location; they contain no machine-specific paths. All original scripts clear the calling workspace and command window before running. Results then remain in that workspace, so save any needed results before starting another case.

The GA baseline uses population 100 and actually performs 501 generations because its loop includes `Max_G`. The exponential SA baseline makes 50 neighborhood moves at each temperature level. PSO uses 100 particles and 200 iterations. These original budgets are retained; execution time depends on the MATLAB installation and hardware.

## Inspecting results

For the GA, pair task IDs in `finalTS` with station indices at the corresponding sequence positions in `finalAsTaSt`. The last column of each output contains the station count. The [assembly-line guide](assembly-line.md) explains the operator variants and station-workload interpretation.

For supermarket location, inspect capacity loads as well as cost. The SA trace records the current state, rather than a separate best-ever incumbent; its plotted cost excludes the infinite capacity penalty. The [supermarket guide](supermarket-location.md) documents these details and differences between variants.

For the default LP formulation, rows represent small, medium, large, and extra-large girders; columns represent machines A, B, and C:

```matlab
hours_by_size_machine = reshape(x,4,3);
```

To run the alternative variable ordering separately:

```matlab
run('src/steelmaking_lp/optimization_assignment_different_formulation.m')
hours_by_size_machine = reshape(x,3,4).';
```

Both LP models have the same minimum cost, but a solver can return different optimal allocations. See the [steelmaking model](steelmaking-lp.md) for constraints, units, and workbook details.

## Optional independent LP verification

From the repository root in a terminal:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install numpy scipy
python tools/check_steel_lp.py
```

This tool parses the numerical matrices from both original MATLAB scripts and solves them with SciPy/HiGHS. It checks equivalent variable ordering, nonnegativity, demand and machine-hour feasibility, the **$4,300** optimum, a dual certificate, and two historical allocations. It does not run MATLAB or Excel.

## Recorded material

The convergence images, original PSO `.fig`, extracted [PSO trace](../data/recorded-pso-convergence.csv), [workbook](../data/steelmaking-production-plan.xlsx), and [48-slide presentation](presentation/technical-optimization-slides.pdf) retain historical project context. They do not establish a new statistical comparison of the heuristics.

Original source checksums are listed in the [source manifest](../data/source-manifest.json). The workbook's metadata cleanup is documented separately in [workbook provenance](../data/workbook-provenance.json).

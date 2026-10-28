# Assembly-line balancing with a genetic algorithm

This implementation assigns **35 assembly tasks to workstations** while respecting task precedence and a **61-second cycle-time limit**. Its objective is to minimize the number of stations: the fixed-cycle-time problem commonly called **SALBP-1**.

All four scripts contain the same task durations and precedence matrix. The tasks total **485 seconds**, the longest task takes **40 seconds**, and the graph has **45 precedence edges**. The workload bound is `ceil(485 / 61) = 8` stations; this bound does not establish that a precedence-feasible eight-station solution has been found.

## How a candidate becomes an assignment

Each chromosome contains 35 continuous task priorities. The decoder repeatedly selects the highest-priority task whose predecessors have already been selected, producing a valid task sequence. It assigns consecutive tasks to the current station until the next task would exceed the cycle limit, then opens another station.

Fitness is the resulting station count. The decoder does not search later tasks to fill a station's remaining capacity, and workload balance is not a separate optimization objective.

## Baseline and operator variants

The recommended starting point is [uniformcrossover.m](../src/assembly_line_ga/uniformcrossover.m). It implements genuine uniform crossover: each priority independently comes from one of two parents, using a 0.5 exchange probability. Mutation swaps two priorities, and elitism retains the best candidates. It also records convergence histories.

All variants use a population of 100. The table describes actual behavior rather than inferring operators from filenames.

| Original script | Actual operators | Offspring / mutation / elites |
| --- | --- | --- |
| [Uniform baseline](../src/assembly_line_ga/uniformcrossover.m) | Uniform parent mixing; two-position swap mutation | 80 / 10 / 10 |
| [Inversion variant](../src/assembly_line_ga/inversemutation_with_unifcorssover.m) | Uniform parent mixing; segment-inversion mutation | 80 / 10 / 10 |
| [Changed-rate variant](../src/assembly_line_ga/changed_crossover_probablity.m) | Reverses a segment within each parent separately; swap mutation | 50 / 10 / 40 |
| [Two-point-named variant](../src/assembly_line_ga/towpointcrossover.m) | Copies parents unchanged; swap mutation | 50 / 10 / 40 |

The changed-rate variant does not mix parents. The two-point-named variant writes each parent's own unchanged segment back into its copy, so it does not implement two-point crossover. Both declare 10% elitism, but their loops actually fill the remaining 40 population positions with elites. These are therefore not controlled comparisons changing only crossover probability.

## Reading the outputs

- `finalTP`: sorted priority chromosomes, with station count in column 36.
- `finalTS`: sorted task sequences, with station count in column 36.
- `finalAsTaSt`: station indices **by sequence position**, followed by station count. Pair these positions with the task IDs in `finalTS`; they are not directly indexed by task ID.
- The uniform and two-point-named scripts also produce `bestresult_eachgeneration`, `freq_lowest_value`, and a plot of station count and the number of candidates sharing the minimum.

Station workloads can be calculated by summing task durations for each assigned station. The accompanying problem's “workload deviation” means average unused station capacity, `sum(61 - stationWorkload) / stationCount`. For these tasks, it equals `61 - 485 / stationCount`; it is not standard deviation.

## Reproducibility and limitations

The scripts use base MATLAB and embed their input data. They start with `clear` and `clc`, clearing the calling workspace. No explicit RNG seed is included. `Max_G = 500` combined with `while G <= Max_G` executes **501 generations**.

The uniform script's unused `ppj` and `ppj2` statistics always evaluate to zero because their comparisons add one or two to every fitness before comparing against the minimum. They do not measure near-best solutions.

Input feasibility is not guarded: reducing the cycle time below a task duration can prevent the decoder from advancing. Validate modified precedence data for cycles before running.

The original files are preserved unchanged. No new MATLAB execution or statistical operator ranking is claimed during repository preparation, and the heuristic does not certify global optimality.

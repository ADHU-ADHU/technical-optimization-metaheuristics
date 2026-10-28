# Source preservation and verification

This repository organizes the supplied technical optimization scripts, saved results, workbook, and presentation into documented components. Original filenames and algorithm logic are retained, including spelling and implementation quirks that affect interpretation.

## Original and derived files

| Material | Publication treatment | Record |
| --- | --- | --- |
| MATLAB implementations and saved PSO figure | Copied without changing source bytes | [Source manifest](../data/source-manifest.json) |
| Steelmaking Excel workbook | Removed one saved absolute-directory metadata element; every other ZIP-entry payload is unchanged | [Workbook provenance](../data/workbook-provenance.json) |
| Presentation | Exported all 48 slides to a static PDF using LibreOffice 24.2; original presentation credits retained | [Presentation provenance](../data/presentation-provenance.json) |
| Experiment plots and PSO trace | Rendered or extracted from the original presentation and saved MATLAB figure, without rerunning the searches | [Asset provenance](../data/asset-provenance.json) |
| Documentation, entry points, and independent checks | Added for navigation, explanation, and verification | Repository source files |

Supporting reports and problem statements informed the documentation. They have not been republished as project source. The presentation includes a cited literature review: its opening section discusses [Fathi et al. (2016)](https://doi.org/10.1080/00207543.2015.1090032). That paper's modified PSO source is not part of this collection.

## What has been checked

Source hashes identify the preserved files. The workbook's sheet, formulas, cached values, styles, and Solver named configuration remain intact; only the saved-directory element was removed. The presentation conversion retains 48 pages, inspected as a contact sheet. Its 3D cover object is represented statically in the PDF.

The [steelmaking check](../tools/check_steel_lp.py) reads the two original MATLAB models, verifies their column-permutation equivalence, solves each with SciPy/HiGHS, and checks feasibility and matching primal/dual bounds at $4,300. It also confirms that the two historical allocations are feasible optimal solutions. This check does not execute MATLAB or Excel Solver.

The metaheuristic scripts were reviewed against their recorded outputs and presentation descriptions. No fresh MATLAB runs, repeated-trial benchmark, or certified ranking of GA, SA, and PSO is claimed. Historical convergence curves describe saved runs. They do not by themselves prove capacity feasibility or global optimality.

Use the component documentation when reproducing results:

- [Assembly-line balancing](assembly-line.md) explains the operators actually implemented, population counts, and eight-station workload lower bound.
- [Supermarket location](supermarket-location.md) explains decoding restrictions, cooling schedules, feasibility checks, and unequal experiment budgets.
- [Steelmaking LP](steelmaking-lp.md) distinguishes saved workbook values, reported allocations, and independent verification.

The historical presentation is preserved as a record. Its labels and reported values have not been silently edited to match later source analysis.

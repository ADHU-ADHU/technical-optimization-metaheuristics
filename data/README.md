# Data and recorded artifacts

- [Saved PSO figure](supermarket-pso-convergence.fig): the original MATLAB figure containing one recorded 200-iteration convergence series.
- [Recorded convergence values](recorded-pso-convergence.csv): the figure's X/Y values exported without rerunning the optimizer. The first cost is infinite; the final recorded cost is 8071.2. The figure contains no allocation or capacity information.
- [Steelmaking workbook](steelmaking-production-plan.xlsx): the original model, formulas, Solver configuration and cached solution, with a saved directory path removed from workbook metadata. See [workbook provenance](workbook-provenance.json).
- [Source manifest](source-manifest.json): checksums of the unchanged MATLAB scripts and saved figure.
- [SA convergence image provenance](supermarket-sa-convergence-provenance.json): source and crop details for the best reported SA terminal trial shown beside PSO; no numerical SA series has been reconstructed.
- [Exact partition check](supermarket-partition-check.json): exhaustive enumeration of the PSO decoder's contiguous-prefix allocations, confirming an optimum of €8,071.20.
- [Full location MILP check](supermarket-milp-check.json): the €7,349.60 unrestricted optimum, LP relaxation, capacity checks, and an exact six-subset certificate.

Images, presentation exports and their provenance are described in [the project provenance guide](../docs/provenance.md). These artifacts record historical experiments and model inputs; they do not constitute newly executed MATLAB benchmarks.

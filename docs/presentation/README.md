# Technical optimization presentation

[View the 48-slide presentation](technical-optimization-slides.pdf)

The PDF preserves the supplied presentation and its original credits. It covers a literature review, assembly-line balancing with a genetic algorithm, supermarket-location experiments with simulated annealing and PSO, and steelmaking production planning with linear programming.

## Reading the slides alongside the code

The opening ten slides review Fathi, Rodríguez, Fontes and Alvarez's paper, [*A modified particle swarm optimisation algorithm to solve the part feeding problem at assembly lines*](https://doi.org/10.1080/00207543.2015.1090032), *International Journal of Production Research* 54(3), 878–893 (2016). The paper's modified PSO implementation is not included in this repository. The supplied supermarket PSO is a separate implementation described in [supermarket location](../supermarket-location.md).

The remaining slides document historical project experiments. Use the component notes for the behavior of the preserved source:

- [Assembly-line GA](../assembly-line.md): the recorded result is nine stations. The workload lower bound is eight; neither value certifies global optimality.
- [Supermarket SA and PSO](../supermarket-location.md): the recorded PSO cost is 8,071.2. A convergence figure alone cannot establish that the final allocation satisfies capacity constraints or prove a ranking across algorithms.
- [Steelmaking LP](../steelmaking-lp.md): the recorded $4,300 optimum was independently checked from the source matrices with SciPy/HiGHS. MATLAB and Excel Solver were not rerun during publication.

Two slide labels need care when reproducing experiments. Slide 19's population counts sum to 102 despite stating a population of 100. Slide 31 labels a schedule “Hyperbolic”; the corresponding `Hyperbolic.m` actually compounds a geometric temperature update. The code notes document the implemented counts, cooling formulas, and other differences between variants. The historical slides have been retained without rewriting these labels.

## PDF conversion

The PDF was exported from `Presentation V3.0.pptx` using LibreOffice 24.2, and all 48 pages were reviewed as a contact sheet. The original deck is approximately 33.6 MB, including a 30.5 MB embedded 3D object. This approximately 2.4 MB PDF provides a static view; the cover's 3D object and presentation effects are not interactive.

[Presentation provenance](../../data/presentation-provenance.json) records the source and derived-file checksums. See [repository provenance](../provenance.md) for source preservation and verification scope.

# One-week roadmap

The schedule prioritizes a defensible final report over optional features. A stage is complete only when its acceptance criteria pass.

## Priorities

### P0 — required

- finalized bootstrap and audited tooling;
- deterministic circle and Lissajous trajectories;
- sampling, fixed delay, ZOH, and constant-velocity prediction;
- first-order plant;
- validated metrics and reference systems;
- deterministic parameter comparison;
- report figures and final report;
- reproducibility audit.

### P1 — add when P0 is stable

- point-to-point minimum-jerk random trajectories;
- time-constant sensitivity;
- dimensionless analysis using \(\omega L\), \(\omega T\), and \(\omega h_s\).

### P2 — first scope cuts

- bootstrap confidence intervals;
- animation;
- phase-lag diagnostics;
- extra plotting variants.

## Day 1 — bootstrap finalization and trajectories

**Work**
- audit migrated `devkit.toml` and `skills/`;
- adopt only verified assets;
- merge PR #1 after human review;
- implement circle and Lissajous position/velocity generators in a new PR;
- test periodicity, derivatives, amplitude, and shape.

**Completion**
- documentation is authoritative;
- every migrated asset has a decision;
- deterministic trajectories pass analytic MATLAB tests.

**Cut first**
- additional trajectory types.

## Day 2 — packet sampling and reconstruction

**Work**
- sample at fixed \(h_s\);
- implement fixed delay;
- select latest packet;
- implement ZOH and CV;
- define startup history.

**Completion**
- exact sample and arrival boundaries pass;
- zero-delay and constant-velocity fixtures pass;
- CV uses packet timestamp age.

**Cut first**
- advanced diagnostics, never boundary tests.

## Day 3 — plant and metrics

**Work**
- implement first-order plant;
- choose and document integrator;
- compare with an analytic case;
- implement task and delay-induced metrics;
- fix warm-up and evaluation window.

**Completion**
- analytic fixtures pass;
- time-step halving meets the documented threshold;
- zero-error and normalization guards pass.

## Day 4 — deterministic factorial study

**Work**
- sweep method, delay, speed, and deterministic trajectory;
- save config and results;
- generate paths, error histories, and contour/heat maps;
- inspect failed or non-finite cases.

**Completion**
- expected case count is verified;
- all P0 cases regenerate from one command;
- plots have units and traceable data.

**Cut first**
- grid density, not comparison dimensions.

## Day 5 — interpretation and P1

**Work**
- analyze \(\omega L\), and if needed \(\omega T\), \(\omega h_s\);
- run small time-constant sensitivity;
- add random minimum-jerk trajectories only if P0 is stable.

**Completion**
- claims distinguish observations from hypotheses;
- dimensionless collapse or its failure is documented;
- random comparisons use common seeds.

**Cut first**
- random ensemble, bootstrap intervals, animation.

## Day 6 — report assembly

**Work**
- complete purpose, model, conditions, program, results, discussion;
- number equations, figures, and tables;
- connect each claim to verified output or reference;
- state limitations and purpose achievement.

**Completion**
- no placeholder result remains;
- every figure regenerates;
- references are verified and cited.

## Day 7 — reproducibility audit

**Work**
- clone or clean the repository;
- run complete P0 workflow;
- compare regenerated artifacts;
- audit units, labels, numbering, links, bibliography;
- confirm no secret or irrelevant artifact is committed.

**Completion**
- clean-workspace regeneration succeeds;
- final report matches code and figures;
- unresolved limitations are explicit.

## Gate rules

- Do not start random trajectories before deterministic end-to-end metrics work.
- Do not write result prose before regeneration is stable.
- Do not increase model fidelity if it obscures the delay question.
- When behind schedule, remove P2, then P1; never remove P0 validation.

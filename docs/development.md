# Development and validation

## 1. Verified environment

Bootstrap verification was performed with MATLAB R2025b. Later PRs report the actual version used. No toolbox is required until its availability and necessity are documented.

## 2. Entry points

From the repository root:

```powershell
matlab -batch "status=run_project(); assert(status==0)"
```

Smoke test:

```powershell
matlab -batch "addpath('tests'); c=onCleanup(@() rmpath('tests')); status=smoke_test(); assert(status==0)"
```

Interactive equivalents:

```matlab
status = run_project();
assert(status == 0);
```

```matlab
addpath("tests");
cleanup = onCleanup(@() rmpath("tests"));
status = smoke_test();
assert(status == 0);
```

Entry points restore MATLAB path state. Tests must not depend on state from prior invocations.

## 3. Branch and PR workflow

- Start from updated `main`.
- Create one branch for one work unit.
- Do not create an Issue unless it records a real backlog item.
- Keep the PR draft while implementation or validation is incomplete.
- Do not merge from Codex.
- Human review decides Ready and merge.

Each PR synchronizes:

1. implementation;
2. tests;
3. `research/log.md`;
4. one report under `docs/reports/`;
5. affected architecture or development documentation.

## 4. Implementation sequence

1. deterministic trajectory contract and generators;
2. sender sampling, packet delay, ZOH, and CV reconstruction;
3. plant model and numerical integration;
4. reference systems and metrics;
5. deterministic factorial study;
6. optional random and sensitivity work;
7. final report generation.

## 5. MATLAB coding expectations

Project-specific rules are in `skills/teleop-delay-matlab/SKILL.md`. The normal generic MATLAB source is `skills/matlab-engineering/SKILL.md`; an upstream MathWorks Skill is not part of normal routing and may be considered only as a separately verified future candidate. Project contracts take precedence if one is ever adopted.

Core expectations:

- functions rather than base-workspace scripts;
- explicit configuration and units;
- `N x 2` time-series arrays;
- fail-fast validation;
- deterministic result generation;
- no hidden toolbox dependency;
- no global warning or error suppression.

## 6. Skill routing and evolution

For MATLAB work, read the generic contract first, then the study contract:

1. `skills/matlab-engineering/SKILL.md`;
2. `skills/teleop-delay-matlab/SKILL.md`;
3. `docs/architecture.md`;
4. the target code and tests.

Update `matlab-engineering` in the same PR when a failure, verified command, or repeated workflow generalizes to other MATLAB projects. Keep communication-delay research rules in `teleop-delay-matlab`, one-off details in code comments or the PR report, research decisions in `research/log.md`, and evidence plus validation in `skills/matlab-engineering/CHANGELOG.md`. Do not promote a single local incident or duplicate an existing rule; keep the Skill concise and rerun affected checks.

For ordinary Devkit use in this repository, read only the task-matched first-party Skill: tree exploration, encoding hygiene, inspect/edit/verify, Git drafts, documentation, metrics, or project bootstrap CLI usage. Keep `devkit-release-maintainer` outside normal routing. Use it only when the target is a Devkit source checkout containing `.github/workflows/release.yml`, `rust/crates/devkit-cli`, and `rust/crates/devkit-installer`, and the user explicitly requests Devkit release maintenance. Do not use it for `teleop-delay-study` release work. The Python sync script bundled with `devkit-project-bootstrap` is likewise a guarded Devkit-source maintenance fallback; prefer the Devkit CLI for this repository.

## 7. Validation levels

### Documentation-only PR

- verify relative links;
- verify terminology against `research/problem_statement.md`;
- verify commands against actual files;
- run `git diff --check`.

### Entry-point/configuration PR

- run `run_project`;
- run `smoke_test`;
- verify status `0`;
- verify MATLAB path before and after;
- test invalid configuration rejection.

### Scientific-function PR

- add focused unit tests;
- include hand-calculated or analytic fixtures;
- test boundaries and invalid inputs;
- verify finite output and array shapes;
- run smoke test and entry point.

### Numerical-model PR

Also:

- compare with an analytic solution where possible;
- halve integration step and quantify metric change;
- reject NaN/Inf;
- document solver, step, and convergence threshold.

### Experiment PR

- use a clean output directory;
- save configuration with results;
- run paired methods on identical trajectories;
- verify expected case count;
- generate plots from saved results;
- report runtime and failed cases.

## 8. Results and figures

`results/` contains generated intermediate data, run manifests, diagnostics, and tables. It is ignored except for its placeholder.

`report/figures/` contains final figures used in the report and is tracked. A committed figure has a documented regeneration command and source result/config.

Do not manually alter plotted values or replace generated figures with visually similar files.

## 9. Research log

Append a dated entry whenever any of the following changes:

- research question or hypothesis;
- signal or metric definition;
- default or sweep parameter;
- initialization or evaluation window;
- solver or convergence threshold;
- scope or priority;
- interpretation of a result.

Do not rewrite earlier entries.

## 10. Failure handling

When a command fails:

1. retain the exact command and relevant output;
2. identify environment, contract, implementation, or data failure;
3. do not label the check successful;
4. make the smallest correction;
5. rerun the failed and relevant regression checks;
6. record unresolved failures in the PR.

## 11. Migrated assets

Follow `docs/migrated-assets-policy.md` before staging imported local files. Audit results belong in `docs/reports/migrated-assets-audit.md`.

Upstream skill content and project-specific guidance must remain separate.

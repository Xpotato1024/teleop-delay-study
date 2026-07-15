# Contributing

This is a one-week individual research project. The workflow is lightweight, but scientific traceability is mandatory.

## Workflow

1. Start from the latest `main`.
2. Create one branch for one coherent work unit.
3. Implement the smallest complete change.
4. Add or update executable tests.
5. Append the research decision or condition change to `research/log.md`.
6. Add or update one implementation report under `docs/reports/`.
7. Run required MATLAB and static checks.
8. Open a draft PR, review it, then mark it ready.
9. Merge only after human review.

Direct commits to `main` are prohibited.

## Preferred PR sequence

1. bootstrap and tooling
2. deterministic trajectories
3. packet sampling, delay, ZOH, and constant-velocity prediction
4. first-order plant and numerical integration
5. metrics and reference systems
6. deterministic factorial experiment
7. optional random trajectories and sensitivity
8. final report and reproducibility audit

## Commit messages

Use concise prefixes where practical: `docs:`, `test:`, `feat:`, `fix:`, `chore:`.

## MATLAB validation

Use commands in `docs/development.md` and report the exact MATLAB version. Static review or Octave does not count as MATLAB execution.

Every MATLAB PR confirms:

- status code;
- no unexpected path changes;
- finite outputs and expected shapes;
- relevant tests;
- `git diff --check`.

Numerical-model PRs also require an analytic or hand-calculated fixture and a time-step convergence check.

## Skills

The `skills/devkit-*` directories are first-party Devkit operation contracts. Read only the task-matched Skill. `skills/matlab-engineering/` is the generic, project-authored MATLAB contract; `skills/teleop-delay-matlab/` contains this study's research-specific rules. Do not mix the two.

Improve the generic MATLAB Skill only when a verified, generalizable failure or repeated workflow supports a concise rule. Keep study-specific decisions in the project Skill, one-off details in the PR report or code comments, and record evidence plus validation in `skills/matlab-engineering/CHANGELOG.md`.

## Documentation synchronization

These must agree:

- `research/problem_statement.md`
- `docs/architecture.md`
- code and tests
- `research/log.md`
- `docs/reports/`
- `report/final_report.md`

Do not rewrite prior log entries; append a dated entry.

## Generated artifacts

- `results/`: intermediate generated data; normally ignored
- `report/figures/`: final regenerated figures used in the report; tracked

Do not commit temporary MATLAB files or manually altered result copies.

## Migrated assets

Audit copied files under `docs/migrated-assets-policy.md` before staging. Unknown provenance, license, secrets, absolute paths, and stale project-specific instructions are blockers.

Upstream MATLAB skills and project-specific rules must remain separate.

## Merge checklist

- [ ] PR scope is coherent
- [ ] source-of-truth files are synchronized
- [ ] MATLAB commands and results are recorded
- [ ] tests cover the changed contract
- [ ] no invented result or citation exists
- [ ] no unreviewed migrated asset was staged
- [ ] generated results are reproducible
- [ ] `git diff --check` passes
- [ ] PR is human-reviewed

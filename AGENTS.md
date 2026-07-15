# AGENTS.md

## 1. Project purpose

This repository studies the effect of transport delay on remote position commands and the operating range of constant-velocity prediction compensation.

The deliverable is a reproducible MATLAB simulation study and a final report. The repository is not a general teleoperation framework and does not model human-subject performance, a real network, detailed robot kinematics, contact, force feedback, or machine-learning prediction.

## 2. Source-of-truth map

| Topic | Source of truth |
|---|---|
| Research question, hypotheses, scope | `research/problem_statement.md` |
| Research decisions and changes | `research/log.md` |
| Signal flow, model boundaries, data contracts | `docs/architecture.md` |
| Local development and validation | `docs/development.md` |
| One-week execution plan and scope cuts | `docs/roadmap.md` |
| Migrated-tooling adoption rules | `docs/migrated-assets-policy.md` |
| General MATLAB guidance | `skills/matlab/` only after provenance is verified |
| Project-specific MATLAB rules | `skills/teleop-delay-matlab/SKILL.md` |
| Final report | `report/final_report.md` |
| Per-PR implementation reports | `docs/reports/` |

Do not treat a PR description, chat message, generated result, or code comment as higher authority than these files.

## 3. Required reading by task

Before MATLAB implementation:

1. `research/problem_statement.md`
2. `docs/architecture.md`
3. `skills/teleop-delay-matlab/SKILL.md`
4. `skills/matlab/SKILL.md` only when upstream provenance has been verified and `skills/matlab/UPSTREAM.md` exists

Before changing project operation or structure:

1. `AGENTS.md`
2. `docs/development.md`
3. `docs/migrated-assets-policy.md`
4. `CONTRIBUTING.md`

Before writing the final report:

1. `research/problem_statement.md`
2. `research/log.md`
3. `docs/architecture.md`
4. verified outputs under `results/`
5. `report/final_report.md`

## 4. Preflight

For every task:

1. Confirm repository, default branch, current branch, and HEAD.
2. Run `git status --short`.
3. Inspect relevant tracked files before editing.
4. List untracked files separately; never stage them implicitly.
5. Confirm MATLAB availability and version for MATLAB work.
6. Confirm required toolboxes are installed before relying on them.
7. Identify validation commands before implementation.
8. Stop if the task conflicts with a source-of-truth document.

## 5. Invariants

- Never commit directly to `main`.
- Use branch → commit → pull request → human merge.
- Do not invent numerical results, citations, test success, or MATLAB execution.
- Distinguish executed, statically inspected, and not executed.
- Record conditions, solver, time step, sampling period, delay, and random seed.
- Keep intermediate generated data under `results/`.
- Keep final report figures under `report/figures/`; these figures are version-controlled.
- Do not hand-edit generated tables or figures and present them as reproducible outputs.
- Keep MATLAB identifiers in English. Documentation may be Japanese.
- Avoid globals, base-workspace state, hidden path mutation, and implicit dependencies.
- Update implementation, tests, `research/log.md`, and the relevant `docs/reports/` file in the same PR.
- Make the smallest coherent change and avoid unrelated rewrites.

## 6. Migrated assets

Untracked files imported from another project are candidate assets, not trusted project files.

Follow `docs/migrated-assets-policy.md` before adoption:

- do not stage before provenance, license, secrets, paths, and relevance are checked;
- do not merge upstream MathWorks material into the project-specific skill;
- preserve upstream structure, license, notice, and revision metadata when permitted;
- place local rules in `skills/teleop-delay-matlab/SKILL.md`;
- if provenance or redistribution rights cannot be verified, classify the asset as `Defer`.

## 7. Validation routing

| Change type | Required validation |
|---|---|
| Documentation only | relative links, terminology consistency, `git diff --check` |
| Entry point or configuration | `run_project`, `smoke_test`, status code, path restoration |
| Trajectory generator | analytic samples, shape/unit checks, endpoint or periodicity checks |
| Communication model | packet-age and boundary tests, zero-delay test, exact arrival cases |
| Numerical plant model | analytic case, finite-value checks, time-step convergence |
| Metrics | hand-calculated fixtures, zero-error case, normalization guards |
| Plotting/export | labels, units, legend, aspect ratio, deterministic regeneration |
| Final experiment | clean-workspace regeneration, config/result pairing, report traceability |

MATLAB execution must use the commands documented in `docs/development.md`. Octave never substitutes for MATLAB verification.

## 8. Stop conditions

Stop and report instead of guessing when:

- the research source of truth conflicts with the requested implementation;
- a signal, unit, shape, reference system, or evaluation window is ambiguous;
- required MATLAB or toolbox functionality is unavailable;
- migrated material has unknown provenance or redistribution terms;
- a validation failure cannot be explained;
- results change materially under a reasonable time-step reduction;
- the requested work would require inventing a citation or result.

## 9. Pull-request completion report

Every implementation PR reports:

- branch and commit SHA;
- changed files;
- implemented model or contract;
- exact MATLAB version and commands;
- tests and results;
- generated artifacts;
- source-of-truth documents updated;
- known limitations and unexecuted checks;
- confirmation that `main` was not directly modified and the PR was not merged.

---
name: matlab-engineering
description: Safe, reproducible MATLAB engineering for numerical and research code. Use for MATLAB environment checks, execution, testing, static review, debugging, and numerical validation; use the repository-specific teleoperation skill for study contracts.
---

# MATLAB engineering

## Scope and routing

Use this skill for general MATLAB operation, execution, testing, review, debugging, and reproducibility. Do not put teleoperation research assumptions here. Read [`skills/teleop-delay-matlab/SKILL.md`](../teleop-delay-matlab/SKILL.md) for repository-specific contracts and [`docs/architecture.md`](../../docs/architecture.md) for signal and equation contracts.

## Environment discovery

- Record the MATLAB release before implementation. In this repository, verify it with `matlab -batch "disp(version('-release'))"`.
- List installed products with `matlab -batch "ver"`; verify any required toolbox before relying on it.
- Prefer core MATLAB when it is sufficient. Do not turn MATLAB and Octave output into one verification result.
- Confirm a non-interactive command in the actual environment before documenting it.

## Execution and organization

- Run from the repository root with `matlab -batch` and use a function entry point that returns an explicit status.
- Save and restore path changes with a function-local cleanup object such as `onCleanup`; do not leave test paths or variables in the caller workspace.
- Keep one primary function per file. Make inputs, outputs, array shapes, and units explicit at function boundaries.
- Put parameters in a configuration structure. Avoid `global`, `eval`, `evalin`, `assignin`, and implicit workspace sharing.
- Keep numerical computation separate from plotting and file I/O when practical.

## Validation and errors

- Validate public inputs with `validateattributes`, `mustBe*`, `assert`, or explicit errors with stable identifiers.
- Reject NaN, Inf, invalid shapes, and invalid units at the boundary. Do not silently transpose data.
- Do not suppress warnings or errors unconditionally, and do not use catch-all handling to hide the original failure.
- Preserve the error identifier and stack when diagnosing a failure.

## Testing and static review

- Prefer small deterministic fixtures, hand-calculated or analytic cases, boundary cases, invalid inputs, and shape/unit checks.
- Use the test runner only when the target test format is confirmed; direct function smoke tests are valid project tests when they return a status.
- Check path restoration and clean-workspace behavior as part of entry-point tests.
- Use the MATLAB Code Analyzer available in the installed release (for this repository, `checkcode` was verified). Review unused variables, shadowing, path dependence, implicit expansion, array orientation, and obvious performance issues manually as well.
- Separate environment failures from implementation failures and rerun the failed check plus a relevant regression check after a fix.

## Numerical simulation and reproducibility

- Record solver, time step, initial conditions, evaluation interval, MATLAB release, products, and random seed.
- For stochastic work, use `rng(seed, "twister")`; do not manufacture sample size by repeating a deterministic case.
- Compare an analytic case where possible, halve the time step to check convergence, reject non-finite values, and distinguish numerical error from model error.
- Keep configuration paired with generated results. Regenerate tables and report figures from code; do not treat hand-edited outputs as source data.

## Plotting and completion report

- Label axes with quantities and units, add legends and titles, use appropriate aspect ratios, and consider common limits for method comparisons.
- Do not smooth data only for appearance. Keep report figures separate from intermediate outputs.
- Report MATLAB version, executed commands, changed files, tests, static analysis, path restoration, generated artifacts, convergence checks, unexecuted checks, and known limitations.

No MCP server, external toolkit, or unverified command is required by this skill.

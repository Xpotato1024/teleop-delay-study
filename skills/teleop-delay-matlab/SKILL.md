# Teleoperation Delay MATLAB Skill

## Scope

This skill defines repository-specific MATLAB contracts. It does not replace verified upstream MathWorks guidance. When `skills/matlab/UPSTREAM.md` exists, read the upstream MATLAB skill first, then apply this file.

## Entry points

- project run: `run_project`
- bootstrap smoke test: `smoke_test`
- focused tests: `tests/`
- parameters: `src/default_config.m`
- validation: `src/validate_config.m`

Entry points are functions, return status where practical, and restore MATLAB path changes.

## Environment discovery

Before MATLAB work:

1. record MATLAB version;
2. identify required toolboxes;
3. verify toolbox availability;
4. prefer core MATLAB when simpler;
5. use `matlab -batch` for recorded non-interactive validation;
6. never treat Octave as MATLAB verification.

## Data contracts

- time vector: `N x 1 double`, seconds;
- positions and velocities: `N x 2 double`;
- rows are time samples; columns are `x`, `y`;
- configuration uses SI units;
- public functions validate shape, finiteness, and scalar constraints;
- never silently transpose input.

Use clear reusable error identifiers, for example:

```matlab
error("teleopDelay:InvalidShape", "position must be N-by-2.");
```

## Coding rules

- Prefer one primary function per file.
- Avoid base-workspace scripts, `global`, `eval`, and hidden state.
- Centralize experiment parameters in configuration structures.
- Keep scientific functions free of plotting and file I/O where practical.
- Use `validateattributes`, `mustBe*`, `assert`, or explicit errors.
- Do not suppress warnings or errors globally.
- Avoid implicit expansion when it obscures dimensions.
- Document units and array orientation.
- Return structured outputs rather than many loose arrays.

## Trajectory functions

A deterministic generator returns:

- time;
- position;
- analytic velocity;
- metadata including type, amplitude, angular frequency, and units.

When acceleration supports interpretation or tests, generate it analytically.

Required tests:

- first/last or periodic consistency;
- amplitude and shape;
- analytic derivative versus finite difference away from boundaries;
- `N x 2` orientation;
- invalid input rejection.

## Sampling and delay

- sender sample times use `sample_period`;
- packet availability uses `send_time + delay <= current_time`;
- exact boundary behavior is tested;
- latest-packet selection is deterministic;
- timestamps, positions, and velocities remain paired;
- startup history is explicit;
- CV age is `current_time - packet_timestamp`, not only nominal delay.

Required fixtures:

- zero delay;
- integer and non-integer delay/sample ratios;
- exact packet arrival;
- constant-velocity target;
- pre-initialization behavior.

## Numerical plant

For `T*x_dot + x = u`:

- validate positive `T` and `dt`;
- reject non-finite commands;
- preserve `N x 2` shape;
- record solver and time step;
- compare against an analytic case;
- include time-step halving before final experiments.

The convergence threshold is documented in `research/log.md`, not hard-coded without explanation.

## Metrics

Implement metrics exactly as defined in `docs/architecture.md`.

Required tests:

- identical signals give zero;
- constant offset gives expected RMSE and max;
- normalization rejects zero or invalid scale;
- mismatched time and shape are rejected;
- improvement ratios guard zero denominators.

## Random studies

Use:

```matlab
rng(seed, "twister");
```

Generate each trajectory once per seed and reuse it for all methods. Save seed and waypoints with results.

Do not repeat deterministic runs to create artificial sample size.

## Results

A result bundle contains:

- configuration;
- method and trajectory identifiers;
- time and evaluated signals;
- metrics;
- MATLAB version;
- execution timestamp;
- solver and time step;
- random seed when applicable;
- convergence metadata where relevant.

Intermediate results go to `results/`. Final figures go to `report/figures/`.

## Plotting

- label axes with quantity and unit;
- include legends for multiple series;
- use equal data aspect ratio for Cartesian paths;
- use consistent limits for method comparisons;
- avoid visual smoothing absent from the data;
- make generation deterministic;
- export from code and record the command.

## Required completion report

After each MATLAB PR, report:

- changed files;
- implemented contract;
- exact MATLAB version and command;
- tests and results;
- path-restoration result;
- generated artifacts;
- convergence status when numerical;
- unexecuted checks and limitations;
- research-log and implementation-report updates.

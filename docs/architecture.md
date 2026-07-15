# Architecture and model contract

## 1. Modeling objective

The model isolates the relationship among packetized position commands, fixed transport delay, simple prediction, and a first-order robot response. Detailed robot kinematics and human behavior are intentionally omitted so that the effect of delay and compensation can be interpreted.

The implementation must not silently add packet loss, jitter, feedback control, joint-space dynamics, saturation, or workspace constraints.

## 2. System boundary

```mermaid
flowchart LR
    R[Continuous target trajectory r(t)]
    S[Sender sampling at t_k]
    P[Packet: t_k, r_k, v_k]
    D[Fixed transport delay L]
    A[Latest available packet]
    M{Command method}
    Z[Zero-order hold]
    C[Constant-velocity prediction]
    U[Applied command u_m,L(t)]
    G[First-order plant]
    X[Plant output x_m,L(t)]
    B[Method-specific zero-delay baseline x_m,0(t)]
    E[Metrics]

    R --> S --> P --> D --> A --> M
    M --> Z --> U
    M --> C --> U
    U --> G --> X --> E
    R --> E
    B --> E
```

## 3. Signals and planned data contracts

All positions and velocities are two-dimensional Cartesian quantities.

| Symbol | Meaning | Planned MATLAB representation |
|---|---|---|
| \(t\) | integration time | `N x 1 double`, seconds |
| \(\mathbf r(t)\) | continuous target position | `N x 2 double`, metres |
| \(\dot{\mathbf r}(t)\) | target velocity | `N x 2 double`, metres/second |
| \(t_k\) | sender sample time | scalar or `K x 1 double`, seconds |
| \(\mathbf r_k\) | sampled position | `K x 2 double` |
| \(\mathbf v_k\) | sampled velocity | `K x 2 double` |
| \(L\) | fixed one-way transport delay | scalar, seconds |
| \(\mathbf u_{m,L}(t)\) | reconstructed command | `N x 2 double` |
| \(\mathbf x_{m,L}(t)\) | plant output | `N x 2 double` |
| \(T\) | first-order time constant | positive scalar, seconds |

Rows represent time samples; columns represent `x` and `y`. Implementations must assert this orientation and must not accept both `2 x N` and `N x 2` implicitly.

## 4. Packet availability

Sender samples occur at

\[
t_k = k h_s,
\]

where \(h_s\) is the sample period. A packet sent at \(t_k\) becomes available at \(t_k + L\).

At simulation time \(t\), the receiver uses the latest packet satisfying

\[
t_k + L \le t.
\]

Boundary behavior at exact arrival times must be unit-tested.

## 5. Reconstruction methods

### 5.1 Zero-order hold

\[
\mathbf u_{\mathrm{ZOH},L}(t)=\mathbf r(t_k).
\]

### 5.2 Constant-velocity dead reckoning

\[
\mathbf u_{\mathrm{CV},L}(t)
=
\mathbf r(t_k)
+
(t-t_k)\dot{\mathbf r}(t_k).
\]

The extrapolation age is the current time minus the packet timestamp. It includes transport delay and the time since the latest received sample. Using only nominal delay \(L\) is a different contract and must not be substituted silently.

This method is a first-order Taylor extrapolation, not a Smith predictor.

## 6. Plant model

Each Cartesian axis uses the same independent first-order response:

\[
T\dot{\mathbf x}(t)+\mathbf x(t)=\mathbf u(t),
\]

or

\[
\dot{\mathbf x}(t)=\frac{\mathbf u(t)-\mathbf x(t)}{T}.
\]

The core implementation should not require Simulink.

## 7. Reference systems and metrics

ZOH and CV behave differently between samples even at zero transport delay. Therefore two questions and two reference policies are kept separate.

### 7.1 Task-tracking error

For direct method comparison under the same task:

\[
E_{\mathrm{track},m}(L)
=
\frac{1}{A}
\sqrt{\frac{1}{N}\sum_{i=1}^{N}
\left\|\mathbf r_i-\mathbf x_{m,L,i}\right\|^2}.
\]

This answers which method tracks the continuous target better.

### 7.2 Delay-induced error

For each method separately, compare delayed and zero-delay runs with identical sampling and reconstruction:

\[
E_{\mathrm{delay},m}(L)
=
\frac{1}{A}
\sqrt{\frac{1}{N}\sum_{i=1}^{N}
\left\|\mathbf x_{m,L,i}-\mathbf x_{m,0,i}\right\|^2}.
\]

This isolates transport delay without conflating it with each method's intrinsic sample reconstruction.

### 7.3 Improvement

The principal method-improvement ratio is based on task error:

\[
R_{\mathrm{track}}(L)
=
1-\frac{E_{\mathrm{track,CV}}(L)}
        {E_{\mathrm{track,ZOH}}(L)}.
\]

A delay-penalty ratio may also be reported, but zero denominators must be guarded explicitly.

Maximum Euclidean position error is a secondary metric. Phase lag is optional.

## 8. Evaluation window and initialization

Startup transients and absent packet history must not contaminate the measured interval.

Planned policy:

- deterministic periodic trajectories: simulate a warm-up interval and exclude it from metrics;
- warm-up duration is at least `max(2*T, L + h_s)` and may be increased after convergence checks;
- point-to-point random trajectories: hold the initial point before motion begins;
- initial plant state and receiver history are recorded in configuration.

The exact warm-up rule is a P0 design gate before metric implementation.

## 9. Deterministic trajectories

P0 trajectories:

1. Circle
   \[
   r_x=A\cos(\omega t),\quad r_y=A\sin(\omega t)
   \]

2. Lissajous 1:2
   \[
   r_x=A\sin(\omega t),\quad r_y=A\sin(2\omega t)
   \]

Generators provide position and analytic velocity. Analytic acceleration should also be available for interpretation and tests.

## 10. Dimensionless interpretation

For periodic motion, the primary dimensionless delay is

\[
\mu=\omega L.
\]

Plant dynamics introduce \(\omega T\), while packetization introduces \(\omega h_s\). Collapse by \(\mu\) alone is a hypothesis, not an assumption.

Taylor expansion suggests a constant-velocity residual proportional to

\[
\frac{L^2}{2}\ddot{\mathbf r},
\]

but the packet-age contract means practical residual also depends on sample timing.

## 11. Planned module map

```text
src/
├── default_config.m
├── validate_config.m
├── generate_trajectory.m
├── sample_trajectory.m
├── reconstruct_command.m
├── simulate_first_order_plant.m
├── simulate_case.m
├── compute_metrics.m
├── run_factorial.m
└── plot_report_figures.m
```

This is a planned boundary, not a requirement to create all files in one PR. Avoid premature fragmentation.

## 12. Open design gates

Before dependent implementation, fix:

- exact warm-up and evaluation-window policy;
- final default values and sweep ranges;
- numerical integrator and convergence threshold;
- normalization amplitude for non-periodic trajectories;
- result schema and file format;
- minimum-jerk random-trajectory contract.

Record each decision in `research/log.md`.

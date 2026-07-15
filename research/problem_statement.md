# Research problem statement

## Title

**Operating range of constant-velocity prediction under communication delay in remote robot position commands**

Japanese report title:

**遠隔操作ロボットの通信遅延に対する定速度予測補償の有効範囲**<br>
― 一次遅れ・純遅延モデルを用いた軌道追従解析 ―

## Background

A remote robot receives commands after transport delay. When target position changes continuously, the newest available packet describes a past state and creates spatial tracking error. Constant-velocity prediction extrapolates a timestamped position using velocity, but effectiveness depends on packet age and on how rapidly the velocity vector changes.

## Objective

Construct a reproducible MATLAB simulation separating packetization, fixed transport delay, command reconstruction, and a first-order robot response. Quantify when constant-velocity prediction improves tracking and identify conditions where improvement disappears or becomes negative.

## Research question

How do transport delay, trajectory speed, trajectory shape, packet sampling, and plant time constant affect:

1. continuous-target tracking error;
2. delay-induced error relative to a method-specific zero-delay baseline;
3. improvement or degradation produced by constant-velocity prediction?

Can results be organized by dimensionless quantities such as \(\omega L\), or do sampling and plant dynamics require additional ratios?

## Hypotheses

1. Tracking error increases as transport delay and motion speed increase.
2. Constant-velocity prediction reduces error when the velocity vector changes slowly over effective packet age.
3. Large acceleration caused by speed change or turning increases first-order extrapolation residual.
4. \(\omega L\) is important for periodic trajectories, but \(\omega h_s\) and \(\omega T\) may prevent single-parameter collapse.
5. CV may improve continuous-target tracking even at zero transport delay because it reconstructs motion between samples; method-specific zero-delay baselines are therefore required to isolate transport-delay effects.

These are pre-simulation hypotheses, not results.

## Compared methods

- packetized command with zero transport delay;
- delayed zero-order hold;
- delayed constant-velocity dead reckoning.

For delay isolation, each reconstruction method is evaluated at zero transport delay under identical sampling.

## Core trajectories

P0:

- circle;
- 1:2 Lissajous trajectory.

P1:

- seeded point-to-point minimum-jerk trajectories using common random numbers for paired comparison.

Human-generated input is not used because it reduces reproducibility and requires an experimental design beyond the available period.

## Model abstraction

Included:

- two-dimensional position and velocity;
- fixed-rate sender sampling;
- timestamped packets;
- fixed one-way transport delay;
- latest-available-packet selection;
- ZOH and CV reconstruction;
- axis-independent first-order plant;
- numerical integration and error metrics.

Excluded:

- human-subject performance, learning, and subjective workload;
- real network measurement;
- packet loss, jitter, and reordering;
- detailed 3D robot geometry, IK, joint limits, collision, contact, and force feedback;
- closed-loop bilateral teleoperation and passivity control;
- machine-learning prediction.

## Primary metrics

- normalized task-tracking RMSE;
- normalized method-specific delay-induced RMSE;
- maximum Euclidean position error;
- task-tracking improvement ratio.

Definitions and reference systems are fixed in `docs/architecture.md`.

## Originality and independent problem setting

Constant-velocity prediction is established and is not claimed as a new algorithm. The independent contribution is:

- asking for an operating range and degradation boundary rather than one successful case;
- replacing human input with reproducible trajectories;
- separating task error from transport-delay-induced error;
- pairing methods on identical inputs and conditions;
- attempting a dimensionless interpretation while testing where it fails;
- documenting numerical convergence and failure conditions.

## Success criterion

The project succeeds when it can reproducibly state, within the simplified model:

- how error changes across the P0 delay/speed/trajectory grid;
- where CV improves or worsens task tracking relative to ZOH;
- how much observed error is attributable to transport delay;
- whether dimensionless organization is supported;
- what limitations prevent direct generalization to a real system.

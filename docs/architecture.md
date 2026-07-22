# 設計・モデル契約

## 1. モデル化の目的

本モデルでは、packet化された位置指令、固定通信遅延、単純な予測補償、一次遅れのロボット応答の関係を分離して扱う。遅延と補償の影響を解釈しやすくするため、詳細なロボット運動学と人間の挙動は意図的に捨象する。

packet loss、jitter、feedback制御、関節空間動力学、飽和、workspace制約を暗黙に追加してはならない。

## 2. システム境界

```mermaid
flowchart LR
    R[連続目標軌道 r(t)]
    S[送信側sampling t_k]
    P[packet: t_k, r_k, v_k]
    D[固定通信遅延 L]
    A[利用可能な最新packet]
    M{指令再構成方式}
    Z[ゼロ次ホールド]
    C[定速度予測]
    U[適用指令 u_m,L(t)]
    Gz[一次遅れplant（ZOH）]
    Gc[一次遅れplant（CV）]
    Gr[一次遅れplant（reference）]
    X[plant出力 x_m,L(t)]
    B[参照出力 x_ref(t)]
    E[評価指標]

    R --> S --> P --> D --> A --> M
    M --> Z --> Gz --> X --> E
    M --> C --> Gc --> X --> E
    R --> Gr --> B --> E
```

## 3. 信号と予定データ契約

位置と速度はすべて2次元直交座標量とする。

| 記号 | 意味 | MATLAB表現 |
|---|---|---|
| \(t\) | 積分時刻 | `N x 1 double`、s |
| \(\mathbf r(t)\) | 連続目標位置 | `N x 2 double`、m |
| \(\dot{\mathbf r}(t)\) | 目標速度 | `N x 2 double`、m/s |
| \(t_k\) | 送信sampling時刻 | scalarまたは`K x 1 double`、s |
| \(\mathbf r_k\) | sampling位置 | `K x 2 double` |
| \(\mathbf v_k\) | sampling速度 | `K x 2 double` |
| \(L\) | 固定片道通信遅延 | scalar、s |
| \(\mathbf u_{m,L}(t)\) | 再構成指令 | `N x 2 double` |
| \(\mathbf x_{m,L}(t)\) | plant出力 | `N x 2 double` |
| \(T\) | 一次遅れ時定数 | 正のscalar、s |

行は時刻sample、列は`x`、`y`を表す。実装はこの向きを検証し、`2 x N`と`N x 2`を暗黙に両方受理しない。

## 4. packetの利用可能条件

送信側のsampling時刻を

\[
t_k = k h_s
\]

とする。\(h_s\)はsampling周期であり、\(t_k\)に送信したpacketは\(t_k+L\)で利用可能になる。

時刻\(t\)で受信側が用いるのは、

\[
t_k+L\leq t
\]

を満たす最新packetである。到着時刻と完全に一致する境界挙動をunit testで固定する。

## 5. 指令再構成方式

### 5.1 ゼロ次ホールド

\[
\mathbf u_{\mathrm{ZOH},L}(t)=\mathbf r(t_k)
\]

### 5.2 定速度デッドレコニング

\[
\mathbf u_{\mathrm{CV},L}(t)
=
\mathbf r(t_k)+(t-t_k)\dot{\mathbf r}(t_k)
\]

外挿時間は現在時刻からpacket timestampを引いた値である。通信遅延だけでなく、最新packetを受信してからの経過時間も含む。名目遅延\(L\)だけを使用する方式へ暗黙に置き換えない。

本方式は一次Taylor外挿であり、Smith predictorではない。

## 6. plantモデル

各直交軸に同一の独立した一次遅れ応答を適用する。

\[
T\dot{\mathbf x}(t)+\mathbf x(t)=\mathbf u(t)
\]

すなわち、

\[
\dot{\mathbf x}(t)=\frac{\mathbf u(t)-\mathbf x(t)}{T}
\]

とする。中心実装はSimulinkを必須としない。

## 7. 参照系と評価指標

ZOH、CV、referenceは同じ`first_order_2d.slx`をModel Referenceとして使用する。referenceだけは通信Model Referenceを通さず、連続目標位置を直接入力する。したがって、評価ではplant自身の追従応答と通信・指令再構成の差を同じsimulation内で比較できる。

### 7.1 評価区間

基本周期は`period_s = 2*pi/omega`とする。標準設定は`total_cycles=10`、`warmup_cycles=2`であり、nominal境界は次で定義する。

```text
nominal_start_s = warmup_cycles * period_s
nominal_end_s   = total_cycles * period_s
```

simulation durationは`nominal_end_s`を覆う最小のfixed-grid endpoint、すなわち`ceil(nominal_end_s / dt) * dt`（整数近傍だけmachine precision toleranceで補正）とする。metrics sampleはnominal start以上の最初のsampleからnominal end以下の最後のsampleまでである。`evaluation`はnominal境界と実sample境界、sample count、logical column maskを公開する。必要区間を覆わないsimulationや空区間はstable errorで拒否する。

### 7.2 追従誤差

各sampleの二次元誤差を

\[
\mathbf e_{m,i}=\mathbf x_{m,i}-\mathbf x_{ref,i},\qquad
e_{m,i}=\|\mathbf e_{m,i}\|_2
\]

とする。評価区間内で次を計算する。

\[
\mathrm{rmse}_m=\sqrt{\frac{1}{N}\sum_i
\left\|\mathbf x_{m,i}-\mathbf x_{ref,i}\right\|_2^2},
\qquad
\mathrm{nrmse}_m=\frac{\mathrm{rmse}_m}{A}
\]

公開fieldは`rmse_zoh_m`、`rmse_cv_m`、`nrmse_zoh`、`nrmse_cv`、`max_error_zoh_m`、`max_error_cv_m`、`performance_ratio`、`improvement_percent`である。`A`はtrajectory amplitude [m]である。RMSE、最大誤差、mean packet ageは同じ`evaluation.mask`のsample集合から計算する。

`performance_ratio = rmse_cv_m / rmse_zoh_m`、`improvement_percent = (1-performance_ratio)*100`とする。評価mask内の`packet_valid`は全sampleでtrueでなければならない。全件falseは`teleopDelay:NoValidPacketInEvaluation`、true/false混在は`teleopDelay:IncompletePacketHistoryInEvaluation`で拒否し、invalid sampleをmetricsから除外して評価区間を短縮しない。`mean_packet_age_s`はこの全validな評価sample集合から求め、評価対象の`packet_age_s`は有限かつ非負でなければならない。`omega_delay`、`omega_mean_packet_age`、`omega_time_constant`、`omega_sample_period`を併せて公開する。

### 7.3 zero denominator contract

zero判定のtoleranceは`32*eps(max(1, abs(rmse_zoh_m), abs(rmse_cv_m)))`というmachine precision由来の値であり、固定の大きなthresholdではない。ZOHとCVのRMSEがともにtolerance以下なら`performance_ratio=1`、`improvement_percent=0`とする。ZOHだけがtolerance以下でCVが超える場合は、NaN/Infを返さず`teleopDelay:UndefinedPerformanceRatio`で拒否する。

## 8. 評価区間と初期化

起動過渡とpacket履歴不足を評価区間へ混入させない。

確定した契約:

- deterministic周期軌道では`warmup_cycles`周期を評価から除外する。
- 標準設定は全10周期、最初の2周期を除外する。
- 起動時のplant初期状態はzero、最初のpacket到着前は`packet_valid=false`とし、過去packetの事前投入は行わない。
- `evaluation.nominal_*`と`evaluation.sample_*`を分離して記録する。

### 8.1 logging time alignment

Datasetの8要素すべてについて`Values.Time`を取得する。最初に取得したcanonical time vectorと各要素を、`N x 1 double`、有限、厳密単調増加、shape一致として検証し、値の比較には`32*eps(max(1, abs(t)))`のmachine precision由来toleranceだけを使う。不一致は`teleopDelay:MisalignedLoggedSignal`、個別time vectorのshape・有限性・単調性違反は`teleopDelay:InvalidLoggedTime`で拒否する。data配列をrow対応で扱うのはこの検証後に限る。

## 9. 決定論的軌道

P0軌道は次の2種類とする。

1. 円軌道

   \[
   r_x=A\cos(\omega t),\quad r_y=A\sin(\omega t)
   \]

2. 1:2 Lissajous軌道

   \[
   r_x=A\sin(\omega t),\quad r_y=A\sin(2\omega t)
   \]

generatorは位置と解析速度を返す。解釈とテストに使用する解析加速度も取得可能にする。

## 10. 無次元量による解釈

周期運動の主要な無次元遅延を、

\[
\mu=\omega L
\]

とする。plant動特性は\(\omega T\)、packet化は\(\omega h_s\)を導入するため、\(\mu\)だけで結果がcollapseすることは仮説であり前提ではない。

Taylor展開から、定速度予測の残差は概ね、

\[
\frac{L^2}{2}\ddot{\mathbf r}
\]

に比例すると予想される。ただし、実際のpacket ageはsampling timingにも依存する。

## 11. module構成

```text
src/+teleopdelay/
├── +app/main.m
├── +config/{default_config,validate_config}.m
├── +metrics/{grid_aligned_duration,build_evaluation_window,tracking_metrics}.m
├── +timegrid/create.m
├── +trajectory/{generate,circle,lissajous_1_2}.m
└── +simulink/
    ├── {model_paths,build_models,validate_models}.m
    ├── {create_simulation_input,run_case}.m
    ├── validate_logging_names.m
    └── validate_logged_time_alignment.m
```

`run_project.m`だけをrepository rootのpublic entry pointとする。`src/`は`run_project`の実行中だけpathへ追加し、呼出元のpathへ戻す。

## 12. 残る設計gate

依存する実装へ進む前に、次を確定する。

- default値とsweep範囲
- 数値積分法と収束判定threshold
- 非周期軌道の正規化振幅
- 結果の保存形式
- 最小ジャーク乱数軌道の契約

各判断を`research/log.md`へ追記する。

## 13. Issue #2で成立させた基盤

Issue #2では、決定論的な軌道生成と、通信遅延を含まない最小plant接続までを実装した。通信packet、ZOH/CV、評価指標、作図はこの時点の基盤には含めなかった。

```text
src/+teleopdelay/
├── +app/main.m
├── +config/{default_config,validate_config}.m
├── +timegrid/create.m
├── +trajectory/{generate,circle,lissajous_1_2}.m
└── +simulink/{model_paths,build_models,create_simulation_input,run_case}.m
```

MATLAB側は設定、固定時間grid、軌道、`Simulink.SimulationInput`、simulation実行を担当し、Simulink側はplantとtop-level接続を担当した。

| model | interface |
|---|---|
| `models/plant/first_order_2d.slx` | `command_xy_m`（2要素、double、m）を受け、`position_xy_m`（2要素、double、m）を返す。`time_constant_s`をmodel argumentとして公開する。 |
| `models/system/teleop_delay_system.slx` | MATLAB軌道の位置を外部入力として受け、`first_order_2d.slx`をModel Referenceで呼び出し、`command_xy_m`と`position_xy_m`をDataset loggingする。 |

top-level modelはplant内部のblockやstateへ依存しない。Inport/Outportはdimension、type、unit、`SampleTime=-1`（inherited）を固定し、外部入力は固定時間gridの`timeseries`として与える。plantはState-Space blockのcompiled sample time `[0 0]`でcontinuous stateを持ち、top-level solverは`ode4`とした。通信packet、固定通信遅延、ZOH/CV指令再構成、metrics、作図は後続実装の責務とした。

`time_constant_s`はplant model workspaceの`Simulink.Parameter`として定義し、referenced modelの`ParameterArgumentNames`へ登録する。top-levelのModel blockはinstance parameterとして同名のmodel argumentを受け、`create_simulation_input`が`Workspace=teleop_delay_system`を指定してcaseごとの値を`SimulationInput`へ設定する。base workspaceへは依存しない。

## 14. Issue #5 サンプル値通信の実装契約

`models/communication/sampled_communication.slx`は、連続目標位置`position_xy_m`（2要素、double、m）と解析速度`velocity_mps`（2要素、double、m/s）を入力とする独立Model Referenceである。model argumentsは`sample_period_s`（s）と`delay_s`（s）であり、内部ClockとMATLAB Functionブロックがsampling、packet timestamp・position・velocityの一体保持、到着判定、最新packet選択を所有する。送信時刻`t_k`のpacketは`t_k+delay_s<=t`で利用可能とする。

通信modelは同じ選択packetから、`zoh_command_xy_m`、`cv_command_xy_m`、`packet_timestamp_s`、`packet_age_s`、`packet_valid`を出力する。CVの外挿時間は`current_time-packet_timestamp_s`である。最初のpacket到着前はvalidity=false、timestamp=0、age=0、ZOH/CV=[0,0]とする。

top-level `teleop_delay_system.slx`は通信出力をZOH/CVの2つの`first_order_2d.slx` instanceへ分岐し、連続目標位置を3つ目のreference instanceへ直接入力する。Dataset elementは`zoh_command_xy_m`、`cv_command_xy_m`、`zoh_position_xy_m`、`cv_position_xy_m`、`reference_position_xy_m`、`packet_timestamp_s`、`packet_age_s`、`packet_valid`の8要素を名前で取得し、順序には依存しない。MATLAB側の公開schemaは`config`、`trajectory`、`simulation`、`evaluation`であり、`simulation`内に同名の`N x 1`または`N x 2`配列を公開する。旧`command_xy_m`、`position_xy_m` aliasは追加しない。

`sample_period_s / fixed_step_s`は正の整数でなければならず、`simulation.fixed_step`は`simulation.dt`と一致しなければならない。これは現在の固定step数値モデルがsolver step内で過去の軌道値を補間せずsamplingする制限を明示的にguardするためである。`sample_period_s < fixed_step_s`、非整数比、buffer容量を超える遅延はstable error identifierで拒否する。通信packet buffer容量は1024で、必要履歴数は`ceil(delay_s / sample_period_s) + 1`以下に制限する。

## 15. Issue #7 評価schema

`config.evaluation.total_cycles`と`config.evaluation.warmup_cycles`はfinite real scalarの非負整数で、`total_cycles > 0`かつ`warmup_cycles < total_cycles`を満たす。標準値は10と2である。`evaluation`は`period_s`、周期数、nominal/sample境界、`sample_count`、logical columnの`mask`を含み、そこへmetrics fieldを追加する。metrics実装はconfig、trajectory、simulationの公開schemaだけを受け取り、Simulink model構築・保存・block pathへ依存しない。

参照plant、ZOH plant、CV plantは同じtracked model、同じ`time_constant_s` mapping、同じsolver/fixed step、zero初期状態を使う。reference outputは`reference_position_xy_m`（`N x 2 double`、m、inherited sample time）である。

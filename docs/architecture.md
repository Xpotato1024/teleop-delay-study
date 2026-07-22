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
    G[一次遅れplant]
    X[plant出力 x_m,L(t)]
    B[方式固有のゼロ遅延基準 x_m,0(t)]
    E[評価指標]

    R --> S --> P --> D --> A --> M
    M --> Z --> U
    M --> C --> U
    U --> G --> X --> E
    R --> E
    B --> E
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

ZOHとCVは、通信遅延がゼロでもsample間の挙動が異なる。このため、総追従性能と通信遅延だけの影響を別の参照系で評価する。

### 7.1 総追従誤差

同一課題における方式間比較には、

\[
E_{\mathrm{track},m}(L)
=
\frac{1}{A}
\sqrt{\frac{1}{N}\sum_{i=1}^{N}
\left\|\mathbf r_i-\mathbf x_{m,L,i}\right\|^2}
\]

を用いる。連続目標軌道へどの方式が良く追従するかを表す。

### 7.2 通信遅延起因誤差

方式ごとに、同じsampling・再構成を用いた遅延ありとゼロ遅延の出力を比較する。

\[
E_{\mathrm{delay},m}(L)
=
\frac{1}{A}
\sqrt{\frac{1}{N}\sum_{i=1}^{N}
\left\|\mathbf x_{m,L,i}-\mathbf x_{m,0,i}\right\|^2}
\]

これにより、方式固有のsample間再構成誤差と通信遅延の影響を混同しない。

### 7.3 改善率

主たる方式改善率は総追従誤差から、

\[
R_{\mathrm{track}}(L)
=
1-\frac{E_{\mathrm{track,CV}}(L)}
        {E_{\mathrm{track,ZOH}}(L)}
\]

とする。通信遅延penaltyの比も補助的に示せるが、分母がゼロとなる場合を明示的にguardする。

最大Euclidean位置誤差を副指標とする。位相遅れは任意の診断指標とする。

## 8. 評価区間と初期化

起動過渡とpacket履歴不足を評価区間へ混入させない。

予定方針:

- 決定論的周期軌道ではwarm-up区間を計算し、評価から除外する。
- warm-upは少なくとも`max(2*T, L + h_s)`とし、収束確認後に延長できる。
- 通過点間の乱数軌道では、運動開始前に初期点を保持する。
- plant初期状態と受信履歴を設定へ記録する。

厳密なwarm-up規則は、評価指標実装前に確定するP0設計gateとする。

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
├── +timegrid/create.m
├── +trajectory/{generate,circle,lissajous_1_2}.m
└── +simulink/
    ├── {model_paths,build_models,validate_models}.m
    ├── {create_simulation_input,run_case}.m
    └── validate_logging_names.m
```

`run_project.m`だけをrepository rootのpublic entry pointとする。`src/`は`run_project`の実行中だけpathへ追加し、呼出元のpathへ戻す。

## 12. 未確定の設計gate

依存する実装へ進む前に、次を確定する。

- warm-upと評価区間の厳密な規則
- default値とsweep範囲
- 数値積分法と収束判定threshold
- 非周期軌道の正規化振幅
- 結果schemaと保存形式
- 最小ジャーク乱数軌道の契約

各判断を`research/log.md`へ追記する。

## 13. Issue #2で成立させた基盤

Issue #2では、上記の研究モデル全体のうち、決定論的な軌道生成と遅延を含まない最小plant接続までを実装した。

```text
src/+teleopdelay/
├── +app/main.m
├── +config/{default_config,validate_config}.m
├── +timegrid/create.m
├── +trajectory/{generate,circle,lissajous_1_2}.m
└── +simulink/{model_paths,build_models,create_simulation_input,run_case}.m
```

MATLAB側は設定、固定時間grid、軌道、`Simulink.SimulationInput`、simulation実行、出力schemaを担当する。Simulink側は次の2つのmodelを担当する。

| model | interface |
|---|---|
| `models/plant/first_order_2d.slx` | `command_xy_m`（2要素、double、m）を受け、`position_xy_m`（2要素、double、m）を返す。`time_constant_s`をmodel argumentとして公開する。 |
| `models/communication/sampled_communication.slx` | `position_xy_m`と`velocity_mps`を受け、`sample_period_s`と`delay_s`に基づくpacket、ZOH/CV command、timestamp・age・validityを返す。 |
| `models/system/teleop_delay_system.slx` | MATLAB軌道の位置・解析速度を外部入力として受け、通信Model Referenceと2つの`first_order_2d.slx`を参照し、7要素schemaをDataset loggingする。 |

top-level modelはplant内部のblockやstateへ依存しない。Inport/Outportはdimension、type、unit、`SampleTime=-1`（inherited）を固定し、外部入力は固定時間gridの`timeseries`として与える。plantはState-Space blockのcompiled sample time `[0 0]`でcontinuous stateを持ち、top-level solverは`ode4`とする。実行時の`FixedStep`は`config.simulation.fixed_step`から`SimulationInput`へ渡す。通信modelはpacket sampling、固定遅延、ZOH、CV、packet diagnosticsを所有し、metricsと作図は未実装である。

`time_constant_s`はplant model workspaceの`Simulink.Parameter`として定義し、referenced modelの`ParameterArgumentNames`へ登録する。top-levelのModel blockはinstance parameterとして同名のmodel argumentを受け、`create_simulation_input`が`Workspace=teleop_delay_system`を指定してcaseごとの値を`SimulationInput`へ設定する。base workspaceや`.slx`の再生成には依存しない。

model lifecycleはbuilderとruntimeを分離する。`build_models`は明示的なmodel保守操作であり、`.slx`を書き換える。`app.main`は`validate_models`で追跡済みmodelの存在、Model Reference接続、interface metadata、model updateを確認するだけで、通常実行中にmodelを保存しない。loggingはDataset elementの完全一致名`zoh_command_xy_m`、`cv_command_xy_m`、`zoh_position_xy_m`、`cv_position_xy_m`、`packet_timestamp_s`、`packet_age_s`、`packet_valid`で取得し、順序に依存しない。

実装済みの検証は、package・model存在、explicit builder、通信Model Reference接続、model load/update、headless simulation、entry point 3形式、circle/Lissajous、output shape・finite値、named logging、path復元、open model cleanup、read-only相当model fileでのruntime、`checkcode`、unit/model/integration testである。軌道の解析値、周期性、微分一致、plant解析解、solver収束性はfollow-upで検証した。

## 14. Issue #5 サンプル値通信の実装契約

`models/communication/sampled_communication.slx`は、連続目標位置`position_xy_m`（2要素、double、m）と解析速度`velocity_mps`（2要素、double、m/s）を入力とする独立Model Referenceである。model argumentsは`sample_period_s`（s）と`delay_s`（s）であり、内部ClockとMATLAB Functionブロックがsampling、packet timestamp・position・velocityの一体保持、到着判定、最新packet選択を所有する。送信時刻`t_k`のpacketは`t_k+delay_s<=t`で利用可能とする。

通信modelは同じ選択packetから、`zoh_command_xy_m`、`cv_command_xy_m`、`packet_timestamp_s`、`packet_age_s`、`packet_valid`を出力する。CVの外挿時間は`current_time-packet_timestamp_s`である。最初のpacket到着前はvalidity=false、timestamp=0、age=0、ZOH/CV=[0,0]とする。

top-level `teleop_delay_system.slx`は通信出力を2つの`first_order_2d.slx` instanceへ分岐する。Dataset elementは`zoh_command_xy_m`、`cv_command_xy_m`、`zoh_position_xy_m`、`cv_position_xy_m`、`packet_timestamp_s`、`packet_age_s`、`packet_valid`の名前で取得し、順序には依存しない。MATLAB側の公開schemaは`config`、`trajectory`、`simulation`を維持し、`simulation`内に同名の`N x 1`または`N x 2`配列を公開する。旧`command_xy_m`、`position_xy_m` aliasは追加しない。

`sample_period_s / fixed_step_s`は正の整数でなければならず、`simulation.fixed_step`は`simulation.dt`と一致しなければならない。これは現在の固定step数値モデルがsolver step内で過去の軌道値を補間せずsamplingする制限を明示的にguardするためである。`sample_period_s < fixed_step_s`、非整数比、buffer容量を超える遅延はstable error identifierで拒否する。通信packet buffer容量は1024で、必要履歴数は`ceil(delay_s / sample_period_s) + 1`以下に制限する。

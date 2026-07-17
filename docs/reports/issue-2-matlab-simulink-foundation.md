# Issue #2 MATLAB/Simulink基盤 実装・検証報告

## 目的

MATLABとSimulinkの責務を分離し、決定論的軌道を外部入力としてModel Referenceの一次遅れplantへ接続する基盤を実装・検証した。通信遅延、packet sampling、ZOH、CV、補償効果は対象外である。

## 実装内容

- `src/+teleopdelay/`へ設定、時間grid、軌道、Simulink adapter、app入口を移行し、旧sourceを削除した。
- `circle`と`lissajous_1_2`が位置、速度、加速度を`N x 2`で返すようにした。
- `duration / dt`をmachine precisionとstep scaleに基づいて判定し、非整数stepを拒否する固定時間gridを実装した。
- `models/plant/first_order_2d.slx`を一次遅れの独立Model Referenceとして生成し、入力・出力をdimension 2、double、unit mに固定した。
- `models/system/teleop_delay_system.slx`がplantをModel blockで参照し、`command_xy_m`と`position_xy_m`を名前付きDataset elementとしてloggingするようにした。

## model lifecycleと実行時parameter

`build_models`は明示的なmodel保守操作に限定した。実行commandは次のとおりである。

```powershell
matlab -batch "addpath('src'); c=teleopdelay.config.default_config(); p=teleopdelay.simulink.model_paths(pwd); teleopdelay.simulink.build_models(p,c)"
```

`teleopdelay.app.main`は通常実行時にbuilderを呼ばず、追跡済み`.slx`の存在、Model Reference接続、interface metadata、model updateを確認してからsimulationする。modelがない場合は`teleopDelay:MissingModel`で停止する。通常の`run_project`三形式、unit/model/integration test、smoke testの前後でmodelを保存せず、plant/systemのSHA-256は次の値で一致した。

| model | SHA-256 |
|---|---|
| `models/plant/first_order_2d.slx` | `B2B7DB8042D7CCE278CF4916EA674905ED0475C4BEBC32048D85F4FCE5A121BB` |
| `models/system/teleop_delay_system.slx` | `97B86A2F4865C3BB10F739E9D3FBE7F413A0A59A9917E593FE9F1CC9F5CA17C2` |

plantの`time_constant_s`はmodel workspaceの`Simulink.Parameter`として定義し、referenced modelのmodel argumentとして公開した。top-level Model blockのinstance parameterへ同名argumentを渡し、`SimulationInput.setVariable`に`Workspace='teleop_delay_system'`を指定してcaseごとの値を設定した。このAPI選択はR2025bのModel Reference parameterization仕様と実行結果で確認した。[MathWorksのmodel argument例](https://www.mathworks.com/help/simulink/ug/parameterize-referenced-models-example.html)、[SimulationInput.setVariable](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html)

`time_constant_s=0.1`と`0.4`をbuilder再実行なしで連続実行し、出力差分`0.4680`を得た。base workspaceへのassignは行っていない。

## interfaceとlogging contract

plant境界は次で固定した。

| signal | dimension | type | unit |
|---|---:|---|---|
| `command_xy_m` | 2 | double | m |
| `position_xy_m` | 2 | double | m |

plantはState-Space blockのcompiled sample time `[0 0]`でcontinuous stateを持ち、top-level solverは`ode4`である。plant Inport/Outportとtop-level Inport/Outportの`SampleTime`は実環境の`get_param`で`-1`を取得した。外部入力は固定時間gridの`timeseries`であり、solverの`FixedStep`はconfigから`SimulationInput`へ渡す。top-levelはplant内部block pathやstateへ依存しない。loggingはDataset element名を完全一致で検証し、duplicateまたはmissingを拒否したため、Outport順序に依存しない。

configの`trajectory.type`と`simulation.solver`はnonmissing string scalarだけを受理し、それぞれ`circle`/`lissajous_1_2`、`ode4`の完全一致を要求する。default configがこの型契約を満たしたままtrajectory dispatcherへ渡ることもunit testで確認した。char vector、string array、case違い、missing fieldは拒否する。

## MATLAB unit validation

- config: 3 tests。string scalar型契約、完全一致、missing field、default configからdispatcherへの接続を確認した。
- time grid: 4 tests。endpoint、column shape、zero duration、非整数step、zero/negative/NaN/Inf、不整合を隠すendpoint上書きの拒否を確認した。
- trajectory: 8 tests。circleとLissajousの`t=0`、周期、shape、finite値、解析微分、有限差分、dispatcherのtype/time validationを確認した。

unit test合計は15件である。

有限差分の許容値は、中心差分の打切り誤差とdoubleの丸め誤差を考慮した。circleは速度・加速度`1e-7`、Lissajousは速度`2e-7`・加速度`5e-7`とした。

## plant model validation

定値入力について、初期値0の解析解

```text
x(t) = u + (x0 - u) exp(-t / T)
```

と比較した。x/y両軸、zero input、nonzero constant input、初期状態、異なる時定数、Model Reference単体、top-level経由を確認した。解析解との差分thresholdは`1e-5`とし、既定の`ode4`相当設定と`dt=0.01 s`で十分小さいことを確認した。

測定値は`T=0.2 s`、constant input `[1, 0.5]`、duration `0.2 s`で、基準step `0.01 s`の最大誤差`1.9976097331841913e-08`、step `0.005 s`の最大誤差`1.2227420187471694e-09`、誤差比`0.061210255358443696`であった。step半減で誤差は減少した。これはsolver設定の受入確認であり、solver最適化や通信遅延の科学的評価ではない。

## integration validation

integration test 4件を通過した。無出力`run_project()`、一出力、二出力の三形式、circle/Lissajous output schema、named logging、missing modelの明示的拒否、read-only相当model fileでのruntime、model hash不変、base workspace非依存、path完全復元、test順序非依存を確認した。smoke testは最小起動確認に留め、解析検証はunit/model testへ分離した。

## 検証環境と結果

- MATLAB: R2025b Update 5、version `25.2.0.3177638`
- Simulink: R2025b Update 5
- explicit model builder: 成功
- unit tests: 15件通過
- model tests: 9件通過
- integration tests: 4件通過
- `smoke_test`: 通過
- `checkcode -id`: 問題なし
- `git diff --check`: 通過
- MATLAB path復元、open model cleanup、headless simulation: 通過

## 未実施・対象外

通信遅延、packet sampling、ZOH、CV、metrics、補償効果、実ネットワーク、科学的な通信遅延結果は本報告の対象外である。今回の解析検証は決定論的軌道の式、Model Reference plantの実行時契約、定値入力の解析解、solver step半減に限定した。

## GitHub状態

- Issue: #2 OPEN
- branch: `codex/2-matlab-simulink-implementation`
- draft PR: #4
- 最終監査fix commit SHA: `a4c5080`（full SHAはGit履歴とPR #4で確認可能）

PR本文では`Refs #2`を維持する。`Closes #2`への変更、Ready化、merge、Issue closeは行わない。

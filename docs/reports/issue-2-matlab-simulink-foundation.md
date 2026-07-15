# Issue #2 MATLAB/Simulink基盤 実装報告

## 目的

MATLABとSimulinkの責務を分離し、決定論的軌道を外部入力としてModel Referenceの一次遅れplantへ接続する最小基盤を実装した。通信遅延と補償方式は含めない。

## 実装内容

- `src/+teleopdelay/`へ設定、時間grid、軌道、Simulink adapter、app入口を移行した。
- `circle`と`lissajous_1_2`が位置、速度、加速度を`N x 2`で返すようにした。
- `duration / dt`が整数stepでない時間gridを拒否するようにした。
- `models/plant/first_order_2d.slx`を一次遅れの独立Model Referenceとして生成した。
- `models/system/teleop_delay_system.slx`がplantをModel blockで参照し、外部軌道、command、plant positionをDataset loggingするようにした。
- `run_project`が設定、軌道、SimulationInput、headless simulation、出力schemaを結線するようにした。

## 検証環境とコマンド

- MATLAB: R2025b Update 5、version `25.2.0.3177638`
- Simulink: MATLABと同じR2025b Update 5で利用可能
- `matlab -batch "status=run_project(); assert(status==0)"`
- `matlab -batch "addpath('tests'); c=onCleanup(@() rmpath('tests')); status=smoke_test(); assert(status==0)"`
- package全体の`checkcode -id`
- `git diff --check`

## 検証結果

`smoke_test passed.`を確認した。packageとmodelの存在、旧sourceの削除、builder、Model Reference接続、model update、headless simulation、`run_project`の3形式、circle/Lissajous、output field・shape・finite値、logging、MATLAB path復元、open model cleanupを確認した。`checkcode`は問題を報告しなかった。

## 未実施

軌道の解析値、周期性、解析微分との一致、plant解析解、solver収束性、通信遅延、packet sampling、ZOH、CV、metrics、科学的効果の評価は未実施である。

## GitHub状態

Issue #2を継続し、`codex/2-matlab-simulink-implementation`を使用する。draft PR作成後に番号とcommit SHAを追記する。IssueはOPENのままとし、`Closes #2`、Ready化、merge、Issue closeは行わない。

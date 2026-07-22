# Issue #7 実装報告：遅延なし参照系・評価区間・追従誤差指標

## 概要

Issue #5の通信・ZOH/CV・plant経路へ、通信を通さないreference plant、固定grid上の評価window、pure MATLABのtracking metricsを追加した。builderを正本として、builderと3つのtracked modelを同期する。

## 実装契約

- `teleop_delay_system.slx`は`position_xy_m`をreference plantへ直接接続し、ZOH/CV/referenceの3 instanceで同じ`first_order_2d.slx`を参照する。
- 3 instanceのmodel argumentは同名`time_constant_s` mapping、dimensionは2、typeはdouble、unitはm、sample timeはinherited、初期状態は既存plantのzeroを維持する。
- Dataset loggingは`zoh_command_xy_m`、`cv_command_xy_m`、`zoh_position_xy_m`、`cv_position_xy_m`、`reference_position_xy_m`、`packet_timestamp_s`、`packet_age_s`、`packet_valid`の8要素で、element名を完全一致で取得し順序へ依存しない。
- 標準評価は10周期のうち最初の2周期を除外する。nominal境界と実sample境界を`output.evaluation`へ記録し、duration不足・空window・valid packetなしはstable errorで拒否する。評価mask内は全sampleで`packet_valid=true`を要求し、混在は`teleopDelay:IncompletePacketHistoryInEvaluation`でfail-closedに拒否する。評価対象のpacket ageは有限かつ非負でなければならず、違反は`teleopDelay:InvalidPacketAgeInEvaluation`で拒否する。
- RMSE、NRMSE、最大誤差、性能比、改善率、同じ全valid評価sample集合からの平均age、および4つの無次元量をpure MATLABで計算する。
- `run_case`は8つのDataset elementの`Values.Time`をすべて取得し、canonical vectorとのshape、有限性、厳密単調増加性、一致をdata配列の対応付け前に検証する。不一致は`teleopDelay:MisalignedLoggedSignal`、個別time vectorの不正は`teleopDelay:InvalidLoggedTime`で拒否する。
- zero denominatorはmachine precision由来の`32*eps` toleranceで判定する。両RMSEがzeroなら性能比1・改善率0、ZOHだけzeroなら`teleopDelay:UndefinedPerformanceRatio`で拒否する。

## 検証

実行環境はMATLAB R2025b Update 5（`25.2.0.3177638`）、Simulinkである。

focused metrics unitは`test_metrics.m` 9件、time alignment unit 3件、合計12/12で成功した。reference/model focused testは2件で、いずれも成功した。analytic fixtureは`dt=sample_period=0.01 s`、`delay=0`、`T=0.2 s`、円軌道、duration `0.20 s`で実測し、ZOH command差`0`、CV command差`2.7755575615628914e-17`、reference解析解差`5.24408451829661e-06`、ZOH/reference plant差`0.00208928851916447`、CV/reference plant差`1.044847777553759e-05`を得た。fixtureのtoleranceは順に`1e-9`、`1e-9`、`1e-5`、`3e-3`、`2e-5`とした。前二つはdouble/logging一致、後三つはsolverとcontinuous external-input interpolation対packet reconstructionの差を根拠とする。

標準`run_project()`の実測では、duration `62.840000000000003 s`、period `6.2831853071795862 s`、nominal区間 `[12.566370614359172, 62.831853071795862] s`、実sample区間 `[12.57, 62.829999999999998] s`、sample count `5027`となった。追加した固定grid fixtureでは、circleと`lissajous_1_2`の双方でperiod `1 s`、nominal `[1, 2] s`、sample `[1, 2] s`、mask index `11:21`、sample count `11`となった。full unitは27/27、full modelは各model fileの分割実行で15/15、full integrationは4/4、smokeは成功し、全src 18 filesの`checkcode -id`は0件であった。一括model suiteの180秒上限timeoutは成功扱いにせず、分割実行の結果を採用した。

runtime前後のtracked model hashは変化せず、最終hashは次のとおりである。

| model | SHA-256 |
|---|---|
| `models/plant/first_order_2d.slx` | `7F64F14BBA907D96A26CAAE622A91E6A92B7A0F915B8009F39EF1A47E3C338C6` |
| `models/communication/sampled_communication.slx` | `E9EF1A331C275DC6117DE1B7B6A2786745541EC71EB3D3BA5DF9DCFE14776417` |
| `models/system/teleop_delay_system.slx` | `8DE4EFE52DCADA1FE8202519C08C1CDC9A893307BFE59E7E4DC20718E866F5DB` |

final runではMATLAB path完全復元、3 model close、reference output `6285 x 2` finite、base workspaceの`time_constant_s`/`sample_period_s`/`delay_s`非残留を確認した。追加のintegrationでは8要素すべての`Values.Time`一致、smokeとrun_project三形式、read-only runtimeを再確認した。

## 未実施範囲

Issue #8のparameter sweep、CSV/MAT保存、figure・heatmap・境界解析、random/minimum-jerk軌道、packet loss・jitter・順序入替え、実ネットワーク、plant fidelity・詳細運動学は実装していない。

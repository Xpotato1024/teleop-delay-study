# Issue #5 実装報告

## 結果

連続目標位置・解析速度を独立した通信Model Referenceへ入力し、固定sampling・固定遅延・最新packet選択・ZOH/CV再構成を実装した。ZOH/CVは同じpacket timestamp、sampled position、sampled velocity、validityを共有する。top-level modelでは2方式を同一仕様の`first_order_2d.slx`へ接続し、1回のsimulationから指令、plant出力、packet diagnosticsを取得する。

## Model interface

| model / signal | dimension | type | unit |
|---|---:|---|---|
| `sampled_communication/position_xy_m` | 2 | double | m |
| `sampled_communication/velocity_mps` | 2 | double | m/s |
| `sample_period_s` | scalar | double | s |
| `delay_s` | scalar | double | s |
| `zoh_command_xy_m`, `cv_command_xy_m` | 2 | double | m |
| `packet_timestamp_s`, `packet_age_s` | scalar | double | s |
| `packet_valid` | scalar | logical | - |

利用可能packetは`t_k+delay_s<=t`を満たすtimestamp最大のpacketである。CVは`r_k+(t-t_k)v_k`を使う。最初のpacket到着前は`false, 0, 0, [0,0], [0,0]`とする。

## 変更

- `build_models`をplant、通信、top-levelのprogrammatic builderへ拡張した。
- `models/communication/sampled_communication.slx`を追加した。
- `create_simulation_input`で位置と解析速度をDataset外部入力としてcase単位に渡すようにした。
- `run_case`で名前付きDataset elementを順序非依存でschemaへ変換するようにした。
- `tests/models/test_sampled_communication.m`へL=0、整数・非整数遅延比、exact boundary、一定速度、ZOH保持、startup、不正値fixtureを追加した。
- 旧`command_xy_m`、`position_xy_m`のsimulation aliasは残していない。

## 検証

MATLAB R2025b Update 5 / Simulinkで、explicit builder、focused communication model tests 3件、unit 15件、model 12件、integration 4件、smoke testを実行し、全件成功した。`run_project`の無出力・一出力・二出力、path復元、model cleanup、base workspace非残留、runtime model hash不変もintegration/smokeで確認した。

未実施範囲はIssueの指定どおり、RMSE・改善率・parameter sweep・結果保存・作図・random軌道・packet loss/jitter・実ネットワークである。

## ChatGPT-side review対応

- P1-1: Preferred方式ではなくminimal alternativeを採用した。`sample_period_s / fixed_step_s`を正の整数、`simulation.fixed_step == simulation.dt`、`sample_period_s >= fixed_step_s`としてconfigで拒否する。これによりpacket timestampとsampling時のposition・velocityの対応を固定step境界に限定する。
- P2-1: `research/log.md`の既存P2 entry本文を見出し配下へ戻し、Issue #5 entryはファイル末尾へ追記した。architectureのIssue #2 schema記述と章番号も修正した。
- P2-2: packet buffer容量1024に対して`ceil(delay_s / sample_period_s) + 1 <= 1024`をguardする。境界値は許可し、超過は`teleopDelay:CommunicationBufferOverflow`で拒否する。整数近傍の丸めはexact arrival semanticsを維持するために限定的に行う。
- P2-3: tautological timestamp testを削除し、各時刻の解析的timestamp、validity、age、packet位置、ZOH、CVを直接比較する。communication outputのdimension、type、unit、sample timeとmodel argument metadataも固定した。

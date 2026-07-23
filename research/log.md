# 研究ログ

判断や条件の変更を追記式で記録する。未実施の実験結果は記載しない。

## 2026-07-15: 課題設定とスケルトン固定

- 日付: 2026-07-15
- 目的: 1週間で完結するMATLABシミュレーション研究の開発境界と記録場所を固定する。
- 実施内容: 研究課題、比較対象、評価指標、予定モデル式、MATLAB単一入口、設定検証、スモークテスト、開発規約、ロードマップ、レポート置き場を追加した。
- 結果: 初期スケルトンを作成した。実験は未実施であり、科学モデルと実験結果は未実装である。
- 判断: 次の実装は決定論的軌道生成から開始し、実装・検証・ログ・報告を同一PRで同期する。
- 未解決事項: 軌道の具体的な種類、実験条件の範囲、数値積分法の詳細、評価指標の正規化方法は後続PRで決定する。
- 次の作業: 決定論的軌道生成の仕様を定め、再現可能なテストを追加する。
- 関連commit / PR: draft PR #1（`chore: bootstrap teleoperation delay study`）。

## 2026-07-15: bootstrap監査follow-up

- 日付: 2026-07-15
- 目的: PR #1のP1/P2監査指摘を修正し、スケルトンの実行境界と研究スコープを明確にする。
- 実施内容: `run_project.m`と`tests/smoke_test.m`を関数化し、実行前後のMATLAB path完全一致を検証するテストを追加した。研究全体の対象外を修正し、仮説の運動学的表現を更新し、`report/figures/`をGit追跡可能にした。
- 結果: follow-up修正を実施した。科学モデル、軌道生成、実験結果は未実装のままである。
- 判断: bootstrap PRでは実行入口、path cleanup、研究スコープ、成果物管理だけを扱い、科学モデルの実装には進まない。
- 未解決事項: 決定論的軌道生成以降のモデル仕様と実験条件は後続PRで決定する。
- 次の作業: human review後、決定論的軌道生成の仕様化へ進む。
- 関連commit / PR: follow-up commit / draft PR #1。

## 2026-07-15: 文書最終化と移植資産監査

- 日付: 2026-07-15
- 目的: 添付ドキュメントパッケージを正本としてbootstrapスケルトンを最終化し、ローカル移植候補を監査する。
- 実施内容: `AGENTS.md`、`README.md`、設計・開発・ロードマップ、最終レポートをpayload版へ更新し、`CONTRIBUTING.md`、移植資産ポリシー、プロジェクト固有MATLAB Skill、bootstrap報告、移植資産監査報告を追加した。`research/log.md`の既存履歴は保持して追記した。
- 結果: `devkit.toml`は現環境の`devkit-cli v0.1.6`、schema、コマンドを確認できたためAdoptとした。未追跡の一般Devkit Skill群とMATLAB Agentic Toolkitは取得元・revision・ライセンスまたはNOTICE・再配布条件を確定できずDeferとした。講義・PDF・プロンプト評価用Skill群は本研究と無関係なためRejectとした。
- 判断: MathWorks由来と表示された未追跡MATLAB Toolkitを公式版とはみなさず、`skills/matlab/`へ導入しない。研究固有の規則は`skills/teleop-delay-matlab/SKILL.md`に分離する。
- 未解決事項: Deferした移植候補の再配布条件と上流差分は、必要性と出典が確認できた場合に別途再監査する。
- 次の作業: 次のPRでは決定論的軌道の契約と解析テストだけを実装する。
- 関連commit / PR: `docs: finalize bootstrap and audit migrated tooling` / draft PR #1。

## 2026-07-15: 最終bootstrap監査follow-up

- 日付: 2026-07-15
- 目的: 未検証MATLAB Skill placeholderの重複を除去し、最終tracked structureとDevkit成果物管理を正確にする。
- 実施内容: 追跡済み`skills/matlab/SKILL.md`を削除し、`tests/smoke_test.m`の必須構造確認を`skills/teleop-delay-matlab/`へ更新した。`.devkit-metrics.jsonl`をignoreへ追加し、READMEとbootstrap構造図から未追跡候補を除外した。
- 結果: プロジェクト固有MATLAB Skillは`skills/teleop-delay-matlab/SKILL.md`だけになった。未追跡`skills/matlab-agentic-toolkit/`のDefer判断は変更していない。科学モデル、結果、図は未実装である。
- 判断: 検証済みupstreamを将来導入するまで`skills/matlab/`は追跡しない。未追跡候補72ファイルはstageしない。
- 未解決事項: MATLAB Agentic Toolkitの取得元、revision、NOTICE、再配布条件は未確認のままである。
- 次の作業: human review後、決定論的軌道の契約と解析テストだけを実装する。
- 関連commit / PR: `fix: remove ambiguous MATLAB skill placeholder` / draft PR #1。

## 2026-07-15: first-party Skill採用と退避

- 日付: 2026-07-15
- 目的: 科学modelを実装せず、bootstrap PRの開発Skill構造を最終化する。
- 実施内容: ユーザー作成の`skills/devkit-*`を採用し、汎用MATLAB guideとして`skills/matlab-engineering/`を内製した。`skills/teleop-delay-matlab/SKILL.md`は研究固有のまま維持した。ローカルMATLAB Agentic Toolkitを設計参考として確認し、参照専用・不要SkillをSHA-256 manifest付きのrepository外archiveへ移動した。routingとSkill継続改善方針を更新した。
- 結果: tracked Skillは、first-party Devkit、汎用MATLAB engineering、研究固有MATLAB guidanceの3層へ分離された。軌道、通信、plant、評価指標、実験、結果、図は追加していない。
- 判断: 今後のMATLAB Skill変更には、検証済みで一般化可能な失敗、command、反復workflowの根拠を必須とする。研究固有の判断は研究固有Skillまたは研究ログへ記録する。
- 未解決事項: 参照したMATLAB Toolkitのupstream、revision、完全なLICENSE/NOTICE、再配布条件は未確認であり、reference-only archiveのままとする。
- 次の作業: Skill境界を人間が確認した後、別PRで科学実装へ進む。
- 関連commit / PR: `chore: adopt first-party skills and add MATLAB engineering guide` / draft PR #1。

## 2026-07-15: Devkit source保守の安全化

- 日付: 2026-07-15
- 目的: first-party Devkit SkillがDevkit本体向け保守操作を`teleop-delay-study`へ誤適用することを防ぐ。
- 実施内容: 通常CLI routingと条件付きDevkit source保守を分離した。誤っていたroot-relative Python commandを修正し、同期fallbackへsource marker、path overlap、dry-run guardを追加した。release checkerはtracebackではなく不足fileを列挙して終了するよう修正し、監査・bootstrap報告を更新した。
- 結果: `devkit-project-bootstrap`はDevkit CLIを優先し、Python scriptをguard付きfallbackとして扱う。`devkit-release-maintainer`は明示的なrelease保守依頼を伴うDevkit source checkoutだけに制限した。MATLABまたは科学実装は変更していない。
- 判断: source保守Skillはfirst-party資産として追跡するが、通常のproject release/bootstrap routingには含めない。
- 未解決事項: 実在する外部Devkit source checkoutへのwrite testは行っていない。fake sourceとno-write検証で安全経路を確認した。
- 次の作業: routing境界を人間が確認した後、別PRで科学実装へ進む。
- 関連commit / PR: `fix: guard Devkit source-maintenance skills` / draft PR #1。

## 2026-07-15: 人間向け文書の日本語統一

- 日付: 2026-07-15
- 目的: 授業提出物とrepository利用者が読む文書を日本語へ統一し、後続PRで英語へ戻ることを防ぐ。
- 実施内容: `AGENTS.md`へ言語方針を追加し、README、CONTRIBUTING、設計・開発・roadmap・監査文書、研究課題、研究ログを日本語化した。Skillはエージェント向け契約であるため、翻訳対象から除外した。
- 結果: 人間向け文書、Issue、PR、実装報告は日本語、コード識別子・CLI・Skillは必要に応じて英語という境界を明文化した。科学実装と数値結果は変更していない。
- 判断: 後続作業でも人間向け成果物は日本語で作成する。
- 未解決事項: なし。
- 次の作業: 文書整合を確認し、PR #1を人間reviewへ回す。
- 関連commit / PR: GitHub上の文書日本語化follow-up / draft PR #1。

## 2026-07-15: Issue #2 MATLAB/Simulink基盤

- 日付: 2026-07-15
- 目的: MATLABとSimulinkの責務分離、決定論的軌道、Model Reference plant、再現可能なheadless entry pointを実装する。
- 実施内容: `src/+teleopdelay/`へsourceを移行し、固定`dt`時間grid、円軌道、1:2 Lissajous軌道、一次遅れplant、top-level system model、`SimulationInput`、Dataset logging、smoke testを追加した。
- 結果: MATLAB R2025b Update 5（`25.2.0.3177638`）とSimulinkでbuilder、Model Reference、model update、headless simulation、entry point 3形式、circle/Lissajous、output shape・finite値、path復元、open model cleanup、`checkcode`を確認した。
- 判断: 今回は実行可能性と構造だけを受入対象とし、科学的な解析結果は記載しない。通信遅延、packet sampling、ZOH、CV、metricsは後続PRへ分離する。
- 未実施: 軌道の解析値、周期性、微分一致、plant解析解、solver収束性、補償効果の検証。
- 次の作業: 同じdraft PRのfollow-upで、解析fixture、interface境界、plant解析解、solver収束性を検証する。
- 関連commit / PR: `466d204cc81c72259869656fb2c3bc28a3472c28` / draft PR #4。Issue #2はOPEN。

## 2026-07-15: Issue #2 MATLAB/Simulink検証follow-up

- 日付: 2026-07-15
- 目的: model lifecycleと実行時parameterを分離し、決定論的軌道とModel Reference plantの解析検証を追加する。
- 判断: `build_models`は明示的な保守操作とし、`run_project`は追跡済み`.slx`を再生成・保存しない。modelが存在しない場合は自動生成せず`teleopDelay:MissingModel`で停止する。
- 実装: `time_constant_s`をreferenced modelのmodel argumentとして公開し、`SimulationInput.setVariable`へ`Workspace='teleop_delay_system'`を指定してcaseごとに渡した。base workspace依存は作らない。
- interface: `command_xy_m`と`position_xy_m`をdimension 2、double、unit mとして固定した。Dataset loggingはelement名を完全一致で検証し、順序に依存しない取得とした。
- 検証: unit 12件、model 6件、integration 4件、smoke test、checkcode、model load/update、read-only相当model fileでのruntimeを通過した。
- 数値受入: `T=0.2 s`、定値入力`[1, 0.5]`、duration `0.2 s`で、`dt=0.01 s`の解析解最大誤差は`1.9976097331841913e-08`、`dt=0.005 s`は`1.2227420187471694e-09`。解析解thresholdは`1e-5`とし、step半減で誤差が減少することを確認した。軌道の有限差分thresholdは式の中心差分誤差とdouble丸めを根拠にcircle `1e-7`、Lissajous速度`2e-7`、加速度`5e-7`とした。
- 環境: MATLAB R2025b Update 5、version `25.2.0.3177638`、Simulink同環境。
- 未実施: 通信遅延、packet sampling、ZOH、CV、metrics、補償効果、実験結果の評価。
- 次の作業: follow-up commitをdraft PR #4へpushし、人間reviewを待つ。Issue #2はOPENのままとする。

## 2026-07-15: 最終監査P2修正

- 目的: configの型契約とSimulink sample-time/dimension契約に関するP2指摘2件だけを修正する。
- config契約: `trajectory.type`と`simulation.solver`をnonmissing string scalarに限定し、許可値をそれぞれ`circle`/`lissajous_1_2`と`ode4`の完全一致に限定した。default configからdispatcherまで同じ型契約を通過することをunit testで確認した。
- model契約: R2025b Update 5で実取得したInport/Outportの`SampleTime=-1`、State-Space blockのcompiled sample time `[0 0]`、top-level solver `ode4`を`validate_models`とmodel testへ反映した。未対応のState-Space `SampleTime` parameterは使用していない。
- dimension: 3列external inputを実simulationへ渡すmodel testを追加し、拒否されることを確認した。runtimeのFixedStep上書きは`dt=0.005 s`の出力sample間隔で確認し、追跡modelの既定`0.01`は変更されないことも確認した。
- 回帰結果: unit 15件、model 9件、integration 4件、smoke test、checkcode、run_project三形式、path復元、open model cleanup、model hash不変を通過した。
- 解析回帰: `T=0.2 s`、定値入力`[1, 0.5]`で、`dt=0.01 s`の最大誤差`1.9976097331841913e-08`、`dt=0.005 s`の最大誤差`1.2227420187471694e-09`、誤差比`0.061210255358443696`。既存測定値から悪化していない。
- 未実施: 通信遅延、packet sampling、ZOH、CV、metrics、補償効果。
## 2026-07-22: Issue #5 サンプル値通信とZOH/CV

- 目的: 連続目標位置・解析速度を独立した通信Model Referenceへ入力し、同じ最新packetからZOH/CV指令とpacket diagnosticsを生成して、同一simulation内の2方式のplant出力を取得する実装を成立させた。
- 設計判断: packetはtimestamp、sampled position、sampled velocityを一体として固定長ring bufferへ保持した。時刻`t`では`t_k+delay_s<=t`を満たす最大timestampを決定論的に選択し、exact arrival boundaryは到着済みとした。ZOH、CV、timestamp、age、validityは同じ選択packetを共有した。
- sampling契約: Preferred方式の離散sampling境界を追加する代わりに、`sample_period_s / fixed_step_s`がmachine precision内の正の整数となること、`sample_period_s >= fixed_step_s`、`simulation.fixed_step == simulation.dt`をconfigで必須化した。この数値モデルでは、実行時solver境界で取得したposition・velocityとpacket timestampの対応をこのguardで保証した。非整合条件は`teleopDelay:InvalidSampleAlignment`または`teleopDelay:InvalidFixedStep`で拒否した。
- CVとstartup: CVの外挿時間は名目遅延ではなく`current_time-packet_timestamp_s`とした。最初のpacket到着前は`packet_valid=false`、timestampとageを0、ZOH/CVをゼロとした。valid時のageはcurrent timeと選択timestampの差とした。
- buffer契約: 容量は`communication_buffer_capacity()`が一元管理する1024 packetとした。必要履歴数`ceil(delay_s/sample_period_s)+1`が容量を超える条件を`teleopDelay:CommunicationBufferOverflow`で拒否し、境界値を許可した。整数近傍の丸めは浮動小数点誤差とexact arrival semanticsを考慮して限定的に行った。
- 検証結果: MATLAB R2025b Update 5 / Simulinkでexplicit builder、focused communication 4件、unit 15件、model 13件、integration 4件、smoke testを実行し、全件成功した。sampling alignment、一定速度解析値、buffer境界とring buffer wrap、output metadata、read-only 3 model runtime、path復元、cleanup、base workspace非残留、runtime前後hash一致を確認した。
- 未実装範囲: RMSE、改善率、parameter sweep、結果保存、作図、random軌道、packet loss/jitter、実ネットワークはIssueの指定どおり後続PRの対象とした。

## 2026-07-22: Issue #7 遅延なし参照系・評価区間・追従誤差指標

- 目的: Issue #5で成立したZOH/CV通信経路へ、同じplant条件の遅延なしreference plant、固定grid上の評価区間、追従誤差metricsを追加する。
- 参照系: `position_xy_m`を通信Model Referenceへ入力する前にreference plantへ直接分岐した。ZOH/CV/referenceの3 instanceは同じ`first_order_2d.slx`と同名`time_constant_s` mappingを使用し、plant内部式・interface・初期状態は変更していない。
- 評価区間: `period_s=2*pi/omega`、既定`total_cycles=10`、`warmup_cycles=2`を採用した。nominal endを覆う最小fixed-grid endpointをsimulation durationとし、nominal境界と実際のsample境界を分けて`evaluation`へ記録する。整数近傍の補正はmachine precision由来の限定toleranceだけにした。
- metrics: reference出力との差からRMSE、NRMSE、最大誤差、性能比、改善率を計算する。packet age平均は評価maskかつ`packet_valid=true`だけを使用する。`omega_delay`、`omega_mean_packet_age`、`omega_time_constant`、`omega_sample_period`を無次元量として公開する。
- zero denominator: `32*eps(max(1, abs(rmse_zoh_m), abs(rmse_cv_m)))`以下をzeroとする。両方zeroなら性能比1・改善率0、ZOHだけzeroなら`teleopDelay:UndefinedPerformanceRatio`で拒否する。任意の固定thresholdによるNaN/Inf置換は行わない。
- 解析fixture実測: R2025b Update 5、`dt=sample_period=0.01 s`、`delay=0`、`T=0.2 s`、円軌道、duration `0.20 s`で、ZOH commandと連続目標の最大差は`0`、CV commandの最大差は`2.7755575615628914e-17`、reference plantと円軌道一次遅れ解析解の最大差は`5.24408451829661e-06`、ZOH/reference plant出力差は`0.00208928851916447`、CV/reference plant出力差は`1.044847777553759e-05`であった。解析fixtureはこれらのsolver/logging semanticsを分けたtoleranceで検証する。
- 判断: `output.evaluation`を公開し、CSV/MAT保存、parameter sweep、figure、heatmap、境界解析、random軌道、packet loss/jitterはIssue #7へ含めない。
- 未実施: full unit/model/integration/smokeおよび全srcのcheckcodeはこの追記時点では未実施であり、実行結果はPR報告へ確定値を追記する。

## 2026-07-22: Issue #7 最終検証

- 実行環境: MATLAB R2025b Update 5（`25.2.0.3177638`）/ Simulink。
- 検証: explicit builder成功、focused metrics 7/7、focused reference 2/2、full unit 22/22、full model 15/15、full integration 4/4、smoke成功、全src 17 filesの`checkcode -id` 0件、`git diff --check`成功。
- 標準runtime: duration `62.840000000000003 s`、nominal `[12.566370614359172, 62.831853071795862] s`、sample `[12.57, 62.829999999999998] s`、sample count `5027`。`reference_position_xy_m`は`6285 x 2` finiteであった。
- hygiene: run_project 3形式、path完全復元、3 model close、runtime前後hash不変、read-only model runtime、base workspaceの`time_constant_s`/`sample_period_s`/`delay_s`非残留を確認した。
- 既定runtime metricsはZOH RMSE `0.12085541283838265 m`、CV RMSE `0.007563217627552481 m`、性能比 `0.062580710701527362`、改善率 `93.741928929847262 %`、mean packet age `0.12000198925827607 s`であった。これは標準契約と配線の実行確認値であり、parameter sweepや最終実験結果ではない。

## 2026-07-22: Issue #7 評価契約P1/P2 follow-up

- 目的: PR #12 reviewで残った、evaluation packet validityのfail-closed契約とDataset element間time alignmentを実装・検証する。
- 判断: evaluation.mask内の`packet_valid`は全sampleでtrueを要求する。全件invalidは`teleopDelay:NoValidPacketInEvaluation`、valid/invalid混在は`teleopDelay:IncompletePacketHistoryInEvaluation`で拒否し、invalid sampleだけを除外して評価区間を短縮しない。評価対象`packet_age_s`は有限かつ非負とする。
- 判断: 8つのDataset elementすべての`Values.Time`をcanonical vectorと比較する。各vectorの`N x 1 double`、有限性、厳密単調増加性を確認し、比較toleranceは`32*eps`のmachine precision由来に限定する。不一致は`teleopDelay:MisalignedLoggedSignal`、個別time vector不正は`teleopDelay:InvalidLoggedTime`とする。
- 検証: 固定`dt=0.1 s`、`period_s=1 s`、`total_cycles=2`、`warmup_cycles=1`のunit fixtureでcircleと1:2 Lissajousを同じmask index `11:21`（sample count `11`）として確認した。小配列の全valid、全invalid、混在、負age、logged time不一致fixtureを含むfocused unitは12/12、full unitは27/27で成功した。full modelは15/15、full integrationは4/4、smoke、run_project三形式、checkcode 18 files/0 messages、git diff --checkも成功した。
## 2026-07-23: Issue #8 完全要因実験runnerと再現可能な結果保存

- 判断: Issue #7で固定したreference plant、evaluation window、metrics schemaを再利用し、`teleopdelay.experiment` packageへ実験条件、case ID、逐次runner、aggregate、metadata、atomic persistenceを分離して追加した。
- 標準条件: `circle` / `lissajous_1_2`、`dt = fixed step = 0.005 s`、sample period `0.020 s`、time constant `0.10 s`、delay 5値、omega 4値、10 cycles、warm-up 2 cycles、solver `ode4`。amplitudeはdefault configを使用した。
- case ID: 全定義fieldのcanonical表現から生成し、入力配列の列挙順とloop indexに依存させない。manifest出力順はtrajectory、delay、omegaのcanonical順とした。
- 保存: `results/generated/<experiment_id>/<run_id>/` をcomplete、`<experiment_id>/failed/<run_id>/` をfailed diagnosticとし、CSV/MATのround-trip validation後にatomic renameする。generated artifactはGit管理対象外とした。
- 検証: MATLAB R2025b Update 5 / Simulink 25.2でfocused manifest 6/6、aggregation/persistence 3/3、runner 1/1、full unit 36/36、model 15/15、integration 5/5、smokeを確認した。標準40 caseは40/40 success、CSV/MAT round-trip成功、metadata success=40/failed=0、代表case全metrics最大絶対差0であった。
- 保存結果: experiment_id `i8v1_n40_2353bb12`、run_id `20260722T173019944Z__c536477`。CSV 18,483 bytes、MAT 58,803,422 bytes。CSV/MATのSHA-256とmodel hashは実装報告へ記録した。結果解釈、figure、heatmap、境界解析は追加していない。

## 2026-07-23: Issue #8 P1/P2 fail-closed follow-up

- 判断: successful caseをaggregateへ格納する前に、manifest全条件と`output.config`、simulation solver/fixed step/endpoint、evaluationの`omega_*`派生値を照合する。double比較は固定decimal toleranceではなくmachine precision由来のscale-aware判定とし、不一致は`teleopDelay:ExperimentCaseOutputMismatch`でfailed扱いにする。
- 判断: `SaveResults=false`はsuccessful complete artifactだけを抑制し、failed diagnostic CSV/MATは常に保存する。diagnostic persistence後の実在pathを`teleopDelay:ExperimentIncomplete`へ含め、complete artifact名を使わない。
- 判断: SHA-256はPowerShell等の外部shellを使わず、`teleopdelay.experiment.sha256_file`のbinary readとJava `java.security.MessageDigest`へ統一した。CSV、MAT、model hash testが同じuppercase digest helperを使う。
- 検証: focused P1/P2 7/7、full unit 40/40、full model 15/15、full integration 5/5、smokeを確認した。negative fixture 5種、`SaveResults=false` failure fixture、round-trip checksumを含む。standard 40 caseの最終再実行結果は実装報告とDraft PRへ追記する。

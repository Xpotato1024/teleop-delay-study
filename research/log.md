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

- 目的: 既存実装のsampling時刻保証、packet buffer上限guard、通信schema test、正本文書をreview指摘に合わせて修正する。
- 設計判断: `sample_period_s / fixed_step_s`を正の整数に必須化し、`sample_period_s < fixed_step_s`と非整数比を`teleopDelay:InvalidSampleAlignment`で拒否する。sampling値は実行時のsolver入力と一致する離散境界だけを受け付ける。
- buffer契約: 固定長1024 packet bufferに対し、`ceil(delay_s/sample_period_s)+1`の必要履歴数が容量を超える条件を`teleopDelay:CommunicationBufferOverflow`で拒否する。境界値は許可し、浮動小数点近傍の整数比は丸めてexact arrival semanticsを維持する。
- 検証: sampling alignment、非整数比、`sample_period_s < fixed_step_s`、解析的packet timestamp/age/ZOH/CV、buffer境界、model metadata、runtime cleanupを追加検証する。

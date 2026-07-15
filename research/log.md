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
- 関連commit / PR: `docs: 人間向け文書を日本語化` / draft PR #1。
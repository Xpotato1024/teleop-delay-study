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

## 2026-07-15: documentation finalization and migrated-asset audit

- 日付: 2026-07-15
- 目的: 添付ドキュメントパッケージを正本としてbootstrapスケルトンを最終化し、ローカル移植候補を監査する。
- 実施内容: `AGENTS.md`、`README.md`、設計・開発・ロードマップ、最終レポートをpayload版へ更新し、`CONTRIBUTING.md`、移植資産ポリシー、プロジェクト固有MATLAB Skill、bootstrap報告、移植資産監査報告を追加した。`research/log.md`の既存履歴は保持して追記した。
- 結果: `devkit.toml`は現環境の`devkit-cli v0.1.6`、schema、コマンドを確認できたためAdoptとした。未追跡の一般Devkit Skill群とMATLAB Agentic Toolkitは取得元・revision・ライセンスまたはNOTICE・再配布条件を確定できずDeferとした。講義・PDF・プロンプト評価用Skill群は本研究と無関係なためRejectとした。
- 判断: MathWorks由来と表示された未追跡MATLAB Toolkitを公式版とはみなさず、`skills/matlab/`へ導入しない。研究固有の規則は`skills/teleop-delay-matlab/SKILL.md`に分離する。
- 未解決事項: Deferした移植候補の再配布条件と上流差分は、必要性と出典が確認できた場合に別途再監査する。
- 次の作業: 次のPRでは決定論的軌道の契約と解析テストだけを実装する。
- 関連commit / PR: `docs: finalize bootstrap and audit migrated tooling` / draft PR #1。

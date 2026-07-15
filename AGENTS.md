# AGENTS.md

## 1. プロジェクトの目的

本リポジトリでは、遠隔位置指令に生じる通信遅延と、定速度予測補償が有効となる範囲を検討する。

成果物は、再現可能なMATLABシミュレーションと最終レポートである。汎用的な遠隔操作フレームワークの構築、人を対象とした実験、実ネットワーク計測、詳細なロボット運動学、接触、力覚、機械学習予測は対象外とする。

## 2. 言語方針

- 人間が読むことを主目的とする文書は日本語で作成する。
- 対象には、`README.md`、`CONTRIBUTING.md`、`docs/`、`research/`、`report/`、Issue本文、PR本文、実装報告、監査報告、最終応答を含む。
- 見出し、表、図表題、説明文、受入条件、検証結果も日本語にする。
- コミット件名は、`docs:`、`feat:`、`fix:`等の接頭辞を残して本文を日本語にしてよい。
- `skills/`はエージェントが読む操作契約であり、明示的な依頼がない限り英語のままでよい。
- ソースコードの識別子、CLIオプション、エラー識別子、外部仕様上の正式名称は英語のままでよい。
- 既存の上流資産や引用文を、翻訳のためだけに改変しない。

## 3. 正本の対応表

| 対象 | 正本 |
|---|---|
| 研究質問、仮説、対象範囲 | `research/problem_statement.md` |
| 研究上の判断と変更履歴 | `research/log.md` |
| 信号フロー、モデル境界、データ契約 | `docs/architecture.md` |
| ローカル開発と検証 | `docs/development.md` |
| 1週間の実施計画と削減方針 | `docs/roadmap.md` |
| 移植資産の採否規則 | `docs/migrated-assets-policy.md` |
| 汎用MATLAB作業規則 | `skills/matlab-engineering/SKILL.md` |
| 本研究固有のMATLAB規則 | `skills/teleop-delay-matlab/SKILL.md` |
| 最終レポート | `report/final_report.md` |
| PR単位の実装報告 | `docs/reports/` |

PR本文、チャット、生成結果、コードコメントを、上記の正本より上位に扱わない。

## 4. タスク別の必読資料

MATLAB実装前:

1. `skills/matlab-engineering/SKILL.md`
2. `skills/teleop-delay-matlab/SKILL.md`
3. `docs/architecture.md`
4. 対象コードとテスト

運用・構造変更前:

1. `AGENTS.md`
2. `docs/development.md`
3. `docs/migrated-assets-policy.md`
4. `CONTRIBUTING.md`

最終レポート執筆前:

1. `research/problem_statement.md`
2. `research/log.md`
3. `docs/architecture.md`
4. `results/`以下の検証済み出力
5. `report/final_report.md`

## 5. 作業前確認

すべての作業で次を行う。

1. リポジトリ、既定branch、現在branch、HEADを確認する。
2. `git status --short`を実行する。
3. 編集前に関連する追跡済みファイルを読む。
4. 未追跡ファイルを別に列挙し、暗黙にstageしない。
5. MATLAB作業では、利用可能性とversionを確認する。
6. 必要なToolboxを使用前に確認する。
7. 実装前に検証コマンドを確定する。
8. 正本と依頼が矛盾する場合は停止する。

## 6. 不変条件

- `main`へ直接commitしない。
- branch → commit → pull request → 人間によるmergeの順序を守る。
- 数値結果、引用、テスト成功、MATLAB実行を捏造しない。
- 実行済み、静的確認のみ、未実行を明確に区別する。
- 条件、solver、時間刻み、sampling周期、遅延、乱数seedを記録する。
- 中間生成物は`results/`へ保存する。
- 最終レポート用の図は`report/figures/`へ保存し、Gitで追跡する。
- 生成表や図を手作業で改変し、再現可能な成果物として扱わない。
- MATLAB識別子は英語にする。
- `global`、base workspace依存、隠れたpath変更、暗黙依存を避ける。
- 実装、テスト、`research/log.md`、対応する`docs/reports/`を同じPRで同期する。
- 最小の一貫した変更に留め、無関係な全面改稿を避ける。

## 7. 移植資産

別プロジェクトから持ち込まれた未追跡ファイルは、監査前には信頼済み資産とみなさない。

採用前に`docs/migrated-assets-policy.md`へ従う。

- 出典、ライセンス、秘密情報、path、関連性を確認する前にstageしない。
- 上流MathWorks資産を研究固有Skillへ統合しない。
- 許可される場合は、上流構造、LICENSE、NOTICE、revision情報を維持する。
- 研究固有規則は`skills/teleop-delay-matlab/SKILL.md`へ置く。
- 出典または再配布条件を確認できない場合は`Defer`とする。

採用済みの`skills/devkit-*`はfirst-party Skillである。タスクに必要なものだけを読む。

- tree確認: `devkit-tree-explore`
- encoding確認: `devkit-encoding-hygiene`
- inspect/edit/verify: `devkit-inspect-edit-verify`
- Gitとdraft PR: `devkit-git-drafts`
- 文書編集: `devkit-doc-edit`
- metrics監査: `devkit-metrics-review`
- Devkit CLIの導入・設定: `devkit-project-bootstrap`のCLI利用部分

すべてのDevkit Skillを既定で読まない。

Devkit本体のsource-maintenance Skillは通常routingから分離する。`devkit-release-maintainer`を使用できるのは、対象がDevkit本体のsource checkoutで、`.github/workflows/release.yml`、`rust/crates/devkit-cli`、`rust/crates/devkit-installer`が存在し、かつユーザーがDevkit本体のrelease保守を明示的に依頼した場合だけである。`teleop-delay-study`自身のreleaseやbootstrapには使用しない。`devkit-project-bootstrap`のPython同期scriptもDevkit本体向けの保守fallbackであり、通常はDevkit CLIを使う。

## 8. Skillの継続改善

- 他のMATLABプロジェクトにも一般化できる失敗、検証済みコマンド、反復手順だけを`skills/matlab-engineering/SKILL.md`へ反映する。
- 通信遅延研究に固有の規則は`skills/teleop-delay-matlab/SKILL.md`へ反映する。
- 単発の実装詳細はコードコメントまたはPR報告に、研究判断は`research/log.md`に記録する。
- Skill変更の根拠と検証結果を`skills/matlab-engineering/CHANGELOG.md`へ記録する。
- 単発の局所問題を一般化せず、既存規則を重複させず、Skill改善のためだけに実装範囲を広げない。
- Skillを簡潔に保ち、影響する検証を再実行する。

## 9. 変更種別ごとの検証

| 変更種別 | 必須検証 |
|---|---|
| 文書のみ | 相対リンク、用語整合、`git diff --check` |
| entry point・設定 | `run_project`、`smoke_test`、status、path復元 |
| 軌道生成 | 解析値、shape・unit、端点または周期性 |
| 通信モデル | packet age、境界、ゼロ遅延、到着時刻一致 |
| 数値plant | 解析解、有限値、時間刻み収束性 |
| 評価指標 | 手計算fixture、ゼロ誤差、正規化guard |
| 作図・export | label、unit、legend、aspect ratio、再生成性 |
| 最終実験 | clean workspace再生成、設定と結果の対応、レポート追跡性 |

MATLAB実行には`docs/development.md`記載のコマンドを用いる。Octaveによる確認をMATLAB検証の代替にしない。

## 10. 停止条件

次の場合は推測せず停止して報告する。

- 研究の正本と依頼された実装が矛盾する。
- 信号定義、unit、shape、参照系、評価区間が曖昧である。
- 必須のMATLAB機能またはToolboxが利用できない。
- 移植資産の出典または再配布条件が不明である。
- 検証失敗を説明できない。
- 妥当な時間刻み縮小で結果が大きく変化する。
- 引用または結果の捏造が必要になる。

## 11. PR完了報告

各実装PRで次を報告する。

- branchとcommit SHA
- 変更ファイル
- 実装したmodelまたはcontract
- MATLABの正確なversionと実行コマンド
- テストと結果
- 生成物
- 更新した正本
- 既知の制限と未実行項目
- `main`を直接変更せず、PRをmergeしていないこと
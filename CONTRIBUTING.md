# 開発参加ガイド

本リポジトリは、1週間で完結する個人研究プロジェクトです。運用は軽量に保ちますが、科学的な追跡可能性は必須です。

## 作業手順

1. 最新の`main`から開始する。
2. 一つの一貫した作業単位につき一つのbranchを作成する。
3. 最小の完全な変更を実装する。
4. 実行可能なテストを追加または更新する。
5. 研究判断や条件変更を`research/log.md`へ追記する。
6. `docs/reports/`以下に実装報告を追加または更新する。
7. 必要なMATLAB検証と静的確認を実行する。
8. draft PRを作成し、確認後にReady化する。
9. 人間によるreview後にのみmergeする。

`main`への直接commitは禁止します。

## 推奨するPR順序

1. bootstrapとtooling
2. 決定論的軌道
3. packet sampling、通信遅延、ZOH、定速度予測
4. 一次遅れplantと数値積分
5. 評価指標と参照系
6. 決定論的な完全要因実験
7. 任意の乱数軌道と感度解析
8. 最終レポートと再現性監査

## コミットメッセージ

可能な範囲で、`docs:`、`test:`、`feat:`、`fix:`、`chore:`等の簡潔な接頭辞を用い、本文は日本語で記述します。

## MATLAB検証

`docs/development.md`に記載したコマンドを使用し、実際に使用したMATLAB versionを報告します。静的確認やOctave実行をMATLAB実行の代替にしません。

各MATLAB PRで次を確認します。

- status code
- 意図しないpath変更がないこと
- 出力が有限で、想定shapeであること
- 変更内容に対応するテスト
- `git diff --check`

数値モデルを変更するPRでは、解析解または手計算fixtureと、時間刻み収束性の確認も必要です。

## Skills

`skills/devkit-*`はfirst-partyのDevkit操作契約です。タスクに対応するSkillだけを読みます。`skills/matlab-engineering/`は内製の汎用MATLAB契約、`skills/teleop-delay-matlab/`は本研究固有の規則です。両者を混在させません。

汎用MATLAB Skillは、検証済みで一般化可能な失敗または反復手順が、簡潔な規則として成立する場合だけ改善します。研究固有の判断は研究固有Skillへ、単発の詳細はPR報告またはコードコメントへ記録し、汎用Skill変更の根拠と検証は`skills/matlab-engineering/CHANGELOG.md`へ追記します。

## 文書の同期

次の内容を一致させます。

- `research/problem_statement.md`
- `docs/architecture.md`
- コードとテスト
- `research/log.md`
- `docs/reports/`
- `report/final_report.md`

過去の研究ログを後から書き換えず、日付付きで追記します。

人間向け文書、Issue、PR、実装報告は日本語で記述します。Skill、コード識別子、CLIオプション等は、用途上必要であれば英語のままで構いません。

## 生成物

- `results/`: 中間生成データ。通常はGit追跡しない。
- `report/figures/`: 最終レポートで使用する再生成可能な図。Git追跡する。

MATLABの一時ファイルや、手作業で変更した結果の複製をcommitしません。

## 移植資産

他プロジェクトから移したファイルは、stage前に`docs/migrated-assets-policy.md`に従って監査します。出典、license、秘密情報、絶対path、古いプロジェクト固有指示が不明な場合は導入を停止します。

上流MATLAB Skillと研究固有規則は分離したまま維持します。

## Mergeチェックリスト

- [ ] PRの範囲が一貫している
- [ ] 正本となる文書が同期している
- [ ] MATLABコマンドと結果を記録した
- [ ] テストが変更契約を網羅している
- [ ] 捏造した結果または引用がない
- [ ] 未監査の移植資産をstageしていない
- [ ] 生成結果を再現できる
- [ ] `git diff --check`が成功する
- [ ] 人間によるreviewが完了している
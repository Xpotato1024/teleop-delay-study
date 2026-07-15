# Bootstrapスケルトン実装報告

## 目的

科学実装へ進む前に、リポジトリの開発基盤を確定する。本bootstrapでは次を成立させる。

- 研究・設計文書の正本化
- 安全なMATLAB entry pointとsmoke test
- 汎用MATLAB規則と研究固有MATLAB規則の分離
- 移植toolingの監査
- コード、研究ログ、結果、図、最終レポートの保存場所

## 初期bootstrap

初回commitでは、リポジトリ構造、MATLAB entry point、設定検証、smoke test、研究契約、レポート配置を追加した。MATLAB R2025bで初期entry pointとsmoke testを確認した。

## 初回監査とfollow-up

最初の監査follow-upでは、`run_project.m`と`tests/smoke_test.m`を関数化し、MATLAB pathの完全復元を検証した。また、研究全体の対象外、予測仮説、`report/figures/`の追跡方針を修正した。

## 文書の最終化

placeholder水準だった文書を次の内容へ更新した。

- 高密度な`AGENTS.md`
- 利用者向け`README.md`
- 軽量な`CONTRIBUTING.md`
- model・参照系contract
- P0 / P1 / P2を区別した1週間roadmap
- 移植資産policy
- 汎用と研究固有に分離したMATLAB Skill
- 授業templateに対応する最終レポート骨格
- 人間向け文書を日本語とする言語方針

## 移植資産監査

詳細inventoryは`docs/reports/migrated-assets-audit.md`に記録した。

| 資産 | 判断 | 根拠 | tracked path |
|---|---|---|---|
| `devkit.toml` | Adopt | `devkit-cli v0.1.6`、schema、help、encoding、tree commandを検証済み | `devkit.toml` |
| `skills/devkit-*` | Adopt / first-party | ユーザー作成のDevkit操作契約。通常利用とsource保守をguardで分離 | `skills/devkit-*` |
| `skills/matlab-engineering` | Adopt / project-authored | 汎用MATLAB実行、test、review、debug、再現性contract | `skills/matlab-engineering/` |
| `skills/teleop-delay-matlab` | Adopt / project-specific | 本研究固有MATLAB contractを汎用規則から分離 | `skills/teleop-delay-matlab/` |
| `skills/matlab-agentic-toolkit` | Reference-only / archived | 設計参考として読んだが、revision、完全なLICENSE/NOTICE、再配布条件を未確認 | repository外archive |
| その他のローカルSkill | Reject / archived | prompt、PDF、講義用workflowで本研究には不要 | repository外archive |

MathWorks由来とは、source、revision、再配布条件を確認するまで主張しない。

## 最終tracked構造

```text
.
├── AGENTS.md
├── CONTRIBUTING.md
├── README.md
├── devkit.toml
├── run_project.m
├── skills/
│   ├── devkit-doc-edit/
│   ├── devkit-encoding-hygiene/
│   ├── devkit-git-drafts/
│   ├── devkit-inspect-edit-verify/
│   ├── devkit-metrics-review/
│   ├── devkit-project-bootstrap/
│   ├── devkit-release-maintainer/
│   ├── devkit-tree-explore/
│   ├── matlab-engineering/
│   │   ├── SKILL.md
│   │   ├── REFERENCES.md
│   │   └── CHANGELOG.md
│   └── teleop-delay-matlab/
├── docs/
│   ├── architecture.md
│   ├── development.md
│   ├── migrated-assets-policy.md
│   ├── roadmap.md
│   └── reports/
│       ├── bootstrap-skeleton.md
│       └── migrated-assets-audit.md
├── research/
├── src/
├── tests/
├── report/
│   ├── final_report.md
│   └── figures/
├── results/
└── references/
```

archiveまたは未追跡の移植候補はtracked構造に含めない。

## 検証

最終follow-upまでに次を確認した。

- MATLAB R2025b Update 5 `run_project`: 成功、status `0`
- MATLAB R2025b Update 5 `smoke_test`: 成功、status `0`
- status付き・出力省略entry point: 成功
- 各entry point前後のMATLAB path: 完全一致
- README quick start: 成功
- `checkcode`: message `0`
- 文書相対linkと`AGENTS.md`参照先: 確認済み
- `git diff --check`とstaged file一覧: 確認済み
- secret、local path、private URL: 該当なし
- 科学model、軌道、評価指標、実験、結果、図: 未実装

## Devkit source保守の安全化

first-party Devkit Skillを、本リポジトリでの通常CLI利用と、別のDevkit source checkout保守に分離した。release保守にはDevkit source markerと明示的な依頼を必須とした。project-bootstrapのPython同期scriptは、source root明示、marker確認、path overlap拒否、`--dry-run`を備えたfallbackとし、通常は`devkit bootstrap sync-skills`を使う。

## 未実装の科学範囲

bootstrap完了時点で、次は意図的に未実装である。

- 決定論的軌道
- samplingと通信遅延
- ZOHとCV
- 一次遅れplant
- 評価指標
- 完全要因実験
- 乱数軌道
- レポート用図と数値結果

## 次のPR

決定論的な円軌道・Lissajous軌道のcontract、実装、解析testだけを扱う。
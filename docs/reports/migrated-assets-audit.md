# 移植資産監査報告

## 対象と方法

本監査は、承認済み文書payloadをstageする前に存在したローカル未追跡候補を対象とする。inventoryは`git ls-files --others --exclude-standard`で取得した。payloadから追加した`CONTRIBUTING.md`、`docs/migrated-assets-policy.md`、`skills/teleop-delay-matlab/SKILL.md`は移植候補に含めない。

各候補について、目的、出典、revision、LICENSE/NOTICE、upstream差分、secret・path、他project参照、実行command、tracked fileとの重複、1週間の研究での価値を確認した。

## 採否判断

| 資産 | file数 | 判断 | 根拠 | staged path |
|---|---:|---|---|---|
| `devkit.toml` | 1 | **Adopt** | `devkit-cli v0.1.6`、`--help`、encoding、tree、config生成を確認した。絶対path、private URL、credentialを含まず、encoding/tree確認と日本語Git textに有用である。 | `devkit.toml` |
| `skills/devkit-*` | 26 | **Adopt / first-party** | ユーザー作成のDevkit操作契約。v0.1.6の代表commandを確認した。`rust/`、`SKILLs/`、release workflow等の参照はDevkit本体保守用の意図的なfirst-party参照であり、通常CLI利用とはroutingとguardで分離した。 | `skills/devkit-*` |
| bootstrap `skills/matlab/SKILL.md` | 1 | **Reject** | upstreamではなく、bootstrap時のproject規則placeholderだった。削除し、未検証の`skills/matlab/`を追跡対象外とした。 | 削除 |
| `skills/matlab-agentic-toolkit` | 39 | **Reference-only / archived** | MATLAB debug、test、review、製品確認、環境確認等の設計参考として読んだ。source revision、完全なLICENSE/NOTICE、再配布条件を確認できないため採用しなかった。 | `../teleop-delay-study-local-skills-archive-20260715/` |
| `skills/empirical-prompt-tuning` | 1 | **Reject / archived** | 本研究に不要なprompt評価workflowである。 | 同上 |
| `skills/pdf-to-ai-readable` | 2 | **Reject / archived** | bootstrapに不要な汎用PDF/OCR workflowである。 | 同上 |
| `skills/simulation-engineering-pdf-to-m` | 2 | **Reject / archived** | 別の講義project用抽出workflowである。 | 同上 |
| `skills/simulation-engineering-task01-report` | 2 | **Reject / archived** | 別の講義project用レポートworkflowである。 | 同上 |

`Adapt`に分類した移植候補はない。`skills/matlab-engineering/`は新規内製Skillであり、移植資産ではない。`skills/teleop-delay-matlab/SKILL.md`は研究固有contractとして独立している。

## MATLAB上流資産の判断

bootstrap placeholderの`skills/matlab/SKILL.md`は削除した。MATLAB Agentic Toolkit候補は参照専用としてrepository外へ退避し、`skills/matlab/`または`skills/matlab/UPSTREAM.md`は追加していない。

候補内にはMathWorks copyrightとBSD-3-Clauseの表記があったが、そのコピーの正確なsource repository、revision、import日、完全なLICENSE/NOTICE、再配布条件、upstream差分を確定できなかった。このため、検証済み公式upstreamとは主張しない。

現在追跡する汎用MATLAB規則は内製の`skills/matlab-engineering/`、研究固有規則は`skills/teleop-delay-matlab/`である。

## Devkit source保守との境界

採用したDevkit Skillには次の2種類がある。

- 本リポジトリで通常使用するCLI Skill: tree、encoding、inspect/edit/verify、Git draft、文書、metrics、project bootstrap/config
- Devkit本体source checkoutだけに使用する条件付き保守Skill: release保守とPython Skill同期fallback

source保守参照はfirst-partyで意図的なものであり、無関係なproject混入ではない。ただし、本リポジトリ自身のreleaseまたは`skills/`bootstrapへ直接適用してはならない。`AGENTS.md`と`docs/development.md`では、Devkit source markerと明示的依頼を必須としている。

同期scriptは`SKILLs/`または`rust/`不足、source/destinationの同一・包含関係を拒否し、`--dry-run`を備える。release checkerは必要な3 pathの不足を列挙し、`FileNotFoundError`のtracebackではなく非0 statusで終了する。誤っていたroot-relative commandはtracked pathへ修正した。

## Skill採用・退避後の状態

2026-07-15に、8群26fileの`skills/devkit-*`をfirst-party資産として採用した。参照先が存在しなかった4 linkは、本リポジトリの`docs/development.md`または`CONTRIBUTING.md`へ修正した。その後、source保守用Skillと通常利用Skillのrouting・guardを追加した。

参照専用MATLAB Toolkit 39fileとRejectした4群7fileは削除せず、`../teleop-delay-study-local-skills-archive-20260715/skills/`以下へ移動した。移動前後のSHA-256を照合し、archiveにmanifestを作成した。archiveとmanifestはrepository外でありstageしていない。

初期73fileはhistorical inventoryであり、最終未追跡数ではない。最終tracked Skill構造は`docs/reports/bootstrap-skeleton.md`を正本とする。

## Security・cross-project確認

- credential、token、private URL、実際の個人pathは検出されなかった。
- MATLAB Toolkit内のusername pathは例示であり、この端末のpathではなかった。
- simulation-engineering候補は別講義projectのprogram/report pathを参照していた。
- broad stagingによる候補の誤追加はなかった。

## 初期候補inventory

次の73fileが初期監査対象だった。`devkit.toml`と採用したDevkit Skillは現在trackedであり、残りの移植群はrepository外へ退避済みである。

- `devkit.toml`
- `skills/devkit-doc-edit/SKILL.md`
- `skills/devkit-doc-edit/agents/openai.yaml`
- `skills/devkit-doc-edit/references/command-patterns.md`
- `skills/devkit-encoding-hygiene/SKILL.md`
- `skills/devkit-encoding-hygiene/agents/openai.yaml`
- `skills/devkit-encoding-hygiene/references/newline-playbook.md`
- `skills/devkit-git-drafts/SKILL.md`
- `skills/devkit-git-drafts/agents/openai.yaml`
- `skills/devkit-git-drafts/references/diff-scope-guide.md`
- `skills/devkit-inspect-edit-verify/SKILL.md`
- `skills/devkit-inspect-edit-verify/agents/openai.yaml`
- `skills/devkit-inspect-edit-verify/references/selector-strategy.md`
- `skills/devkit-metrics-review/SKILL.md`
- `skills/devkit-metrics-review/agents/openai.yaml`
- `skills/devkit-metrics-review/references/interpretation-guide.md`
- `skills/devkit-project-bootstrap/SKILL.md`
- `skills/devkit-project-bootstrap/agents/openai.yaml`
- `skills/devkit-project-bootstrap/references/setup-checklist.md`
- `skills/devkit-project-bootstrap/scripts/sync_repo_skills_to_codex.py`
- `skills/devkit-release-maintainer/SKILL.md`
- `skills/devkit-release-maintainer/agents/openai.yaml`
- `skills/devkit-release-maintainer/references/release-checklist.md`
- `skills/devkit-release-maintainer/scripts/check_release_version_alignment.py`
- `skills/devkit-tree-explore/SKILL.md`
- `skills/devkit-tree-explore/agents/openai.yaml`
- `skills/devkit-tree-explore/references/exploration-patterns.md`
- `skills/empirical-prompt-tuning/SKILL.md`
- `skills/matlab-agentic-toolkit/README.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-create-live-script/SKILL.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-create-live-script/manifest.yaml`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/SKILL.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/evals/evals.json`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/evals/fixtures/batchProcess.m`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/evals/fixtures/binData.m`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/evals/fixtures/computeScore.m`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/manifest.yaml`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-install-products/SKILL.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-install-products/evals/evals.json`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-install-products/manifest.yaml`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-install-products/reference/linux-macos-steps.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-list-products/SKILL.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-list-products/evals/evals.json`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-list-products/manifest.yaml`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-review-code/SKILL.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-review-code/manifest.yaml`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/SKILL.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/manifest.yaml`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/reference/app-testing-guidance.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/reference/constraints-guidance.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/reference/fixtures-guidance.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/reference/mocking-guidance.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/reference/parameterized-tests-guidance.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/reference/test-execution-guidance.md`
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/scripts/printCoverageGaps.m`
- `skills/matlab-agentic-toolkit/matlab-core/plugin.yaml`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/SKILL.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/manifest.yaml`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/reference/amp-setup-guidance.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/reference/claude-code-setup-guidance.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/reference/codex-setup-guidance.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/reference/copilot-setup-guidance.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/reference/cursor-setup-guidance.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/reference/gemini-cli-setup-guidance.md`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/scripts/install-global-skills.ps1`
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/scripts/install-global-skills.sh`
- `skills/matlab-agentic-toolkit/toolkit/plugin.yaml`
- `skills/pdf-to-ai-readable/SKILL.md`
- `skills/pdf-to-ai-readable/agents/openai.yaml`
- `skills/simulation-engineering-pdf-to-m/SKILL.md`
- `skills/simulation-engineering-pdf-to-m/agents/openai.yaml`
- `skills/simulation-engineering-task01-report/SKILL.md`
- `skills/simulation-engineering-task01-report/agents/openai.yaml`
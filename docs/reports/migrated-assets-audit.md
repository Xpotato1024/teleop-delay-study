# Migrated assets audit

## Scope and method

This audit covers the local untracked candidates present before staging the author-approved documentation payload. The inventory was obtained with `git ls-files --others --exclude-standard`. The three payload files `CONTRIBUTING.md`, `docs/migrated-assets-policy.md`, and `skills/teleop-delay-matlab/SKILL.md` are documented separately and are not treated as migrated candidates.

The audit checked purpose, source evidence, revision, license or notice evidence, upstream diff availability, secrets and paths, references to other projects, executable commands, overlap with the tracked repository, and value to the one-week study.

## Decisions

| Asset | Files | Decision | Evidence and reason | Staged path |
|---|---:|---|---|---|
| `devkit.toml` | 1 | **Adopt** | The installed `devkit-cli v0.1.6` exists. `devkit --help`, `devkit encoding check README.md --brief`, `devkit tree --path . --brief`, and `devkit config init --path <temporary-file>` succeeded. The TOML uses the generated schema sections, contains no absolute project path, private URL, or credential, and is useful for repository encoding/tree checks and Japanese Git text. It is configuration, not third-party source code; no separate license notice is required. | `devkit.toml` |
| `skills/devkit-*` | 26 | **Defer** | Potentially useful workflow skills, but no source URL, revision, license, NOTICE, or independently identifiable upstream diff was found. They are not required by the MATLAB skeleton or runtime. | Not staged; retained locally |
| `skills/matlab-agentic-toolkit` | 39 | **Defer** | Files contain MathWorks copyright and `MathWorks BSD-3-Clause` claims, but the copied tree has no source URL for the skill package, revision, LICENSE/NOTICE, or independent Git metadata. The local Git context resolves to this repository, so an upstream diff cannot be established. The text includes setup scripts and external installer/server references. Officiality and redistribution terms therefore remain unverified. | Not staged; retained locally |
| `skills/empirical-prompt-tuning` | 1 | **Reject** | Unrelated prompt-evaluation methodology, with no verified provenance or redistribution terms and no immediate value to the one-week simulation repository. | Not staged; retained locally |
| `skills/pdf-to-ai-readable` | 2 | **Reject** | Generic PDF/OCR workflow unrelated to this repository's bootstrap deliverable; provenance and redistribution terms are not established. | Not staged; retained locally |
| `skills/simulation-engineering-pdf-to-m` | 2 | **Reject** | Explicitly targets a separate lecture project program path and would introduce unrelated code-extraction workflow. Provenance and redistribution terms are not established. | Not staged; retained locally |
| `skills/simulation-engineering-task01-report` | 2 | **Reject** | Explicitly targets a separate lecture project report path and is outside this repository's study scope. Provenance and redistribution terms are not established. | Not staged; retained locally |

No candidate required **Adapt**. The project-specific `skills/teleop-delay-matlab/SKILL.md` was supplied by the author in the documentation payload and is added as a local project contract, not merged with the unverified MATLAB toolkit.

## MATLAB upstream decision

The untracked MATLAB toolkit is not adopted as `skills/matlab/`, and no `skills/matlab/UPSTREAM.md` is added. The copied README and manifests state MathWorks copyright and MathWorks BSD-3-Clause, but they do not establish the exact upstream repository, revision, import date, complete license/NOTICE set, or redistribution terms for this copy. Public URLs appearing in the text point to MATLAB MCP/server or documentation resources, not an identifiable revision of this skill tree. No claim that the copied tree is verified official upstream is made.

The tracked `skills/matlab/SKILL.md` remains unchanged. The author-approved project-specific rules live separately in `skills/teleop-delay-matlab/SKILL.md`.

## Security and cross-project scan

- No credential, token, private URL, or actual personal path was found in the candidate scan.
- Generic username path placeholders in the MATLAB toolkit are examples, not this workstation's path.
- The simulation-engineering candidates reference separate lecture-project program/report paths.
- No candidate was staged by broad staging.

## Complete untracked candidate inventory

The following 73 files were present as migrated candidates before staging. The adopted `devkit.toml` is the only candidate staged; every other path below remains untracked and unstaged.

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

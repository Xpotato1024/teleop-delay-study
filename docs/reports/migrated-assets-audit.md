# Migrated assets audit

## Scope and method

This audit covers the local untracked candidates present before staging the author-approved documentation payload. The inventory was obtained with `git ls-files --others --exclude-standard`. The three payload files `CONTRIBUTING.md`, `docs/migrated-assets-policy.md`, and `skills/teleop-delay-matlab/SKILL.md` are documented separately and are not treated as migrated candidates.

The audit checked purpose, source evidence, revision, license or notice evidence, upstream diff availability, secrets and paths, references to other projects, executable commands, overlap with the tracked repository, and value to the one-week study.

## Decisions

| Asset | Files | Decision | Evidence and reason | Staged path |
|---|---:|---|---|---|
| `devkit.toml` | 1 | **Adopt** | The installed `devkit-cli v0.1.6` exists. `devkit --help`, `devkit encoding check README.md --brief`, `devkit tree --path . --brief`, and `devkit config init --path <temporary-file>` succeeded. The TOML uses the generated schema sections, contains no absolute project path, private URL, or credential, and is useful for repository encoding/tree checks and Japanese Git text. It is configuration, not third-party source code; no separate license notice is required. | `devkit.toml` |
| `skills/devkit-*` | 26 | **Adopt / first-party** | User-authored Devkit operation contracts. `devkit-cli v0.1.6` version/help and representative commands were checked. Devkit source-maintenance paths such as `rust/`, `SKILLs/`, and `.github/workflows/release.yml` are intentional first-party references; they are not normal `teleop-delay-study` targets. Routing and guards separate CLI use from source maintenance. | `skills/devkit-*` |
| bootstrap `skills/matlab/SKILL.md` | 1 | **Reject** | This was a bootstrap project-rules placeholder, not verified upstream material. It was deleted in this follow-up so the unverified `skills/matlab/` directory is no longer tracked. | Deleted |
| `skills/matlab-agentic-toolkit` | 39 | **Reference-only / archived** | Read for MATLAB debugging, testing, review, product discovery, environment setup, manifests, references, and eval fixtures. The copied tree has no verified source revision, complete LICENSE/NOTICE set, or redistribution terms, so it was not adopted or copied. | `../teleop-delay-study-local-skills-archive-20260715/` |
| `skills/empirical-prompt-tuning` | 1 | **Reject / archived** | Unrelated prompt-evaluation methodology with no immediate value to this study. | `../teleop-delay-study-local-skills-archive-20260715/` |
| `skills/pdf-to-ai-readable` | 2 | **Reject / archived** | Generic PDF/OCR workflow unrelated to this bootstrap repository. | `../teleop-delay-study-local-skills-archive-20260715/` |
| `skills/simulation-engineering-pdf-to-m` | 2 | **Reject / archived** | Separate lecture-project extraction workflow. | `../teleop-delay-study-local-skills-archive-20260715/` |
| `skills/simulation-engineering-task01-report` | 2 | **Reject / archived** | Separate lecture-project report workflow. | `../teleop-delay-study-local-skills-archive-20260715/` |

No candidate required **Adapt**. `skills/matlab-engineering/` is a new project-authored Skill, not a migrated asset. The project-specific `skills/teleop-delay-matlab/SKILL.md` remains a separate local contract.

## MATLAB upstream decision

The bootstrap placeholder `skills/matlab/SKILL.md` was deleted. The MATLAB toolkit is reference-only and archived, not adopted as `skills/matlab/`, and no `skills/matlab/UPSTREAM.md` is added. The copied README and manifests state MathWorks copyright and MathWorks BSD-3-Clause, but they do not establish the exact upstream repository, revision, import date, complete license/NOTICE set, or redistribution terms for this copy. Public URLs appearing in the text point to MATLAB MCP/server or documentation resources, not an identifiable revision of this skill tree. No claim that the copied tree is verified official upstream is made.

No `skills/matlab/` directory is tracked. The author-approved project-specific rules live separately in `skills/teleop-delay-matlab/SKILL.md`.

## Devkit source-maintenance boundary

The adopted Devkit Skills contain two deliberate roles:

- CLI-use Skills for this repository: tree exploration, encoding, inspect/edit/verify, Git drafts, documentation, metrics, and ordinary project bootstrap/configuration;
- conditional Devkit-source-maintenance Skills: release maintenance and the Python Skill-sync fallback, which assume a Devkit source checkout.

The source-maintenance references are first-party and intentional, not unrelated-project contamination. They must not be applied directly to this repository's release or `skills/` bootstrap. `AGENTS.md` and `docs/development.md` now require the Devkit source markers before release maintenance. The project-bootstrap Skill makes `devkit bootstrap sync-skills` the first choice and documents the Python script only as an explicit `--repo-root <devkit-source-repo>` fallback.

The sync script now refuses missing `SKILLs/` or `rust/`, refuses source/destination equality or nesting, and supports a no-write `--dry-run`. Its help states that matching destination Skill directories are replaced. The release checker now reports missing `.github/workflows/release.yml`, `rust/crates/devkit-cli/src/main.rs`, and `rust/crates/devkit-installer/src/main.rs` as explicit failures instead of raising `FileNotFoundError`. Root-relative script commands were corrected to the tracked paths under `skills/`.

## Final status after Skill adoption and archive

On 2026-07-15, the eight `skills/devkit-*` groups (26 files) were adopted as first-party assets. Four inherited links to the source Devkit repository's unavailable `docs/design/` pages were adapted to this repository's `docs/development.md` or `CONTRIBUTING.md`; no workflow command or substantive rule was redesigned at that adoption stage. The project-authored `skills/matlab-engineering/` (three files) was added after the reference-only MATLAB review. The existing `skills/teleop-delay-matlab/SKILL.md` remains the study-specific contract. The later source-maintenance safety follow-up is recorded above and in the current PR.

The 39 MATLAB Agentic Toolkit files were moved, not deleted, to `../teleop-delay-study-local-skills-archive-20260715/skills/matlab-agentic-toolkit/` after review. The four rejected groups (seven files) were moved to the same archive under their original `skills/` paths. An archive SHA-256 manifest was generated and checked against the files after the move. Neither the archive nor its manifest is inside the repository or staged.

The initial count of 73 refers to the historical audit inventory, not the final untracked count. The final tracked Skill structure is the one shown in `docs/reports/bootstrap-skeleton.md`; the archived groups are not tracked.

## Security and cross-project scan

- No credential, token, private URL, or actual personal path was found in the candidate scan.
- Generic username path placeholders in the MATLAB toolkit are examples, not this workstation's path.
- The simulation-engineering candidates reference separate lecture-project program/report paths.
- No candidate was staged by broad staging.

## Complete untracked candidate inventory

The following 73 files were present in the initial audit inventory: tracked `devkit.toml` plus 72 untracked local candidates. This historical list is retained for traceability; final status is recorded below. Adopted Devkit files are tracked, and the remaining migrated groups were archived outside the repository.

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

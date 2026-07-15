---
name: devkit-release-maintainer
description: Use when an AI agent needs to prepare, verify, or debug devkit releases, including tags, release metadata, installer packaging, and user-visible version alignment.
---

# devkit release maintainer

Use this skill only for release-oriented work on the `devkit` source repository itself. Do not use it for `teleop-delay-study` release work or ordinary Devkit CLI usage.

## When to use

- A release tag is about to be cut or was just cut.
- Release metadata, installer manifests, or version display may be inconsistent.
- A GitHub Actions release build or packaging flow needs verification.
- Windows installer packaging behavior needs release validation.

## Workflow

1. Confirm that the target is a Devkit source checkout before any command:
   - `.github/workflows/release.yml` exists;
   - `rust/crates/devkit-cli` exists;
   - `rust/crates/devkit-installer` exists.
   If these markers are absent, stop and report the missing paths.
2. Confirm release-facing metadata.
   - Check `README.md`, `docs/release/`, and `AGENTS.md`.
   - Verify user-visible version paths such as `devkit -V`, installer `--version`, and manifest version fields.
3. Verify local build behavior.
   - `cargo test -p devkit-cli -p devkit-installer`
   - `cargo run -p devkit-cli -- -V`
   - For release-injected behavior, build or run with `DEVKIT_RELEASE_VERSION=<tag>`
4. Verify installer and packaging flow when relevant.
   - Build `devkit-cli`
   - Build `devkit-cleanup-helper`
   - Build `devkit-installer` with embedded payload env vars
5. Only then proceed to tag / release publication.
6. Use the bundled checker when the version-alignment path itself needs a deterministic audit:
   - `uv run python skills/devkit-release-maintainer/scripts/check_release_version_alignment.py --repo-root <devkit-source-repo>`

## Rules

- Treat release tags as the source of truth for user-facing release version output.
- Verify both fallback local behavior and tagged-release behavior when version metadata is touched.
- Do not assume crate `version` fields alone define the shipped release version.
- A `teleop-delay-study` root is a negative case for this Skill, not a release target.

## Reference

- See `docs/release/`
- See `docs/reports/release_version_metadata_report_2026-04-09.md`
- When actively preparing or validating a release, read [references/release-checklist.md](references/release-checklist.md).
- Use [scripts/check_release_version_alignment.py](scripts/check_release_version_alignment.py) when you need a repeatable static check of the release-version wiring.

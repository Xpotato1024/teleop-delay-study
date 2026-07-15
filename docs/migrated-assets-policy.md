# Migrated asset policy

## Purpose

Local untracked files copied from another project may contain valuable tooling, but also stale assumptions, incompatible paths, unknown licenses, or secrets. They are not trusted until audited.

## Audit output

Record the audit in `docs/reports/migrated-assets-audit.md`. Classify every candidate as:

- **Adopt** — relevant, safe, licensed, usable without substantive local changes;
- **Adapt** — relevant and licensed, but requires explicit project-specific changes;
- **Defer** — potentially useful, but provenance, license, compatibility, or need is unresolved;
- **Reject** — irrelevant, duplicated, unsafe, incompatible, or not redistributable.

Do not delete deferred or rejected local files without explicit instruction.

## Required checks

For every candidate:

1. exact path and file type;
2. purpose and expected consumer;
3. source URL or repository;
4. source revision, tag, or release;
5. license and notice requirements;
6. diff from upstream when identifiable;
7. secrets, tokens, private URLs, identifiers, and absolute paths;
8. references to another repository, command, skill, or directory;
9. executable commands and local support;
10. overlap with tracked files;
11. immediate value to the one-week study.

Do not stage before these checks are recorded.

## MathWorks or other upstream MATLAB skills

A locally copied MATLAB skill may be official upstream material, but memory alone is not sufficient proof.

When provenance and redistribution are verified:

- preserve upstream structure where practical;
- preserve required `LICENSE`, `NOTICE`, and attribution;
- add `UPSTREAM.md` with source, revision, import date, local modifications, and license;
- avoid editing upstream files;
- keep upstream MATLAB guidance separate from project rules;
- place local rules in `skills/teleop-delay-matlab/SKILL.md`.

Expected role split:

```text
skills/
├── matlab/
│   ├── SKILL.md
│   ├── UPSTREAM.md
│   └── required license or notice files
└── teleop-delay-matlab/
    └── SKILL.md
```

If provenance or redistribution cannot be verified:

- do not claim the files are official;
- do not commit them;
- classify as `Defer`;
- retain the project-specific skill independently.

The tracked placeholder under `skills/matlab/` must not be represented as upstream official content. Replace it only as part of verified adoption.

## `devkit.toml`

Before adoption:

- identify the exact tool and supported schema;
- confirm the tool exists locally;
- inspect actual help or official documentation;
- confirm every command and path;
- remove other-project references;
- verify concrete value to this repository.

If the tool or schema cannot be verified, classify it as `Defer`.

## First-party Devkit Skills

The user-authored `skills/devkit-*` directories are first-party assets, not third-party imports. Before staging them, check secrets, personal paths, cross-project references, command compatibility with the installed Devkit version, and script side effects. Preserve their structure and wording unless a safety or compatibility correction is necessary; record any such correction in the audit.

## Reference-only local Skills

When the user explicitly requests cleanup after reference review, move rejected or reference-only local Skill groups to the named external archive rather than deleting them. Verify the inventory and file hashes before and after the move, create an archive SHA-256 manifest, and never stage the archive or its manifest.

## Staging rule

After audit:

- stage only Adopt and approved Adapt outputs;
- report remaining untracked files;
- use `git diff --cached --name-status`;
- verify no candidate was added by broad staging.

## Public-repository rule

No imported asset may expose credentials, private URLs, personal paths, non-public data, or third-party material without redistribution permission.

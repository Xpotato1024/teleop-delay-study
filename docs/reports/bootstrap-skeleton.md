# Bootstrap skeleton report

## Purpose

Finalize the repository skeleton before scientific implementation. The bootstrap establishes:

- authoritative research and architecture documents;
- safe MATLAB entry point and smoke test;
- project-specific MATLAB guidance;
- audited handling of migrated tooling;
- locations for code, logs, results, figures, and final report.

## Initial bootstrap

The initial bootstrap commit established the repository layout, MATLAB entry point, configuration validation, smoke test, research contract, and report locations. MATLAB R2025b verified the original skeleton entry point and smoke test.

## First audit and follow-up

The first audit follow-up converted `run_project.m` and `tests/smoke_test.m` to functions, verified exact MATLAB path restoration, corrected the research-wide exclusion scope, refined the prediction hypothesis, and made `report/figures/` trackable.

## Documentation finalization

This package replaces placeholder-level documentation with:

- a high-density `AGENTS.md`;
- public-facing `README.md`;
- lightweight `CONTRIBUTING.md`;
- explicit model and reference-system contracts;
- a one-week P0/P1/P2 roadmap;
- migrated-asset policy;
- separate project-specific MATLAB skill;
- course-template-aligned report skeleton.

## Migrated asset audit

Detailed inventory belongs in `docs/reports/migrated-assets-audit.md`.

| Asset | Decision | Reason | Tracked path |
|---|---|---|---|
| `devkit.toml` | Adopt | `devkit-cli v0.1.6`, schema template, help, encoding, and tree commands verified; no project-specific absolute path or secret | `devkit.toml` |
| `skills/devkit-*` | Adopt / first-party | User-authored Devkit operation contracts; v0.1.6 commands and safety scans verified | `skills/devkit-*` |
| `skills/matlab-engineering` | Adopt / project-authored | Generic MATLAB execution, testing, review, debugging, and reproducibility contract | `skills/matlab-engineering/` |
| `skills/teleop-delay-matlab` | Adopt / project-specific | Research-specific MATLAB contract kept separate from generic guidance | `skills/teleop-delay-matlab/` |
| `skills/matlab-agentic-toolkit` | Reference-only / archived | Read for design reference; upstream revision, complete license/NOTICE, and redistribution terms remain unverified | external archive |
| Other local Skills | Reject / archived | Unrelated prompt, PDF, and lecture workflows | external archive |

Do not claim MathWorks provenance until source, revision, and redistribution terms are verified.

## Final bootstrap structure

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

Archived or untracked local migration candidates are not part of the tracked structure; see `docs/reports/migrated-assets-audit.md`.

## Validation

Completed for this follow-up:

- MATLAB R2025b `run_project`: success, status `0`;
- MATLAB R2025b `smoke_test`: success, status `0`;
- status-bearing and output-free entry-point calls: success;
- MATLAB path equality before and after each entry point: exact match;
- README quick-start commands from the repository root: success;
- relative documentation links and `AGENTS.md` references: checked;
- `git diff --check` and `git diff --cached --name-status`: checked;
- staged-content scan for local paths, private URLs, tokens, and other-project names: checked;
- no scientific model, trajectory, metric, experiment, result, or figure introduced.

The MATLAB engineering Skill and first-party Devkit Skills were audited and added after this report was first written. The MATLAB Agentic Toolkit and unrelated local Skills were moved to the external archive recorded in `docs/reports/migrated-assets-audit.md`.

## Unimplemented scientific scope

At the end of bootstrap:

- deterministic trajectories;
- sampling and delay;
- ZOH and CV;
- first-order plant;
- metrics;
- experiments;
- random trajectories;
- report figures and results

remain intentionally unimplemented.

## Next PR

Implement only deterministic trajectory contracts and analytic tests.

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
| MATLAB upstream skill candidate | Defer | MathWorks claims are present, but exact source, revision, NOTICE, and redistribution terms are unverified | not staged |
| Other skill candidates | Defer/Reject | See the complete inventory and per-group decisions in `docs/reports/migrated-assets-audit.md` | not staged |

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
│   ├── matlab/
│   ├── teleop-delay-matlab/
│   └── (unverified local candidates remain unstaged)
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

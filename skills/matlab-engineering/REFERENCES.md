# MATLAB engineering references

## Reviewed local material

The following local, untracked MATLAB Agentic Toolkit files were read as design references on 2026-07-15:

- `skills/matlab-agentic-toolkit/matlab-core/matlab-debugging/SKILL.md`: separate static diagnosis from runtime diagnosis; preserve stack details; guard against paused breakpoints in headless execution.
- `skills/matlab-agentic-toolkit/matlab-core/matlab-testing/SKILL.md`: organize tests around observable behavior, fixtures, cleanup, determinism, and explicit result inspection.
- `skills/matlab-agentic-toolkit/matlab-core/matlab-review-code/SKILL.md`: combine Code Analyzer output with manual review for shadowing, paths, shapes, and maintainability.
- `skills/matlab-agentic-toolkit/matlab-core/matlab-list-products/SKILL.md`: make installed-product discovery explicit before assuming toolbox support.
- `skills/matlab-agentic-toolkit/matlab-core/matlab-create-live-script/SKILL.md`: keep version-controlled MATLAB text artifacts distinct from ordinary function files.
- `skills/matlab-agentic-toolkit/toolkit/matlab-agentic-toolkit-setup/SKILL.md`: discover the environment before configuration and report tested versus experimental integrations.
- The related `manifest.yaml`, reference, and eval-fixture files: use manifests and fixtures as audit evidence, not as a repository structure to reproduce.

## Design outcome

These references suggested concise routing, explicit environment discovery, independent checks for execution/testing/static review/debugging, and progressive disclosure. The resulting skill was authored for GPT-5.6 and this repository; its wording, structure, commands, and files were not copied or lightly paraphrased from the reviewed material.

The reviewed Toolkit was not imported as a tracked asset, does not provide an upstream or redistribution claim for this repository, and is archived outside the repository after review. Project-specific rules remain in `skills/teleop-delay-matlab/SKILL.md`.

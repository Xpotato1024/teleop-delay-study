# Changelog

## 2026-07-15

- Created a short generic MATLAB engineering skill to separate environment, execution, testing, review, debugging, numerical, and reproducibility guidance from the teleoperation study contract.
- Reviewed the local MATLAB debugging, testing, code-review, product-discovery, Live Script, setup, manifest, reference, and eval-fixture material listed in `REFERENCES.md`.
- Verified with MATLAB R2025b Update 5: `matlab -batch "disp(version('-release'))"`, `matlab -batch "ver"`, the repository `run_project` entry point, status-bearing and output-free calls, `smoke_test`, exact path restoration, and `checkcode`.
- Initial version does not define research equations, trajectory generation, communication models, plant models, metrics, experiments, or MCP/third-party-toolkit setup.
- Improve this skill only when a generalizable failure, verified command, or repeated workflow justifies a concise rule; record the evidence and rerun the affected checks.

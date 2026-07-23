function tests = test_experiment_manifest
tests = functiontests(localfunctions);
end

function testStandardManifestHasFortyCanonicalCases(testCase)
manifest = teleopdelay.experiment.standard_manifest();
verifyEqual(testCase, manifest.case_count, 40);
verifyEqual(testCase, numel(unique(string({manifest.cases.case_id}))), 40);
verifyEqual(testCase, numel(unique(string({manifest.cases.canonical_key}))), 40);
verifyEqual(testCase, sort(unique(string({manifest.cases.trajectory}))), ...
    ["circle", "lissajous_1_2"]);
verifyEqual(testCase, sort(unique([manifest.cases.delay_s])), ...
    [0, 0.10, 0.20, 0.40, 0.50]);
verifyEqual(testCase, sort(unique([manifest.cases.omega_rad_s])), ...
    [0.5, 1.0, 2.0, 4.0]);
verifyTrue(testCase, teleopdelay.experiment.validate_manifest(manifest));
end

function testManifestIsInvariantToAxisEnumerationOrder(testCase)
canonical = teleopdelay.experiment.standard_manifest();
permuted = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", ["lissajous_1_2", "circle"], ...
    "Delays", [0.50, 0.40, 0.20, 0.10, 0], ...
    "Omegas", [4.0, 2.0, 1.0, 0.5]);
verifyEqual(testCase, string({permuted.cases.case_id}), ...
    string({canonical.cases.case_id}));
verifyEqual(testCase, permuted.experiment_id, canonical.experiment_id);
end

function testStandardValuesAndGridAlignedDurations(testCase)
manifest = teleopdelay.experiment.standard_manifest();
for index = 1:manifest.case_count
    definition = manifest.cases(index);
    verifyEqual(testCase, definition.amplitude_m, 1.0, AbsTol=0);
    verifyEqual(testCase, definition.sample_period_s, 0.020, AbsTol=0);
    verifyEqual(testCase, definition.time_constant_s, 0.10, AbsTol=0);
    verifyEqual(testCase, definition.dt_s, 0.005, AbsTol=0);
    verifyEqual(testCase, definition.fixed_step_s, 0.005, AbsTol=0);
    verifyEqual(testCase, definition.total_cycles, 10, AbsTol=0);
    verifyEqual(testCase, definition.warmup_cycles, 2, AbsTol=0);
    verifyEqual(testCase, definition.solver, "ode4");
    expected = teleopdelay.metrics.grid_aligned_duration( ...
        10 * 2 * pi / definition.omega_rad_s, 0.005);
    verifyEqual(testCase, definition.duration_s, expected, AbsTol=0);
    config = teleopdelay.experiment.case_config(definition);
    verifyTrue(testCase, teleopdelay.config.validate_config(config));
end
end

function testManifestRejectsDuplicateCaseId(testCase)
manifest = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", "circle", "Delays", [0, 0.1], "Omegas", 0.5);
manifest.cases(2) = manifest.cases(1);
manifest.experiment_id = teleopdelay.experiment.experiment_id(manifest);
verifyError(testCase, @() teleopdelay.experiment.validate_manifest(manifest), ...
    "teleopDelay:ExperimentManifestDuplicateCaseId");
end

function testManifestRejectsMissingAndNonfiniteFields(testCase)
manifest = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", "circle", "Delays", 0, "Omegas", 0.5);
manifest.cases = rmfield(manifest.cases, "delay_s");
verifyError(testCase, @() teleopdelay.experiment.validate_manifest(manifest), ...
    "teleopDelay:ExperimentManifestMissingField");

manifest = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", "circle", "Delays", 0, "Omegas", 0.5);
manifest.cases.delay_s = NaN;
verifyError(testCase, @() teleopdelay.experiment.validate_manifest(manifest), ...
    "teleopDelay:ExperimentManifestNonFinite");
end

function testManifestRejectsNoncanonicalOrder(testCase)
manifest = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", "circle", "Delays", [0, 0.1], "Omegas", [0.5, 1]);
manifest.cases = flipud(manifest.cases);
manifest.experiment_id = teleopdelay.experiment.experiment_id(manifest);
verifyError(testCase, @() teleopdelay.experiment.validate_manifest(manifest), ...
    "teleopDelay:ExperimentManifestNoncanonicalOrder");
end

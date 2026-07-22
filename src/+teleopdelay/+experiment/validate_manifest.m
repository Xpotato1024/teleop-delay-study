function isValid = validate_manifest(manifest)
% validate_manifest  Validate manifest structure and every config contract.

if ~isstruct(manifest) || ~isscalar(manifest)
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "manifest must be a scalar struct.");
end
requiredManifestFields = ["schema_version", "experiment_id", "case_count", "cases"];
if ~all(isfield(manifest, requiredManifestFields))
    error("teleopDelay:ExperimentManifestMissingField", ...
        "manifest is missing one or more required fields.");
end
if ~(isstring(manifest.schema_version) && isscalar(manifest.schema_version) && ...
        manifest.schema_version == "issue8.standard.v1")
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "manifest.schema_version is not supported.");
end
cases = manifest.cases;
if ~isstruct(cases) || isempty(cases)
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "manifest.cases must be a nonempty struct array.");
end
if ~(isa(manifest.case_count, "double") && isscalar(manifest.case_count) && ...
        manifest.case_count == numel(cases))
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "manifest.case_count must match the number of case definitions.");
end

requiredCaseFields = ["case_id", "canonical_key", "trajectory", ...
    "amplitude_m", "omega_rad_s", "delay_s", "sample_period_s", ...
    "time_constant_s", "dt_s", "fixed_step_s", "total_cycles", ...
    "warmup_cycles", "solver", "nominal_duration_s", ...
    "expected_duration_s", "duration_s"];
if ~all(isfield(cases, requiredCaseFields))
    error("teleopDelay:ExperimentManifestMissingField", ...
        "A case definition is missing one or more required fields.");
end

caseIds = strings(numel(cases), 1);
canonicalKeys = strings(numel(cases), 1);
sortMatrix = zeros(numel(cases), 3);
for index = 1:numel(cases)
    definition = cases(index);
    validate_case_scalar_fields(definition);
    config = teleopdelay.experiment.case_config(definition);
    teleopdelay.config.validate_config(config);
    nominalDuration = config.evaluation.total_cycles * 2 * pi / ...
        config.trajectory.omega;
    expectedDuration = teleopdelay.metrics.grid_aligned_duration( ...
        nominalDuration, config.simulation.fixed_step);
    tolerance = 128 * eps(max([1, abs(expectedDuration), abs(definition.duration_s)]));
    if abs(definition.nominal_duration_s - nominalDuration) > tolerance || ...
            abs(definition.expected_duration_s - expectedDuration) > tolerance || ...
            abs(definition.duration_s - expectedDuration) > tolerance
        error("teleopDelay:ExperimentManifestGridMismatch", ...
            "Case %d does not use its grid-aligned expected duration.", index);
    end
    [expectedId, expectedKey] = teleopdelay.experiment.case_id(definition);
    if string(definition.case_id) ~= expectedId || string(definition.canonical_key) ~= expectedKey
        error("teleopDelay:ExperimentManifestInvalidCaseId", ...
            "Case %d has a noncanonical case_id or canonical_key.", index);
    end
    caseIds(index) = string(definition.case_id);
    canonicalKeys(index) = string(definition.canonical_key);
    sortMatrix(index, :) = [ ...
        double(definition.trajectory == "lissajous_1_2"), ...
        definition.delay_s, definition.omega_rad_s];
end
if numel(unique(caseIds)) ~= numel(caseIds)
    error("teleopDelay:ExperimentManifestDuplicateCaseId", ...
        "manifest contains duplicate case IDs.");
end
if numel(unique(canonicalKeys)) ~= numel(canonicalKeys)
    error("teleopDelay:ExperimentManifestDuplicateCondition", ...
        "manifest contains duplicate case conditions.");
end
[~, canonicalOrder] = sortrows(sortMatrix, [1, 2, 3]);
if ~isequal(canonicalKeys, canonicalKeys(canonicalOrder))
    error("teleopDelay:ExperimentManifestNoncanonicalOrder", ...
        "manifest.cases is not in canonical order.");
end
expectedExperimentId = teleopdelay.experiment.experiment_id(manifest);
if string(manifest.experiment_id) ~= expectedExperimentId
    error("teleopDelay:ExperimentManifestInvalidExperimentId", ...
        "manifest.experiment_id is not canonical.");
end
isValid = true;
end

function validate_case_scalar_fields(definition)
stringFields = ["case_id", "canonical_key", "trajectory", "solver"];
for name = stringFields
    value = definition.(char(name));
    if ~(isstring(value) && isscalar(value) && ~ismissing(value))
        error("teleopDelay:ExperimentManifestInvalidField", ...
            "Case field %s must be a nonmissing string scalar.", name);
    end
end
if ~ismember(definition.trajectory, ["circle", "lissajous_1_2"])
    error("teleopDelay:InvalidConfig", ...
        "case trajectory must be circle or lissajous_1_2.");
end
numericFields = ["amplitude_m", "omega_rad_s", "delay_s", ...
    "sample_period_s", "time_constant_s", "dt_s", "fixed_step_s", ...
    "total_cycles", "warmup_cycles", "nominal_duration_s", ...
    "expected_duration_s", "duration_s"];
for name = numericFields
    value = definition.(char(name));
    if ~(isa(value, "double") && isscalar(value) && isreal(value) && isfinite(value))
        error("teleopDelay:ExperimentManifestNonFinite", ...
            "Case field %s must be a finite double scalar.", name);
    end
end
end

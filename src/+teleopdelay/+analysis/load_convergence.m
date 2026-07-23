function convergence = load_convergence(input, convergenceMat, outputRoot, config, ...
        explicitRequested, preliminaryRepresentatives)
% load_convergence  Load and validate the expected representative supplement.

if nargin < 5
    explicitRequested = false;
end
if nargin < 6 || isempty(preliminaryRepresentatives)
    preliminaryRepresentatives = table();
end
candidate = string(convergenceMat);
if explicitRequested
    if strlength(candidate) == 0
        error("teleopDelay:AnalysisConvergenceMissing", ...
            "An explicit ConvergenceMat was provided but is empty.");
    end
    if ~isfile(candidate)
        error("teleopDelay:AnalysisConvergenceMissing", ...
            "The explicit ConvergenceMat does not exist: %s", candidate);
    end
    loaded = try_load(candidate, input, config, preliminaryRepresentatives);
    if ~loaded.available
        error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
            "The explicit convergence artifact is incompatible: %s", loaded.reason);
    end
    loaded.source = "explicit-saved-convergence-artifact";
    loaded.diagnostics = diagnostic_table({string(candidate), true, "valid", loaded.semantic_hash, true});
    convergence = loaded;
    return;
end

pattern = fullfile(char(outputRoot), "analysis", char(input.source_experiment_id), ...
    "*", "*", "analysis_tables.mat");
files = dir(pattern);
paths = strings(0, 1);
for index = 1:numel(files)
    paths(end + 1) = string(fullfile(files(index).folder, files(index).name)); %#ok<AGROW>
end
paths = sort(paths);
diagnosticRows = cell(numel(paths), 5);
validCandidates = cell(numel(paths), 1);
validCount = 0;
for pathIndex = 1:numel(paths)
    loaded = try_load(paths(pathIndex), input, config, preliminaryRepresentatives);
    diagnosticRows(pathIndex, :) = {paths(pathIndex), logical(loaded.available), ...
        string(loaded.reason), string(loaded.semantic_hash), false};
    if loaded.available
        validCount = validCount + 1;
        validCandidates{validCount, 1} = loaded;
    end
end
diagnosticRows = diagnosticRows(1:numel(paths), :);
validCandidates = validCandidates(1:validCount);
if isempty(validCandidates)
    convergence = empty_convergence("machine-precision-only-no-compatible-artifact");
    convergence.diagnostics = diagnostic_table(diagnosticRows);
    return;
end
semanticHashes = string(cellfun(@(value) value.semantic_hash, validCandidates, "UniformOutput", false));
if numel(unique(semanticHashes)) > 1
    error("teleopDelay:AnalysisConvergenceAmbiguous", ...
        "Multiple compatible convergence artifacts contain different semantic content.");
end
convergence = validCandidates{1};
convergence.source = "saved-convergence-artifact";
diagnostics = diagnostic_table(diagnosticRows);
diagnostics.selected(:) = false;
firstValid = find(diagnostics.valid, 1, "first");
if ~isempty(firstValid)
    diagnostics.selected(firstValid) = true;
end
convergence.diagnostics = diagnostics;
end

function convergence = try_load(file, input, config, preliminaryRepresentatives)
convergence = empty_convergence("invalid");
convergence.path = string(file);
try
    data = load(file);
catch exception
    convergence.reason = "load failed: " + string(exception.identifier);
    return;
end
[valid, reason, value, metadata, semanticHash] = validate_candidate( ...
    data, input, config, preliminaryRepresentatives);
convergence.reason = reason;
convergence.semantic_hash = semanticHash;
if ~valid
    return;
end
convergence.available = true;
convergence.table = value.table;
convergence.metadata = metadata;
end

function [valid, reason, value, metadata, semanticHash] = validate_candidate( ...
        data, input, config, preliminaryRepresentatives)
valid = false;
value = struct("table", teleopdelay.analysis.convergence_table());
metadata = struct();
semanticHash = "";
try
    expectedPlan = teleopdelay.analysis.convergence_plan(input, ...
        preliminaryRepresentatives, config);
catch exception
    reason = "expected representative plan is invalid: " + string(exception.message);
    return;
end
if ~isfield(data, "convergence_artifact") || ~isstruct(data.convergence_artifact) || ...
        ~isscalar(data.convergence_artifact) || ...
        ~isfield(data.convergence_artifact, "available") || ...
        ~islogical(data.convergence_artifact.available) || ...
        ~isscalar(data.convergence_artifact.available) || ...
        ~data.convergence_artifact.available || ...
        ~isfield(data.convergence_artifact, "table") || ...
        ~istable(data.convergence_artifact.table) || ...
        isempty(data.convergence_artifact.table) || ...
        ~isfield(data.convergence_artifact, "metadata") || ...
        ~isstruct(data.convergence_artifact.metadata) || ...
        ~isscalar(data.convergence_artifact.metadata)
    reason = "convergence artifact is missing, unavailable, empty, or incomplete";
    return;
end
value = data.convergence_artifact;
if ~isfield(data, "metadata") || ~isstruct(data.metadata) || ~isscalar(data.metadata) || ...
        ~isfield(data, "convergence_metadata") || ...
        ~isstruct(data.convergence_metadata) || ~isscalar(data.convergence_metadata) || ...
        ~isfield(data, "analysis_schema_version") || ...
        ~isfield(data, "convergence_schema_version")
    reason = "artifact metadata or schema version is missing";
    return;
end
metadata = data.convergence_metadata;
if ~isequaln(value.metadata, data.convergence_metadata) || ...
        ~isfield(data.metadata, "convergence_metadata") || ...
        ~isequaln(data.metadata.convergence_metadata, data.convergence_metadata)
    reason = "convergence artifact metadata does not match top-level metadata";
    return;
end
if string(data.analysis_schema_version) ~= string(config.analysis_schema_version) || ...
        string(data.metadata.analysis_schema_version) ~= string(config.analysis_schema_version) || ...
        string(metadata.analysis_schema_version) ~= string(config.analysis_schema_version) || ...
        string(data.convergence_schema_version) ~= string(config.convergence.schema_version) || ...
        string(metadata.convergence_schema_version) ~= string(config.convergence.schema_version)
    reason = "analysis or convergence schema version mismatch";
    return;
end
if ~isfield(data.metadata, "source_mat_sha256") || ...
        string(data.metadata.source_mat_sha256) ~= string(input.source_mat_sha256) || ...
        ~isfield(metadata, "source_mat_sha256") || ...
        string(metadata.source_mat_sha256) ~= string(input.source_mat_sha256) || ...
        ~isfield(metadata, "source_experiment_id") || ...
        string(metadata.source_experiment_id) ~= string(input.source_experiment_id)
    reason = "source MAT identity does not match the input artifact";
    return;
end
requiredMetadata = ["solver", "base_fixed_step_s", "refined_fixed_step_s", ...
    "sample_period_s", "alignment_ratio", "alignment_valid", "convergence_case_ids"];
if ~all(isfield(metadata, requiredMetadata)) || ...
        string(metadata.solver) ~= string(config.convergence.solver) || ...
        ~close_enough(metadata.base_fixed_step_s, config.convergence.base_fixed_step_s) || ...
        ~close_enough(metadata.refined_fixed_step_s, config.convergence.refined_fixed_step_s) || ...
        ~close_enough(metadata.sample_period_s, config.convergence.sample_period_s) || ...
        ~islogical(metadata.alignment_valid) || ~isscalar(metadata.alignment_valid) || ...
        ~metadata.alignment_valid
    reason = "convergence configuration metadata mismatch";
    return;
end
required = teleopdelay.analysis.convergence_table().Properties.VariableNames;
tableValue = value.table;
variables = string(tableValue.Properties.VariableNames);
if ~all(ismember(string(required), variables)) || isempty(tableValue)
    reason = "required convergence columns are missing or empty";
    return;
end
if ~isstring(tableValue.role) || ~isstring(tableValue.role_mapping) || ...
        ~isstring(tableValue.trajectory) || ~isstring(tableValue.case_id) || ...
        ~islogical(tableValue.sample_alignment_valid) || ...
        ~isstring(tableValue.convergence_status)
    reason = "convergence text or logical columns have incompatible types";
    return;
end
ids = string(tableValue.case_id);
metadataIds = string(metadata.convergence_case_ids(:));
expectedIds = string(expectedPlan.case_ids(:));
if height(tableValue) ~= expectedPlan.case_count || ...
        numel(unique(ids)) ~= height(tableValue) || any(strlength(ids) == 0) || ...
        ~isequal(sort(ids), sort(expectedIds)) || ...
        ~isequal(sort(metadataIds), sort(expectedIds)) || ...
        numel(unique(metadataIds)) ~= numel(metadataIds)
    reason = "convergence case_id set or row count does not match the expected representative plan";
    return;
end
if any(string(tableValue.convergence_status) ~= "validated") || ...
        any(~tableValue.sample_alignment_valid)
    reason = "convergence rows are not all validated and aligned";
    return;
end
numericNames = setdiff(string(required), ["role", "role_mapping", "trajectory", "case_id", ...
    "sample_alignment_valid", "convergence_status"]);
for name = numericNames
    column = tableValue.(char(name));
    if ~isnumeric(column) || ~isreal(column) || any(~isfinite(double(column)))
        reason = "convergence numeric columns contain invalid values";
        return;
    end
end
for index = 1:expectedPlan.case_count
    expected = expectedPlan.table(index, :);
    rowIndex = find(ids == expected.case_id, 1);
    actual = tableValue(rowIndex, :);
    if actual.role ~= expected.primary_role || actual.role_mapping ~= expected.role_mapping || ...
            actual.trajectory ~= expected.trajectory || ...
            ~close_enough(actual.omega_rad_s, expected.omega_rad_s) || ...
            ~close_enough(actual.delay_s, expected.delay_s) || ...
            ~close_enough(actual.base_fixed_step_s, expected.base_fixed_step_s) || ...
            ~close_enough(actual.sample_period_s, expected.sample_period_s) || ...
            ~close_enough(actual.base_rmse_zoh_m, expected.base_rmse_zoh_m) || ...
            ~close_enough(actual.base_rmse_cv_m, expected.base_rmse_cv_m) || ...
            ~close_enough(actual.base_performance_ratio, expected.base_performance_ratio) || ...
            ~close_enough(actual.base_max_error_zoh_m, expected.base_max_error_zoh_m) || ...
            ~close_enough(actual.base_max_error_cv_m, expected.base_max_error_cv_m)
        reason = "convergence row does not match the expected representative case, role, condition, or base metrics";
        return;
    end
end
if any(abs(double(tableValue.base_fixed_step_s) - config.convergence.base_fixed_step_s) > ...
        row_tolerance(double(tableValue.base_fixed_step_s), config.convergence.base_fixed_step_s), "all") || ...
        any(abs(double(tableValue.refined_fixed_step_s) - config.convergence.refined_fixed_step_s) > ...
        row_tolerance(double(tableValue.refined_fixed_step_s), config.convergence.refined_fixed_step_s), "all") || ...
        any(abs(double(tableValue.sample_period_s) - config.convergence.sample_period_s) > ...
        row_tolerance(double(tableValue.sample_period_s), config.convergence.sample_period_s), "all")
    reason = "convergence table step or sample period mismatch";
    return;
end
if any(abs(double(tableValue.delta_performance_ratio) - ...
        (double(tableValue.refined_performance_ratio) - double(tableValue.base_performance_ratio))) > ...
        row_tolerance(double(tableValue.delta_performance_ratio), ...
        double(tableValue.refined_performance_ratio) - double(tableValue.base_performance_ratio)), "all")
    reason = "delta_performance_ratio is inconsistent with refined-base";
    return;
end
relativeNames = ["relative_delta_rmse_zoh", "relative_delta_rmse_cv", ...
    "relative_delta_performance_ratio", "relative_delta_max_error_zoh", ...
    "relative_delta_max_error_cv"];
baseNames = ["base_rmse_zoh_m", "base_rmse_cv_m", "base_performance_ratio", ...
    "base_max_error_zoh_m", "base_max_error_cv_m"];
refinedNames = ["refined_rmse_zoh_m", "refined_rmse_cv_m", "refined_performance_ratio", ...
    "refined_max_error_zoh_m", "refined_max_error_cv_m"];
for index = 1:numel(relativeNames)
    expected = relative_value(tableValue.(char(refinedNames(index))), ...
        tableValue.(char(baseNames(index))));
    actual = double(tableValue.(char(relativeNames(index))));
    if any(abs(actual - expected) > row_tolerance(actual, expected), "all")
        reason = "relative convergence delta is inconsistent with the stored metrics";
        return;
    end
end
expectedRatio = double(metadata.sample_period_s) / double(metadata.refined_fixed_step_s);
if ~close_enough(metadata.alignment_ratio, expectedRatio) || ...
        any(abs(double(tableValue.sample_alignment_ratio) - expectedRatio) > ...
        row_tolerance(double(tableValue.sample_alignment_ratio), expectedRatio), "all")
    reason = "sample alignment metadata is inconsistent";
    return;
end
semanticHash = semantic_hash(tableValue, metadata, data);
valid = true;
reason = "valid";
end

function value = relative_value(refined, base)
floorValue = 64 * eps(max([1; abs(double(base(:))); abs(double(refined(:)))]));
value = abs(double(refined) - double(base)) ./ max(abs(double(base)), floorValue);
end

function tolerance = row_tolerance(first, second)
first = double(first(:));
second = double(second(:));
count = max(numel(first), numel(second));
if isscalar(first)
    first = repmat(first, count, 1);
end
if isscalar(second)
    second = repmat(second, count, 1);
end
tolerance = 128 * eps(max([ones(count, 1), abs(first), abs(second)], [], 2));
end

function result = close_enough(first, second)
result = isscalar(first) && isscalar(second) && isreal(first) && isreal(second) && ...
    isfinite(first) && isfinite(second) && abs(double(first) - double(second)) <= ...
    128 * eps(max([1, abs(double(first)), abs(double(second))]));
end

function digest = semantic_hash(tableValue, metadata, data)
sortedTable = sortrows(tableValue, "case_id");
payload = struct();
for name = string(sortedTable.Properties.VariableNames)
    value = sortedTable.(char(name));
    if isstring(value)
        payload.(char(name)) = cellstr(value);
    else
        payload.(char(name)) = value;
    end
end
payload.metadata = struct( ...
    "analysis_schema_version", string(metadata.analysis_schema_version), ...
    "convergence_schema_version", string(metadata.convergence_schema_version), ...
    "source_mat_sha256", string(metadata.source_mat_sha256), ...
    "source_experiment_id", string(metadata.source_experiment_id), ...
    "solver", string(metadata.solver), ...
    "base_fixed_step_s", double(metadata.base_fixed_step_s), ...
    "refined_fixed_step_s", double(metadata.refined_fixed_step_s), ...
    "sample_period_s", double(metadata.sample_period_s), ...
    "alignment_ratio", double(metadata.alignment_ratio), ...
    "convergence_case_ids", cellstr(sort(string(metadata.convergence_case_ids))));
payload.artifact_analysis_schema_version = string(data.analysis_schema_version);
payload.artifact_convergence_schema_version = string(data.convergence_schema_version);
digest = teleopdelay.analysis.sha256_text(jsonencode(payload));
end

function convergence = empty_convergence(source)
convergence = struct("available", false, "source", string(source), ...
    "table", teleopdelay.analysis.convergence_table(), "metadata", struct(), ...
    "diagnostics", diagnostic_table(cell(0, 5)), "path", "", ...
    "reason", string(source), "semantic_hash", "");
end

function diagnostics = diagnostic_table(rows)
if isempty(rows)
    diagnostics = table('Size', [0, 5], 'VariableTypes', ...
        ["string", "logical", "string", "string", "logical"], ...
        'VariableNames', {'candidate_path', 'valid', 'reason', 'semantic_hash', 'selected'});
else
    diagnostics = cell2table(rows, 'VariableNames', ...
        {'candidate_path', 'valid', 'reason', 'semantic_hash', 'selected'});
    diagnostics.candidate_path = string(diagnostics.candidate_path);
    diagnostics.valid = logical(diagnostics.valid);
    diagnostics.reason = string(diagnostics.reason);
    diagnostics.semantic_hash = string(diagnostics.semantic_hash);
    diagnostics.selected = logical(diagnostics.selected);
end
end

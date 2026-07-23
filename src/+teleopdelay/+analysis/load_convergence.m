function convergence = load_convergence(input, convergenceMat, outputRoot, config, explicitRequested)
% load_convergence  Load and semantically validate a convergence supplement.

if nargin < 5
    explicitRequested = false;
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
    loaded = try_load(candidate, input, config);
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
    loaded = try_load(paths(pathIndex), input, config);
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

function convergence = try_load(file, input, config)
convergence = empty_convergence("invalid");
convergence.path = string(file);
try
    data = load(file);
catch exception
    convergence.reason = "load failed: " + string(exception.identifier);
    return;
end
[valid, reason, value, metadata, semanticHash] = validate_candidate(data, input, config);
convergence.reason = reason;
convergence.semantic_hash = semanticHash;
if ~valid
    return;
end
convergence.available = true;
convergence.table = value.table;
convergence.metadata = metadata;
end

function [valid, reason, value, metadata, semanticHash] = validate_candidate(data, input, config)
valid = false;
reason = "invalid convergence artifact"; %#ok<NASGU>
value = struct();
metadata = struct();
semanticHash = "";
if ~isfield(data, "convergence_artifact") || ~isstruct(data.convergence_artifact) || ...
        ~isscalar(data.convergence_artifact) || ~isfield(data.convergence_artifact, "available") || ...
        ~logical(data.convergence_artifact.available) || ~isfield(data.convergence_artifact, "table") || ...
        ~istable(data.convergence_artifact.table) || isempty(data.convergence_artifact.table)
    reason = "convergence table is missing or empty";
    return;
end
value = data.convergence_artifact;
if ~isfield(data, "metadata") || ~isstruct(data.metadata) || ~isscalar(data.metadata) || ...
        ~isfield(data, "convergence_metadata") || ~isstruct(data.convergence_metadata) || ...
        ~isscalar(data.convergence_metadata) || ~isfield(data, "analysis_schema_version") || ...
        ~isfield(data, "convergence_schema_version")
    reason = "artifact metadata or schema version is missing";
    return;
end
metadata = data.convergence_metadata;
if string(data.analysis_schema_version) ~= string(config.analysis_schema_version) || ...
        string(data.metadata.analysis_schema_version) ~= string(config.analysis_schema_version) || ...
        string(data.convergence_schema_version) ~= string(config.convergence.schema_version) || ...
        string(metadata.analysis_schema_version) ~= string(config.analysis_schema_version) || ...
        string(metadata.convergence_schema_version) ~= string(config.convergence.schema_version)
    reason = "analysis or convergence schema version mismatch";
    return;
end
if ~isfield(data.metadata, "source_mat_sha256") || ...
        string(data.metadata.source_mat_sha256) ~= string(input.source_mat_sha256) || ...
        ~isfield(metadata, "source_mat_sha256") || ...
        string(metadata.source_mat_sha256) ~= string(input.source_mat_sha256)
    reason = "source MAT SHA-256 mismatch";
    return;
end
requiredMetadata = ["solver", "base_fixed_step_s", "refined_fixed_step_s", ...
    "sample_period_s", "alignment_ratio", "alignment_valid", "convergence_case_ids"];
if ~all(isfield(metadata, requiredMetadata)) || string(metadata.solver) ~= string(config.convergence.solver) || ...
        ~close_enough(metadata.base_fixed_step_s, config.convergence.base_fixed_step_s) || ...
        ~close_enough(metadata.refined_fixed_step_s, config.convergence.refined_fixed_step_s) || ...
        ~close_enough(metadata.sample_period_s, config.convergence.sample_period_s) || ...
        ~logical(metadata.alignment_valid)
    reason = "convergence configuration metadata mismatch";
    return;
end
required = teleopdelay.analysis.convergence_table().Properties.VariableNames;
variables = string(value.table.Properties.VariableNames);
if ~all(ismember(string(required), variables)) || isempty(value.table)
    reason = "required convergence columns are missing or empty";
    return;
end
ids = string(value.table.case_id);
metadataIds = string(metadata.convergence_case_ids(:));
inputIds = cellfun(@(value) string(value.case_id), input.cases);
if numel(unique(ids)) ~= height(value.table) || any(strlength(ids) == 0) || ...
        ~all(ismember(ids, inputIds)) || ...
        numel(unique(metadataIds)) ~= numel(metadataIds) || ~isequal(sort(ids), sort(metadataIds))
    reason = "convergence case_id set is not unique or does not match metadata";
    return;
end
if any(string(value.table.convergence_status) ~= "validated") || ...
        any(~logical(value.table.sample_alignment_valid))
    reason = "convergence rows are not all validated and aligned";
    return;
end
numericNames = setdiff(string(required), ["role", "role_mapping", "trajectory", "case_id", ...
    "sample_alignment_valid", "convergence_status"]);
for name = numericNames
    column = value.table.(char(name));
    if ~isnumeric(column) || ~isreal(column) || any(~isfinite(double(column)))
        reason = "convergence numeric columns contain invalid values";
        return;
    end
end
if any(abs(double(value.table.base_fixed_step_s) - config.convergence.base_fixed_step_s) > ...
        row_tolerance(double(value.table.base_fixed_step_s), config.convergence.base_fixed_step_s), "all") || ...
        any(abs(double(value.table.refined_fixed_step_s) - config.convergence.refined_fixed_step_s) > ...
        row_tolerance(double(value.table.refined_fixed_step_s), config.convergence.refined_fixed_step_s), "all") || ...
        any(abs(double(value.table.sample_period_s) - config.convergence.sample_period_s) > ...
        row_tolerance(double(value.table.sample_period_s), config.convergence.sample_period_s), "all")
    reason = "convergence table step or sample period mismatch";
    return;
end
if any(abs(double(value.table.delta_performance_ratio) - ...
        (double(value.table.refined_performance_ratio) - double(value.table.base_performance_ratio))) > ...
        row_tolerance(double(value.table.delta_performance_ratio), ...
        double(value.table.refined_performance_ratio) - double(value.table.base_performance_ratio)), "all")
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
    expected = relative_value(value.table.(char(refinedNames(index))), ...
        value.table.(char(baseNames(index))));
    actual = double(value.table.(char(relativeNames(index))));
    if any(abs(actual - expected) > row_tolerance(actual, expected), "all")
        reason = "relative convergence delta is inconsistent with the stored metrics";
        return;
    end
end
expectedRatio = double(metadata.sample_period_s) / double(metadata.refined_fixed_step_s);
if ~close_enough(metadata.alignment_ratio, expectedRatio) || ...
        any(abs(double(value.table.sample_alignment_ratio) - expectedRatio) > ...
        row_tolerance(double(value.table.sample_alignment_ratio), expectedRatio), "all")
    reason = "sample alignment metadata is inconsistent";
    return;
end
semanticHash = semantic_hash(value.table, metadata, data);
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

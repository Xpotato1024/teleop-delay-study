function convergence = load_convergence(input, convergenceMat, outputRoot, config)
% load_convergence  Load an explicit or deterministically discoverable supplement.

candidate = string(convergenceMat);
if strlength(candidate) == 0
    pattern = fullfile(char(outputRoot), "analysis", char(input.source_experiment_id), ...
        "*", "*", "analysis_tables.mat");
    files = dir(pattern);
    paths = strings(0, 1);
    for index = 1:numel(files)
        paths(end + 1) = string(fullfile(files(index).folder, files(index).name)); %#ok<AGROW>
    end
    paths = sort(paths);
    for pathIndex = 1:numel(paths)
        loaded = try_load(paths(pathIndex), input, config);
        if loaded.available
            convergence = loaded;
            convergence.source = "saved-convergence-artifact";
            return;
        end
    end
    convergence = empty_convergence("machine-precision-only-no-artifact");
    return;
end
if ~isfile(candidate)
    error("teleopDelay:AnalysisConvergenceMissing", ...
        "The explicit ConvergenceMat does not exist: %s", candidate);
end
loaded = try_load(candidate, input, config);
if ~loaded.available
    error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
        "The explicit convergence artifact does not match the input MAT.");
end
loaded.source = "explicit-saved-convergence-artifact";
convergence = loaded;
end

function convergence = try_load(file, input, config) %#ok<INUSD>
convergence = empty_convergence("invalid");
try
    data = load(file, "convergence", "metadata");
catch
    return;
end
if ~isfield(data, "convergence")
    return;
end
value = data.convergence;
if isstruct(value) && isfield(value, "available")
    if value.available && isfield(value, "table") && istable(value.table)
        convergence = value;
    end
elseif istable(value)
    convergence.available = true;
    convergence.table = value;
end
if convergence.available && isfield(data, "metadata") && isfield(data.metadata, "source_mat_sha256")
    convergence.available = string(data.metadata.source_mat_sha256) == string(input.source_mat_sha256);
end
if convergence.available
    required = ["case_id", "base_performance_ratio", "refined_performance_ratio", ...
        "delta_performance_ratio"];
    convergence.available = all(ismember(required, string(convergence.table.Properties.VariableNames)));
end
end

function convergence = empty_convergence(source)
convergence = struct("available", false, "source", string(source), ...
    "table", teleopdelay.analysis.convergence_table(), "metadata", struct());
end

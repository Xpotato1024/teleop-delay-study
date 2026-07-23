function layout = condition_map_layout(classification, brackets, trajectory)
% condition_map_layout  Build an index-coordinate discrete condition map.

required = ["trajectory", "omega_rad_s", "delay_s", "performance_ratio"];
if ~istable(classification) || ~all(ismember(required, string(classification.Properties.VariableNames)))
    error("teleopDelay:AnalysisConditionGridSchemaMismatch", ...
        "Classification table cannot define the condition grid.");
end
trajectory = string(trajectory);
subset = classification(classification.trajectory == trajectory, :);
if isempty(subset)
    error("teleopDelay:AnalysisConditionGridMismatch", ...
        "No classification rows exist for trajectory %s.", trajectory);
end
omegas = sort(unique(double(subset.omega_rad_s))).';
delays = sort(unique(double(subset.delay_s))).';
if numel(omegas) ~= 4 || numel(delays) ~= 5 || ...
        any(~isfinite(omegas)) || any(~isfinite(delays)) || ...
        any(diff(omegas) <= 0) || any(diff(delays) <= 0)
    error("teleopDelay:AnalysisConditionGridMismatch", ...
        "The condition grid must contain four omega and five delay values.");
end
map = nan(numel(delays), numel(omegas));
for rowIndex = 1:numel(delays)
    for columnIndex = 1:numel(omegas)
        matches = close_rows(double(subset.delay_s), delays(rowIndex)) & ...
            close_rows(double(subset.omega_rad_s), omegas(columnIndex));
        if sum(matches) ~= 1
            error("teleopDelay:AnalysisConditionGridMismatch", ...
                "Expected exactly one case at delay %.17g and omega %.17g.", ...
                delays(rowIndex), omegas(columnIndex));
        end
        map(rowIndex, columnIndex) = double(subset.performance_ratio(matches));
    end
end
if any(~isfinite(map), "all")
    error("teleopDelay:AnalysisConditionGridMetricInvalid", ...
        "Condition-map performance ratios must be finite.");
end

requiredBracket = ["trajectory", "bracket_type", "lower_delay_s", ...
    "upper_delay_s", "lower_omega_rad_s", "upper_omega_rad_s", ...
    "lower_case_id", "upper_case_id"];
if ~istable(brackets) || ~all(ismember(requiredBracket, string(brackets.Properties.VariableNames)))
    error("teleopDelay:AnalysisBoundarySchemaMismatch", ...
        "Boundary table cannot define condition-map markers.");
end
selected = brackets(brackets.trajectory == trajectory & ...
    brackets.bracket_type == "improvement-degradation", :);
markers = repmat(marker_template(), height(selected), 1);
for index = 1:height(selected)
    lowerDelay = index_for_value(delays, selected.lower_delay_s(index), "delay");
    upperDelay = index_for_value(delays, selected.upper_delay_s(index), "delay");
    lowerOmega = index_for_value(omegas, selected.lower_omega_rad_s(index), "omega");
    upperOmega = index_for_value(omegas, selected.upper_omega_rad_s(index), "omega");
    if selected.lower_delay_s(index) == selected.upper_delay_s(index)
        markerX = [lowerOmega + 0.25, upperOmega + 0.25];
        markerY = [lowerDelay, upperDelay];
    elseif selected.lower_omega_rad_s(index) == selected.upper_omega_rad_s(index)
        markerX = [lowerOmega, upperOmega];
        markerY = [lowerDelay + 0.25, upperDelay + 0.25];
    else
        error("teleopDelay:AnalysisBoundaryGridMismatch", ...
            "Boundary marker is not an adjacent one-axis grid pair.");
    end
    markers(index) = struct( ...
        "lower_case_id", string(selected.lower_case_id(index)), ...
        "upper_case_id", string(selected.upper_case_id(index)), ...
        "lower_delay_index", lowerDelay, "upper_delay_index", upperDelay, ...
        "lower_omega_index", lowerOmega, "upper_omega_index", upperOmega, ...
        "x", markerX, "y", markerY);
end
layout = struct( ...
    "trajectory", trajectory, "omegas", omegas, "delays", delays, ...
    "omega_index", 1:numel(omegas), "delay_index", 1:numel(delays), ...
    "map", map, "selected_brackets", selected, "markers", markers);
end

function result = close_rows(values, target)
result = abs(values - target) <= 128 * eps(max([1, abs(values(:).'), abs(target)]));
result = result(:);
end

function index = index_for_value(values, target, axisName)
matches = close_rows(values, double(target));
if sum(matches) ~= 1
    error("teleopDelay:AnalysisBoundaryGridValueMissing", ...
        "Boundary %s value %.17g is not present exactly once in the condition grid.", ...
        axisName, double(target));
end
index = find(matches, 1);
end

function marker = marker_template()
marker = struct("lower_case_id", "", "upper_case_id", "", ...
    "lower_delay_index", 0, "upper_delay_index", 0, ...
    "lower_omega_index", 0, "upper_omega_index", 0, "x", [], "y", []);
end

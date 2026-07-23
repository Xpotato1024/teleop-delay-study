function representatives = select_representatives(input, classification, config)
% select_representatives  Select analysis cases using metrics and case_id ties.

trajectoryNames = ["circle", "lissajous_1_2"];
rows = cell(0, 7);
for trajectoryName = trajectoryNames
    subset = classification(classification.trajectory == trajectoryName, :);
    row = choose_best(subset);
    fallback = false;
    rows(end + 1, :) = role_row(trajectoryName, "best_improvement", row, ...
        "improvement_percent", row.improvement_percent, ...
        "Maximum improvement_percent; ties use minimum G then case_id.", fallback); %#ok<AGROW>
    [row, fallback, role] = choose_worst(subset);
    if fallback
        reason = "No degradation case; nearest G=1 case used as documented fallback.";
    else
        reason = "Maximum degradation G; ties use case_id.";
    end
    rows(end + 1, :) = role_row(trajectoryName, role, row, ...
        "performance_ratio", row.performance_ratio, reason, fallback); %#ok<AGROW>
    row = choose_nearest(subset);
    rows(end + 1, :) = role_row(trajectoryName, "nearest_boundary", row, ...
        "abs(G-1)", row.boundary_distance, ...
        "Minimum absolute distance from G=1; ties use case_id.", false); %#ok<AGROW>
    row = choose_max_metric(subset, "max_error_zoh_m");
    rows(end + 1, :) = role_row(trajectoryName, "maximum_instantaneous_error_zoh", row, ...
        "max_error_zoh_m", row.max_error_zoh_m, ...
        "Maximum saved ZOH instantaneous error metric; ties use case_id.", false); %#ok<AGROW>
    row = choose_max_metric(subset, "max_error_cv_m");
    rows(end + 1, :) = role_row(trajectoryName, "maximum_instantaneous_error_cv", row, ...
        "max_error_cv_m", row.max_error_cv_m, ...
        "Maximum saved CV instantaneous error metric; ties use case_id.", false); %#ok<AGROW>
    if trajectoryName == "lissajous_1_2"
        row = choose_worst_by_ratio(subset);
        caseResult = find_case(input, row.case_id);
        evalMask = logical(caseResult.evaluation.mask);
        acceleration = vecnorm(double(caseResult.trajectory.acceleration_mps2), 2, 2);
        acceleration = acceleration(evalMask);
        eventTime = double(caseResult.trajectory.time_s(evalMask));
        [~, eventThreshold] = teleopdelay.analysis.event_acceleration_mask( ...
            acceleration, config.event_acceleration_percentile);
        [maximumAcceleration, eventIndex] = max(acceleration);
        eventText = "direction-change/high-acceleration diagnostic; " + ...
            compose("events use %.17gth percentile threshold=%.9g m/s^2; ", ...
            config.event_acceleration_percentile, eventThreshold) + ...
            "peak acceleration=" + ...
            compose("%.9g", maximumAcceleration) + " m/s^2 at t=" + ...
            compose("%.9g", eventTime(eventIndex)) + " s; association is observational.";
        rows(end + 1, :) = role_row(trajectoryName, "lissajous_direction_change", row, ...
            "performance_ratio", row.performance_ratio, eventText, false); %#ok<AGROW>
    end
end
representatives = cell2table(rows, 'VariableNames', ...
    {'trajectory', 'role', 'case_id', 'selection_metric', 'selected_value', ...
    'selection_reason', 'fallback_used'});
representatives.selected_value = double(representatives.selected_value);
representatives.fallback_used = logical(representatives.fallback_used);
end

function row = choose_best(subset)
work = subset;
work.score = -double(work.improvement_percent);
work = sortrows(work, {'score', 'performance_ratio', 'case_id'}, ...
    {'ascend', 'ascend', 'ascend'});
row = work(1, :);
end

function [row, fallback, role] = choose_worst(subset)
degradation = subset(subset.classification == "degradation", :);
if isempty(degradation)
    row = choose_nearest(subset);
    fallback = true;
    role = "worst_degradation_fallback";
    return;
end
work = sortrows(degradation, {'performance_ratio', 'case_id'}, ...
    {'descend', 'ascend'});
row = work(1, :);
fallback = false;
role = "worst_degradation";
end

function row = choose_nearest(subset)
work = sortrows(subset, {'boundary_distance', 'case_id'}, {'ascend', 'ascend'});
row = work(1, :);
end

function row = choose_max_metric(subset, metric)
work = sortrows(subset, {char(metric), 'case_id'}, {'descend', 'ascend'});
row = work(1, :);
end

function row = choose_worst_by_ratio(subset)
work = sortrows(subset, {'performance_ratio', 'case_id'}, {'descend', 'ascend'});
row = work(1, :);
end

function caseResult = find_case(input, caseId)
ids = cellfun(@(value) string(value.case_id), input.cases);
index = find(ids == string(caseId), 1);
caseResult = input.cases{index};
end

function row = role_row(trajectory, role, selected, metric, value, reason, fallback)
row = {string(trajectory), string(role), string(selected.case_id), string(metric), ...
    double(value), string(reason), logical(fallback)};
end

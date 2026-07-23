function brackets = detect_boundaries(classification, theory, config) %#ok<INUSD>
% detect_boundaries  Extract only adjacent pairs from each 5-by-4 grid.

rows = cell(0, 19);
trajectoryNames = ["circle", "lissajous_1_2"];
for trajectoryName = trajectoryNames
    subset = classification(classification.trajectory == trajectoryName, :);
    candidates = cell(0, 19);
    for omega = unique(subset.omega_rad_s).'
        pair = sortrows(subset(subset.omega_rad_s == omega, :), "delay_s");
        for index = 1:height(pair)-1
            if is_direct(pair(index, :), pair(index + 1, :))
                candidates(end + 1, :) = bracket_row(pair(index, :), pair(index + 1, :), ...
                    "delay", omega, "improvement-degradation"); %#ok<AGROW>
            elseif has_equivalent(pair(index, :), pair(index + 1, :))
                candidates(end + 1, :) = bracket_row(pair(index, :), pair(index + 1, :), ...
                    "delay", omega, "equivalent-adjacent"); %#ok<AGROW>
            end
        end
    end
    for delay = unique(subset.delay_s).'
        pair = sortrows(subset(subset.delay_s == delay, :), "omega_rad_s");
        for index = 1:height(pair)-1
            if is_direct(pair(index, :), pair(index + 1, :))
                candidates(end + 1, :) = bracket_row(pair(index, :), pair(index + 1, :), ...
                    "omega", delay, "improvement-degradation"); %#ok<AGROW>
            elseif has_equivalent(pair(index, :), pair(index + 1, :))
                candidates(end + 1, :) = bracket_row(pair(index, :), pair(index + 1, :), ...
                    "omega", delay, "equivalent-adjacent"); %#ok<AGROW>
            end
        end
    end
    allPairs = cell(0, 19);
    for omega = unique(subset.omega_rad_s).'
        pair = sortrows(subset(subset.omega_rad_s == omega, :), "delay_s");
        for index = 1:height(pair)-1
            allPairs(end + 1, :) = bracket_row(pair(index, :), pair(index + 1, :), ...
                "delay", omega, "nearest-G-pair"); %#ok<AGROW>
        end
    end
    for delay = unique(subset.delay_s).'
        pair = sortrows(subset(subset.delay_s == delay, :), "omega_rad_s");
        for index = 1:height(pair)-1
            allPairs(end + 1, :) = bracket_row(pair(index, :), pair(index + 1, :), ...
                "omega", delay, "nearest-G-pair"); %#ok<AGROW>
        end
    end
    if ~isempty(allPairs)
        candidates(end + 1, :) = choose_nearest_pair(allPairs); %#ok<AGROW>
    end
    rows = [rows; candidates]; %#ok<AGROW>
end
brackets = cell2table(rows, 'VariableNames', { ...
    'trajectory', 'varied_axis', 'fixed_axis_value', 'lower_case_id', 'upper_case_id', ...
    'lower_delay_s', 'upper_delay_s', 'lower_omega_rad_s', 'upper_omega_rad_s', ...
    'lower_G', 'upper_G', 'lower_q_delay', 'upper_q_delay', 'lower_q_age', 'upper_q_age', ...
    'bracket_type', 'interpolation_used', 'interpolation_note', 'grid_adjacency'});
brackets.interpolation_used = logical(brackets.interpolation_used);
brackets.fixed_axis_value = double(brackets.fixed_axis_value);
end

function value = is_direct(lower, upper)
value = (lower.classification == "improvement" && upper.classification == "degradation") || ...
    (lower.classification == "degradation" && upper.classification == "improvement");
end

function value = has_equivalent(lower, upper)
value = lower.classification == "equivalent" || upper.classification == "equivalent";
end

function row = bracket_row(lower, upper, variedAxis, fixedValue, bracketType)
row = {string(lower.trajectory), string(variedAxis), double(fixedValue), ...
    string(lower.case_id), string(upper.case_id), double(lower.delay_s), double(upper.delay_s), ...
    double(lower.omega_rad_s), double(upper.omega_rad_s), double(lower.performance_ratio), ...
    double(upper.performance_ratio), double(lower.omega_delay), double(upper.omega_delay), ...
    double(lower.omega_mean_packet_age), double(upper.omega_mean_packet_age), ...
    string(bracketType), false, "No interpolation; adjacent discrete grid pair only.", true};
end

function row = choose_nearest_pair(rows)
scores = zeros(size(rows, 1), 1);
for index = 1:size(rows, 1)
    scores(index) = min(abs([double(rows{index, 10}), double(rows{index, 11})] - 1));
end
[~, order] = sort(scores);
row = rows(order(1), :);
row{16} = "nearest-G-pair";
end

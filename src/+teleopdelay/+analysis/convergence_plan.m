function plan = convergence_plan(input, representatives, config)
% convergence_plan  Build the deterministic representative convergence plan.

required = ["trajectory", "role", "case_id"];
if ~istable(representatives) || ~all(ismember(required, string(representatives.Properties.VariableNames)))
    error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
        "Representative table cannot define the convergence study plan.");
end
roleNames = ["best_improvement", "worst_degradation", ...
    "worst_degradation_fallback", "nearest_boundary"];
roleMask = representatives.role == "best_improvement" | ...
    startsWith(representatives.role, "worst_degradation") | ...
    representatives.role == "nearest_boundary";
roleTable = representatives(roleMask, required);
if isempty(roleTable)
    error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
        "Representative table contains no convergence roles.");
end
trajectoryOrder = ["circle", "lissajous_1_2"];
trajectoryRank = zeros(height(roleTable), 1);
roleRank = zeros(height(roleTable), 1);
for index = 1:height(roleTable)
    trajectoryIndex = find(trajectoryOrder == roleTable.trajectory(index), 1);
    roleIndex = find(roleNames == roleTable.role(index), 1);
    if isempty(trajectoryIndex) || isempty(roleIndex)
        error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
            "Representative convergence role is not part of the fixed study plan.");
    end
    trajectoryRank(index) = trajectoryIndex;
    roleRank(index) = roleIndex;
end
roleTable.trajectory_rank = trajectoryRank;
roleTable.role_rank = roleRank;
roleTable = sortrows(roleTable, {'trajectory_rank', 'role_rank', 'case_id'});
roleTable = removevars(roleTable, {'trajectory_rank', 'role_rank'});

inputIds = cellfun(@(value) string(value.case_id), input.cases);
if any(~ismember(string(roleTable.case_id), inputIds))
    unknown = setdiff(string(roleTable.case_id), inputIds);
    if ~isempty(unknown)
        error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
            "Representative convergence case is not present in the input: %s", unknown(1));
    end
end

caseIds = unique(string(roleTable.case_id), "stable");
rows = cell(numel(caseIds), 13);
for index = 1:numel(caseIds)
    caseId = caseIds(index);
    caseResult = find_case(input, caseId);
    roleRows = roleTable(roleTable.case_id == caseId, :);
    roleMapping = strjoin(cellstr(roleRows.role), "|");
    rows(index, :) = {caseId, roleRows.role(1), roleMapping, ...
        string(caseResult.config.trajectory.type), ...
        double(caseResult.config.trajectory.omega), ...
        double(caseResult.config.communication.delay), ...
        double(caseResult.config.simulation.fixed_step), ...
        double(caseResult.config.communication.sample_period), ...
        double(caseResult.evaluation.rmse_zoh_m), ...
        double(caseResult.evaluation.rmse_cv_m), ...
        double(caseResult.evaluation.performance_ratio), ...
        double(caseResult.evaluation.max_error_zoh_m), ...
        double(caseResult.evaluation.max_error_cv_m)};
end
planTable = cell2table(rows, 'VariableNames', ...
    {'case_id', 'primary_role', 'role_mapping', 'trajectory', ...
    'omega_rad_s', 'delay_s', 'base_fixed_step_s', 'sample_period_s', ...
    'base_rmse_zoh_m', 'base_rmse_cv_m', 'base_performance_ratio', ...
    'base_max_error_zoh_m', 'base_max_error_cv_m'});
planTable.case_id = string(planTable.case_id);
planTable.primary_role = string(planTable.primary_role);
planTable.role_mapping = string(planTable.role_mapping);
planTable.trajectory = string(planTable.trajectory);
for name = string(planTable.Properties.VariableNames(5:end))
    planTable.(char(name)) = double(planTable.(char(name)));
end
planTable = sortrows(planTable, {'trajectory', 'delay_s', 'omega_rad_s', 'case_id'});
plan = struct("table", planTable, "role_table", roleTable, ...
    "case_ids", string(planTable.case_id), "case_count", height(planTable), ...
    "base_fixed_step_s", double(config.convergence.base_fixed_step_s), ...
    "sample_period_s", double(config.convergence.sample_period_s));
end

function caseResult = find_case(input, caseId)
ids = cellfun(@(value) string(value.case_id), input.cases);
index = find(ids == string(caseId), 1);
if isempty(index)
    error("teleopDelay:AnalysisConvergenceSchemaMismatch", ...
        "Representative convergence case is missing from input: %s", caseId);
end
caseResult = input.cases{index};
end

function caseResult = case_by_id(input, caseId)
% case_by_id  Retrieve a validated input case by canonical case_id.

ids = cellfun(@(value) string(value.case_id), input.cases);
index = find(ids == string(caseId), 1);
if isempty(index)
    error("teleopDelay:AnalysisInputSchemaMismatch", "Unknown case_id: %s", caseId);
end
caseResult = input.cases{index};
end

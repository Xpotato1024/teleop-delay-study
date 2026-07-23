function context = git_context(projectRoot)
% git_context  Read optional Git metadata without making it a runtime dependency.

projectRoot = char(string(projectRoot));
[shaStatus, shaText] = run_git(projectRoot, "rev-parse HEAD");
[shortStatus, shortText] = run_git(projectRoot, "rev-parse --short HEAD");
[dirtyStatus, dirtyText] = run_git(projectRoot, "status --porcelain");
if shaStatus == 0 && strlength(shaText) > 0
    sha = shaText;
else
    sha = "unknown";
end
if shortStatus == 0 && strlength(shortText) > 0
    shortSha = shortText;
else
    shortSha = "unknown";
end
if dirtyStatus == 0
    if strlength(dirtyText) == 0
        dirtyState = "clean";
    else
        dirtyState = "dirty";
    end
else
    dirtyState = "unknown";
end
context = struct( ...
    "commit_sha", sha, ...
    "short_sha", shortSha, ...
    "dirty_state", dirtyState);
end

function [status, output] = run_git(projectRoot, gitArguments)
command = ['git -C "' projectRoot '" ' char(gitArguments)];
[status, output] = system(command);
output = string(strtrim(output));
end

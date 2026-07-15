function [status, output] = run_project()
% run_project  リポジトリルートから実行するMATLABの単一入口。
%
projectRoot = fileparts(mfilename("fullpath"));
srcDirectory = fullfile(projectRoot, "src");
originalPath = path;
cleanupPath = onCleanup(@() path(originalPath));

addpath(srcDirectory);
[status, output] = teleopdelay.app.main(projectRoot);
end

function status = run_project()
% run_project  リポジトリルートから実行するMATLABの単一入口。
%
% このスケルトンでは設定検証と状態表示だけを行い、実験結果は生成しない。

projectRoot = fileparts(mfilename("fullpath"));
srcDirectory = fullfile(projectRoot, "src");
originalPath = path;
cleanupPath = onCleanup(@() path(originalPath));

addpath(srcDirectory);
status = main();
end

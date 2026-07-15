% smoke_test  MATLABスケルトンの最小限の構成・設定検証。

testRoot = fileparts(fileparts(mfilename('fullpath')));
srcDirectory = fullfile(testRoot, 'src');
originalPath = path;
cleanupPath = onCleanup(@() path(originalPath)); %#ok<NASGU>
addpath(srcDirectory);

config = default_config();
assert(isstruct(config), 'default_config must return a struct.');
assert(validate_config(config), 'The default configuration must be valid.');

invalidConfig = config;
invalidConfig.simulation.dt = -1;
rejected = false;
try
    validate_config(invalidConfig);
catch
    rejected = true;
end
assert(rejected, 'A negative simulation.dt must be rejected.');

requiredDirectories = {
    fullfile(testRoot, 'skills', 'matlab')
    fullfile(testRoot, 'docs')
    fullfile(testRoot, 'docs', 'reports')
    fullfile(testRoot, 'research')
    fullfile(testRoot, 'src')
    fullfile(testRoot, 'tests')
    fullfile(testRoot, 'report')
    fullfile(testRoot, 'report', 'figures')
    fullfile(testRoot, 'results')
    fullfile(testRoot, 'references')
    };
for pathIndex = 1:numel(requiredDirectories)
    assert(isfolder(requiredDirectories{pathIndex}), 'Missing required directory: %s.', requiredDirectories{pathIndex});
end

requiredPaths = {
    fullfile(testRoot, 'AGENTS.md')
    fullfile(testRoot, 'README.md')
    fullfile(testRoot, 'run_project.m')
    fullfile(testRoot, 'skills', 'matlab', 'SKILL.md')
    fullfile(testRoot, 'docs', 'architecture.md')
    fullfile(testRoot, 'research', 'problem_statement.md')
    fullfile(testRoot, 'src', 'main.m')
    fullfile(testRoot, 'src', 'default_config.m')
    fullfile(testRoot, 'src', 'validate_config.m')
    fullfile(testRoot, 'tests', 'smoke_test.m')
    fullfile(testRoot, 'report', 'final_report.md')
    fullfile(testRoot, 'report', 'figures', '.gitkeep')
    fullfile(testRoot, 'results', '.gitkeep')
    fullfile(testRoot, 'references', 'README.md')
    };
for pathIndex = 1:numel(requiredPaths)
    assert(isfile(requiredPaths{pathIndex}), 'Missing required file: %s.', requiredPaths{pathIndex});
end

fprintf('smoke_test passed.\n');

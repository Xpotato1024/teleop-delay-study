function status = smoke_test()
% smoke_test  Issue #2の基盤構造と最小headless実行を検証する。

testRoot = fileparts(fileparts(mfilename("fullpath")));
srcDirectory = fullfile(testRoot, "src");
initialPath = path;
cleanupPath = onCleanup(@() path(initialPath));
addpath(srcDirectory);

config = teleopdelay.config.default_config();
assert(teleopdelay.config.validate_config(config));
assert(isfolder(fullfile(testRoot, "src", "+teleopdelay")));
assert(~isfile(fullfile(testRoot, "src", "main.m")));
assert(~isfile(fullfile(testRoot, "src", "default_config.m")));
assert(~isfile(fullfile(testRoot, "src", "validate_config.m")));

invalidConfig = config;
invalidConfig.simulation.dt = -1;
rejected = false;
try
    teleopdelay.config.validate_config(invalidConfig);
catch
    rejected = true;
end
assert(rejected, "負のsimulation.dtを拒否しなければならない。");

rejected = false;
try
    teleopdelay.timegrid.create(1.0, 0.03);
catch errorInfo
    rejected = strcmp(errorInfo.identifier, "teleopDelay:InvalidTimeGrid");
end
assert(rejected, "整数stepにならないduration / dtを拒否しなければならない。");

paths = teleopdelay.simulink.model_paths(testRoot);
teleopdelay.simulink.validate_models(paths);
assert(isfile(paths.plant));
assert(isfile(paths.communication));
assert(isfile(paths.system));

load_system(paths.plant);
load_system(paths.communication);
load_system(paths.system);
cleanupModels = onCleanup(@() close_models(paths));
modelBlock = [paths.systemModelName '/sampled_communication'];
assert(strcmp(get_param(modelBlock, 'ModelName'), paths.communicationModelName));
set_param(paths.systemModelName, 'SimulationCommand', 'update');
clear cleanupModels;
close_models(paths);

pathBeforeEntry = path;
[status, output] = run_project();
assert(status == 0);
assert_output(output, "circle");
assert(strcmp(pathBeforeEntry, path));
assert(~bdIsLoaded(paths.systemModelName) && ~bdIsLoaded(paths.communicationModelName) && ~bdIsLoaded(paths.plantModelName));

statusOnly = run_project();
assert(statusOnly == 0);
assert(strcmp(pathBeforeEntry, path));

[statusAgain, outputAgain] = run_project();
assert(statusAgain == 0);
assert_output(outputAgain, "circle");
assert(strcmp(pathBeforeEntry, path));

for trajectoryType = ["circle", "lissajous_1_2"]
    caseConfig = config;
    caseConfig.trajectory.type = trajectoryType;
    time_s = teleopdelay.timegrid.create( ...
        caseConfig.simulation.duration, caseConfig.simulation.dt);
    trajectory = teleopdelay.trajectory.generate(time_s, caseConfig.trajectory);
    simulationInput = teleopdelay.simulink.create_simulation_input(paths, caseConfig, trajectory);
    simulation = teleopdelay.simulink.run_case(simulationInput, paths, caseConfig);
    evaluation = teleopdelay.metrics.build_evaluation_window(caseConfig, trajectory, simulation);
    tracking = teleopdelay.metrics.tracking_metrics(caseConfig, trajectory, simulation, evaluation);
    evaluation = merge_structs(evaluation, tracking);
    assert_output(struct("config", caseConfig, "trajectory", trajectory, ...
        "simulation", simulation, "evaluation", evaluation), trajectoryType);
    assert(~bdIsLoaded(paths.systemModelName) && ~bdIsLoaded(paths.communicationModelName) && ~bdIsLoaded(paths.plantModelName));
end

clear cleanupPath;
assert(strcmp(initialPath, path));
fprintf("smoke_test passed.\n");
end

function assert_output(output, trajectoryType)
assert(isstruct(output) && all(isfield(output, ["config", "trajectory", "simulation", "evaluation"])));
assert(strcmp(string(output.trajectory.type), string(trajectoryType)));
trajectory = output.trajectory;
simulation = output.simulation;
N = numel(trajectory.time_s);
assert(isequal(size(trajectory.time_s), [N, 1]));
assert(isequal(size(trajectory.position_m), [N, 2]));
assert(isequal(size(trajectory.velocity_mps), [N, 2]));
assert(isequal(size(trajectory.acceleration_mps2), [N, 2]));
assert(isequal(size(simulation.time_s), [N, 1]));
required = ["zoh_command_xy_m", "cv_command_xy_m", "zoh_position_xy_m", ...
    "cv_position_xy_m", "reference_position_xy_m", "packet_timestamp_s", ...
    "packet_age_s", "packet_valid"];
assert(all(isfield(simulation, required)));
assert(isequal(size(simulation.zoh_command_xy_m), [N, 2]));
assert(isequal(size(simulation.cv_command_xy_m), [N, 2]));
assert(isequal(size(simulation.zoh_position_xy_m), [N, 2]));
assert(isequal(size(simulation.cv_position_xy_m), [N, 2]));
assert(isequal(size(simulation.reference_position_xy_m), [N, 2]));
assert(isequal(size(simulation.packet_timestamp_s), [N, 1]));
assert(isequal(size(simulation.packet_age_s), [N, 1]));
assert(isequal(size(simulation.packet_valid), [N, 1]) && islogical(simulation.packet_valid));
assert(all(isfinite(trajectory.position_m), "all"));
assert(all(isfinite(trajectory.velocity_mps), "all"));
assert(all(isfinite(trajectory.acceleration_mps2), "all"));
assert(all(isfinite(simulation.zoh_command_xy_m), "all"));
assert(all(isfinite(simulation.cv_command_xy_m), "all"));
assert(all(isfinite(simulation.zoh_position_xy_m), "all"));
assert(all(isfinite(simulation.cv_position_xy_m), "all"));
assert(all(isfinite(simulation.reference_position_xy_m), "all"));
assert(all(isfinite(simulation.packet_timestamp_s)) && all(isfinite(simulation.packet_age_s)));
end

function close_models(paths)
if bdIsLoaded(paths.systemModelName)
    close_system(paths.systemModelName, 0);
end
if bdIsLoaded(paths.plantModelName)
    close_system(paths.plantModelName, 0);
end
if bdIsLoaded(paths.communicationModelName)
    close_system(paths.communicationModelName, 0);
end
end

function combined = merge_structs(first, second)
combined = first;
names = fieldnames(second);
for index = 1:numel(names)
    combined.(names{index}) = second.(names{index});
end
end

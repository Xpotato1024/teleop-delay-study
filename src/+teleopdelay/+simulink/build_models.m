function paths = build_models(paths, config)
% build_models  Model Referenceを含む2つのSimulink modelを生成する。

arguments
    paths (1,1) struct
    config (1,1) struct
end
if ~isfolder(paths.plantDirectory)
    mkdir(paths.plantDirectory);
end
if ~isfolder(paths.systemDirectory)
    mkdir(paths.systemDirectory);
end
build_plant(paths, config.plant.time_constant);
build_system(paths, config.plant.time_constant);
end

function build_plant(paths, time_constant_s)
modelName = char(paths.plantModelName);
close_if_loaded(modelName);
new_system(modelName);
cleanup = onCleanup(@() close_if_loaded(modelName));
set_param(modelName, "Solver", "ode4", "FixedStep", "0.01", ...
    "StopTime", "10", "SaveOutput", "off", "SignalLogging", "off");
modelWorkspace = get_param(modelName, "ModelWorkspace");
timeConstantParameter = Simulink.Parameter(time_constant_s);
timeConstantParameter.DataType = "double";
timeConstantParameter.Unit = "s";
assignin(modelWorkspace, "time_constant_s", timeConstantParameter);

inBlock = [modelName '/command_xy_m'];
stateBlock = [modelName '/first_order_state_space'];
outBlock = [modelName '/position_xy_m'];
add_block('simulink/Ports & Subsystems/In1', inBlock, ...
    "Position", [40 95 70 125], "Port", "1");
configure_port(inBlock, "-1");
add_block('simulink/Continuous/State-Space', stateBlock, ...
    "Position", [160 80 330 140], ...
    "A", "[-1/time_constant_s 0; 0 -1/time_constant_s]", ...
    "B", "[1/time_constant_s 0; 0 1/time_constant_s]", ...
    "C", "[1 0; 0 1]", "D", "[0 0; 0 0]", "X0", "[0; 0]");
add_block('simulink/Ports & Subsystems/Out1', outBlock, ...
    "Position", [400 95 430 125], "Port", "1");
configure_port(outBlock, "-1");
add_line(modelName, "command_xy_m/1", "first_order_state_space/1", "autorouting", "on");
add_line(modelName, "first_order_state_space/1", "position_xy_m/1", "autorouting", "on");
set_param(modelName, "ParameterArgumentNames", "time_constant_s");
save_system(modelName, paths.plant);
clear cleanup;
end

function build_system(paths, time_constant_s)
modelName = char(paths.systemModelName);
close_if_loaded(modelName);
load_system(paths.plant);
new_system(modelName);
cleanup = onCleanup(@() close_if_loaded(modelName));
set_param(modelName, "Solver", "ode4", "FixedStep", "0.01", ...
    "StopTime", "10", "SaveOutput", "on", "OutputSaveName", "yout", ...
    "SaveFormat", "Dataset", "SignalLogging", "off");
modelWorkspace = get_param(modelName, "ModelWorkspace");
assignin(modelWorkspace, "time_constant_s", time_constant_s);

inBlock = [modelName '/command_xy_m'];
plantBlock = [modelName '/first_order_2d'];
commandOut = [modelName '/command_logging_sink'];
positionOut = [modelName '/position_logging_sink'];
add_block('simulink/Ports & Subsystems/In1', inBlock, ...
    "Position", [35 95 65 125], "Port", "1");
configure_port(inBlock, "-1");
add_block('simulink/Ports & Subsystems/Model', plantBlock, ...
    "Position", [180 80 350 140], "ModelName", paths.plantModelName);
add_block('simulink/Ports & Subsystems/Out1', commandOut, ...
    "Position", [420 30 450 60], "Port", "1");
configure_port(commandOut, "-1");
add_block('simulink/Ports & Subsystems/Out1', positionOut, ...
    "Position", [420 150 450 180], "Port", "2");
configure_port(positionOut, "-1");
instanceParameters = get_param(plantBlock, "InstanceParameters");
instanceParameters(1).Value = 'time_constant_s';
set_param(plantBlock, "InstanceParameters", instanceParameters);
commandLine = add_line(modelName, "command_xy_m/1", "first_order_2d/1", "autorouting", "on");
positionLine = add_line(modelName, "first_order_2d/1", "position_logging_sink/1", "autorouting", "on");
add_line(modelName, "command_xy_m/1", "command_logging_sink/1", "autorouting", "on");
set_param(commandLine, "Name", "command_xy_m");
set_param(positionLine, "Name", "position_xy_m");
save_system(modelName, paths.system);
clear cleanup;
close_if_loaded(paths.plantModelName);
end

function close_if_loaded(modelName)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end

function configure_port(blockPath, sampleTime)
set_param(blockPath, "PortDimensions", "2", "OutDataTypeStr", "double", ...
    "Unit", "m", "SampleTime", sampleTime);
end

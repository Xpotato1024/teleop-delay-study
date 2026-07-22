function paths = build_models(paths, config)
% build_models  Plant、通信、top-levelのSimulink modelを明示的に生成する。
arguments
    paths (1,1) struct
    config (1,1) struct
end
teleopdelay.config.validate_config(config);
if ~isfolder(paths.plantDirectory), mkdir(paths.plantDirectory); end
if ~isfolder(paths.communicationDirectory), mkdir(paths.communicationDirectory); end
if ~isfolder(paths.systemDirectory), mkdir(paths.systemDirectory); end
build_plant(paths, config.plant.time_constant);
build_communication(paths);
build_system(paths, config.plant.time_constant);
end

function build_plant(paths, time_constant_s)
modelName = char(paths.plantModelName);
close_if_loaded(modelName);
new_system(modelName);
cleanup = onCleanup(@() close_if_loaded(modelName));
set_param(modelName, "Solver", "ode4", "FixedStep", "0.01", "StopTime", "10", ...
    "SaveOutput", "off", "SignalLogging", "off");
workspace = get_param(modelName, "ModelWorkspace");
parameter = Simulink.Parameter(time_constant_s);
parameter.DataType = "double";
parameter.Unit = "s";
assignin(workspace, "time_constant_s", parameter);
inBlock = [modelName '/command_xy_m'];
stateBlock = [modelName '/first_order_state_space'];
outBlock = [modelName '/position_xy_m'];
add_block('simulink/Ports & Subsystems/In1', inBlock, "Position", [40 95 70 125], "Port", "1");
configure_port(inBlock, "-1", "m");
add_block('simulink/Continuous/State-Space', stateBlock, "Position", [160 80 330 140], ...
    "A", "[-1/time_constant_s 0; 0 -1/time_constant_s]", ...
    "B", "[1/time_constant_s 0; 0 1/time_constant_s]", ...
    "C", "[1 0; 0 1]", "D", "[0 0; 0 0]", "X0", "[0; 0]");
add_block('simulink/Ports & Subsystems/Out1', outBlock, "Position", [400 95 430 125], "Port", "1");
configure_port(outBlock, "-1", "m");
add_line(modelName, "command_xy_m/1", "first_order_state_space/1", "autorouting", "on");
add_line(modelName, "first_order_state_space/1", "position_xy_m/1", "autorouting", "on");
set_param(modelName, "ParameterArgumentNames", "time_constant_s");
save_system(modelName, paths.plant);
clear cleanup;
end

function build_communication(paths)
modelName = char(paths.communicationModelName);
close_if_loaded(modelName);
new_system(modelName);
cleanup = onCleanup(@() close_if_loaded(modelName));
set_param(modelName, "Solver", "ode4", "FixedStep", "0.01", "StopTime", "10", ...
    "SaveOutput", "off", "SignalLogging", "off");
workspace = get_param(modelName, "ModelWorkspace");
assignin(workspace, "sample_period_s", Simulink.Parameter(0.05));
assignin(workspace, "delay_s", Simulink.Parameter(0.10));
positionIn = [modelName '/position_xy_m'];
velocityIn = [modelName '/velocity_mps'];
clockBlock = [modelName '/Clock'];
reconstructBlock = [modelName '/reconstruct_packet'];
add_block('simulink/Ports & Subsystems/In1', positionIn, "Position", [25 55 55 85], "Port", "1");
add_block('simulink/Ports & Subsystems/In1', velocityIn, "Position", [25 135 55 165], "Port", "2");
configure_port(positionIn, "-1", "m");
configure_port(velocityIn, "-1", "m/s");
add_block('simulink/Sources/Clock', clockBlock, "Position", [25 230 55 260]);
add_block('simulink/User-Defined Functions/MATLAB Function', reconstructBlock, ...
    "Position", [230 75 430 255]);
chart = find(sfroot, '-isa', 'Stateflow.EMChart', 'Path', reconstructBlock);
chart.Script = communication_function_code();
set_chart_data_shape(chart.Inputs, ["position", "velocity", "sample_period_s", "delay_s", "time_s"], ...
    ["[1 2]", "[1 2]", "1", "1", "1"], "double");
set_chart_data_shape(chart.Outputs, ["zoh", "cv", "timestamp", "age", "valid"], ...
    ["[1 2]", "[1 2]", "1", "1", "1"], "double");
chart.Outputs(5).DataType = "boolean";
add_block('simulink/Ports & Subsystems/Out1', [modelName '/zoh_command_xy_m'], ...
    "Position", [510 55 540 85], "Port", "1");
add_block('simulink/Ports & Subsystems/Out1', [modelName '/cv_command_xy_m'], ...
    "Position", [510 95 540 125], "Port", "2");
add_block('simulink/Ports & Subsystems/Out1', [modelName '/packet_timestamp_s'], ...
    "Position", [510 135 540 165], "Port", "3");
add_block('simulink/Ports & Subsystems/Out1', [modelName '/packet_age_s'], ...
    "Position", [510 175 540 205], "Port", "4");
add_block('simulink/Ports & Subsystems/Out1', [modelName '/packet_valid'], ...
    "Position", [510 215 540 245], "Port", "5");
add_line(modelName, "position_xy_m/1", "reconstruct_packet/1", "autorouting", "on");
add_line(modelName, "velocity_mps/1", "reconstruct_packet/2", "autorouting", "on");
add_line(modelName, "Clock/1", "reconstruct_packet/5", "autorouting", "on");
for port = 1:2
    parameterBlock = [modelName '/parameter_' num2str(port)];
    add_block('simulink/Sources/Constant', parameterBlock, ...
        "Position", [100 115+port*55 150 145+port*55], "Value", parameter_name(port));
    add_line(modelName, char("parameter_" + string(port) + "/1"), ...
        char("reconstruct_packet/" + string(port+2)), "autorouting", "on");
end
% The function has five inputs: position, velocity, sample period, delay, time.
for port = 1:5
    add_line(modelName, char("reconstruct_packet/" + string(port)), ...
        char(output_name(port) + "/1"), "autorouting", "on");
end
set_param(modelName, "ParameterArgumentNames", "sample_period_s,delay_s");
save_system(modelName, paths.communication);
clear cleanup;
end

function name = parameter_name(port)
if port == 1, name = 'sample_period_s'; else, name = 'delay_s'; end
end

function name = output_name(port)
names = ["zoh_command_xy_m", "cv_command_xy_m", "packet_timestamp_s", "packet_age_s", "packet_valid"];
name = names(port);
end

function set_chart_data_shape(data, names, sizes, dataType)
for index = 1:numel(names)
    item = data(index);
    assert(string(item.Name) == names(index));
    item.Props.Array.IsDynamic = false;
    item.Props.Array.Size = char(sizes(index));
    item.DataType = dataType;
end
end

function code = communication_function_code()
lines = [ ...
    "function [zoh, cv, timestamp, age, valid] = reconstruct_packet(position, velocity, sample_period_s, delay_s, time_s)"; ...
    "%#codegen"; ...
    "persistent next_sample write_index packet_count packet_timestamps packet_positions packet_velocities"; ...
    "if isempty(packet_count)"; ...
    "    next_sample = 0.0; write_index = 1.0; packet_count = 0.0;"; ...
    "    packet_timestamps = -ones(1,1024); packet_positions = zeros(1024,2); packet_velocities = zeros(1024,2);"; ...
    "end"; ...
    "tol = 1.0e-10;"; ...
    "if ~(isfinite(sample_period_s) && sample_period_s > 0.0)"; ...
    "    error('teleopDelay:InvalidSamplePeriod', 'sample_period_s must be positive and finite.');"; ...
    "end"; ...
    "if ~(isfinite(delay_s) && delay_s >= 0.0)"; ...
    "    error('teleopDelay:InvalidDelay', 'delay_s must be nonnegative and finite.');"; ...
    "end"; ...
    "if time_s + tol >= next_sample"; ...
    "    packet_timestamps(write_index) = next_sample; packet_positions(write_index,:) = position; packet_velocities(write_index,:) = velocity;"; ...
    "    write_index = write_index + 1.0; if write_index > 1024.0, write_index = 1.0; end; packet_count = min(packet_count + 1.0, 1024.0);"; ...
    "    next_sample = next_sample + sample_period_s;"; ...
    "end"; ...
    "selected_timestamp = -1.0; selected_position = zeros(1,2); selected_velocity = zeros(1,2); selected_valid = false;"; ...
    "for index = 1:1024"; ...
    "    if index <= packet_count && packet_timestamps(index) + delay_s <= time_s + tol && packet_timestamps(index) > selected_timestamp"; ...
    "        selected_timestamp = packet_timestamps(index); selected_position = packet_positions(index,:); selected_velocity = packet_velocities(index,:); selected_valid = true;"; ...
    "    end"; ...
    "end"; ...
    "if selected_valid"; ...
    "    valid = true; timestamp = selected_timestamp; age = max(0.0, time_s - selected_timestamp); zoh = selected_position; cv = selected_position + age * selected_velocity;"; ...
    "else"; ...
    "    valid = false; timestamp = 0.0; age = 0.0; zoh = zeros(1,2); cv = zeros(1,2);"; ...
    "end"; ...
    "end" ];
code = char(strjoin(lines, newline));
end

function build_system(paths, time_constant_s)
modelName = char(paths.systemModelName);
close_if_loaded(modelName);
load_system(paths.plant);
load_system(paths.communication);
new_system(modelName);
cleanup = onCleanup(@() close_if_loaded(modelName));
set_param(modelName, "Solver", "ode4", "FixedStep", "0.01", "StopTime", "10", ...
    "SaveOutput", "on", "OutputSaveName", "yout", "SaveFormat", "Dataset", ...
    "SignalLogging", "off");
workspace = get_param(modelName, "ModelWorkspace");
assignin(workspace, "time_constant_s", time_constant_s);
assignin(workspace, "sample_period_s", 0.05);
assignin(workspace, "delay_s", 0.10);
add_block('simulink/Ports & Subsystems/In1', [modelName '/position_xy_m'], ...
    "Position", [25 75 55 105], "Port", "1");
add_block('simulink/Ports & Subsystems/In1', [modelName '/velocity_mps'], ...
    "Position", [25 155 55 185], "Port", "2");
configure_port([modelName '/position_xy_m'], "-1", "m");
configure_port([modelName '/velocity_mps'], "-1", "m/s");
communicationBlock = [modelName '/sampled_communication'];
add_block('simulink/Ports & Subsystems/Model', communicationBlock, ...
    "Position", [130 70 300 210], "ModelName", paths.communicationModelName);
communicationParameters = get_param(communicationBlock, "InstanceParameters");
for index = 1:numel(communicationParameters)
    communicationParameters(index).Value = communicationParameters(index).Name;
end
set_param(communicationBlock, "InstanceParameters", communicationParameters);
add_line(modelName, "position_xy_m/1", "sampled_communication/1", "autorouting", "on");
add_line(modelName, "velocity_mps/1", "sampled_communication/2", "autorouting", "on");
add_block('simulink/Ports & Subsystems/Model', [modelName '/zoh_first_order_2d'], ...
    "Position", [390 45 555 105], "ModelName", paths.plantModelName);
add_block('simulink/Ports & Subsystems/Model', [modelName '/cv_first_order_2d'], ...
    "Position", [390 155 555 215], "ModelName", paths.plantModelName);
for blockName = ["zoh_first_order_2d", "cv_first_order_2d"]
    instanceParameters = get_param([modelName '/' char(blockName)], "InstanceParameters");
    instanceParameters(1).Value = 'time_constant_s';
    set_param([modelName '/' char(blockName)], "InstanceParameters", instanceParameters);
end
add_line(modelName, "sampled_communication/1", "zoh_first_order_2d/1", "autorouting", "on");
add_line(modelName, "sampled_communication/2", "cv_first_order_2d/1", "autorouting", "on");
log_names = ["zoh_command_xy_m", "cv_command_xy_m", "zoh_position_xy_m", ...
    "cv_position_xy_m", "packet_timestamp_s", "packet_age_s", "packet_valid"];
source_ports = ["sampled_communication/1", "sampled_communication/2", ...
    "zoh_first_order_2d/1", "cv_first_order_2d/1", ...
    "sampled_communication/3", "sampled_communication/4", "sampled_communication/5"];
for index = 1:numel(log_names)
    sink = [modelName '/' char(log_names(index))];
    add_block('simulink/Ports & Subsystems/Out1', sink, ...
        "Position", [650 30+index*45 680 60+index*45], "Port", num2str(index));
    lineHandle = add_line(modelName, char(source_ports(index)), char(log_names(index) + "/1"), "autorouting", "on");
    set_param(lineHandle, "Name", char(log_names(index)));
end
save_system(modelName, paths.system);
clear cleanup;
close_if_loaded(paths.communicationModelName);
close_if_loaded(paths.plantModelName);
end

function configure_port(blockPath, sampleTime, unit)
set_param(blockPath, "PortDimensions", "2", "OutDataTypeStr", "double", "Unit", unit, "SampleTime", sampleTime);
end

function close_if_loaded(modelName)
if bdIsLoaded(modelName), close_system(modelName, 0); end
end

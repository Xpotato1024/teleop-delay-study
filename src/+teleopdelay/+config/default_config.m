function config = default_config()
% default_config  決定論的基盤シミュレーションの既定設定を返す。
%
% これらの値は研究結果や最適値ではなく、後続実装を開始するための仮設定である。

config.simulation.dt = 0.01;              % 時間刻み [s]
config.simulation.duration = 10.0;        % シミュレーション終了時刻 [s]

config.communication.sample_period = 0.05; % 通信サンプリング周期 [s]
config.communication.delay = 0.10;         % 通信純遅延 [s]

config.plant.time_constant = 0.20;        % 一次遅れ時定数 [s]

config.trajectory.type = "circle";       % circle または lissajous_1_2
config.trajectory.amplitude = 1.0;        % 軌道振幅 [m]
config.trajectory.omega = 1.0;            % 角速度 [rad/s]

config.random.seed = 0;                   % 再現性のための非負整数シード
config.simulation.solver = "ode4";
config.simulation.fixed_step = config.simulation.dt;
end

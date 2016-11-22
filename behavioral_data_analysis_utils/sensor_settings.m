function settings = sensor_settings

% Acquisition params
settings.sampRate = 4000;
settings.current_gain = 2.0;
settings.voltage_gain = 10.0;

% Stim parameters
settings.pre_stim = 3.0;
settings.stim = 0.5;
settings.post_stim = 3.0;

% Processing settings
settings.zero_mean_voltage_per_channel = [2.477, 2.463, 2.488, 2.484];
%settings.zero_mean_two_std_per_channel = [0.0137, 0.0151, 0.0142, 0.0156];
settings.zero_mean_two_std_per_channel = [0.00097875, 0.0010688, 0.0011572, 0.0020838];
settings.cutoffFreq = 50;
settings.aiType = 'SingleEnded';
settings.sensorPollFreq = 100; 

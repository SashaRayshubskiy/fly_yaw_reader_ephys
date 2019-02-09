function settings = sensor_settings( exp_metadata_file )

% 'LIGHT_LEVEL', 'SAMPLING_RATE', 'pre_stim_t', 'stim_t', 'post_stim_t', 'inter_trial_t'
if exist('exp_metadata_file','var')
    
    if(~exist(exp_metadata_file,'file'))
        settings.pre_stim = 3.0;
        settings.stim = 0.5;
        settings.post_stim = 3.0;
        settings.sampRate = 4000;        
    else
        dd = load(exp_metadata_file);
        
        % Stim parameters
        settings.pre_stim = dd.pre_stim_t;
        settings.stim = dd.stim_t;
        settings.post_stim = dd.post_stim_t;
        settings.sampRate = dd.SAMPLING_RATE;
    end
else
    % Date of sampRate change
    % dd = datetime({'2017-08-08::12-59-00'}, 'InputFormat', 'yyyy-MM-dd::hh-mm-ss');        
   
    settings.sampRate = 10000;    
    % settings.sampRate = 4000;    
    
    % disp(['Sample rate: ' num2str(settings.sampRate)]);    
%     settings.pre_stim = 0.5;
%     settings.stim = 0.25;
    
    settings.pre_stim = 3.0;
    settings.stim = 0.5;
    settings.post_stim = 3.0;    
end

% Acquisition params
settings.current_gain = 2.0;
settings.voltage_gain = 10.0;

% Processing settings
%settings.zero_mean_voltage_per_channel = [2.4875, 2.4712, 2.4952, 2.4914];
%settings.zero_mean_two_std_per_channel = [0.0137, 0.0151, 0.0142, 0.0156];
%settings.zero_mean_two_std_per_channel = [0.00097875, 0.0010688, 0.0011572, 0.0020838];

settings.zero_params_filename = 'zero_ball_velocity_params.mat';
settings.cutoffFreq = 50;
settings.aiType = 'SingleEnded';
settings.sensorPollFreq = 100; 

settings.sensor_1_DX_DAQ_AI = 7;
settings.sensor_1_DY_DAQ_AI = 8;
settings.sensor_2_DX_DAQ_AI = 9;
settings.sensor_2_DY_DAQ_AI = 10;

settings.CURRENT_NON_SCALED_A_DAQ_AI = 1;
settings.VOLTAGE_NON_SCALED_A_DAQ_AI = 2;
settings.SCALED_OUT_A_DAQ_AI = 3;
settings.GAIN_A_DAQ_AI = 5;
settings.MODE_A_DAQ_AI = 6;

settings.CURRENT_NON_SCALED_B_DAQ_AI = 17;
settings.VOLTAGE_NON_SCALED_B_DAQ_AI = 18;
settings.SCALED_OUT_B_DAQ_AI = 19;
settings.GAIN_B_DAQ_AI = 21;
settings.MODE_B_DAQ_AI = 22;

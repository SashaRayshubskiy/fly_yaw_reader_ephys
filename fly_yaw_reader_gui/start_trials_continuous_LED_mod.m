function [ output_args ] = start_trials_continuous_LED_mod( run_obj )

global tasks;
global viz_figs;
global current_trial_idx;
global session_id;
global experiment_dir;
global sessiod_id_hdl;
global session_obj;
global total_duration;
global pre_stim_t;
global stim_t;

global SHOW_TRIAL_DATA;


current_trial_idx = 1;

stim_type = run_obj.stim_type;

if(strcmp(stim_type, 'Task File') == 1)
    
    task_file_path = run_obj.taskfile_path;
    
    disp(['About to start trials using task file: ' task_file_path]);
    
    tasks = read_task_file(task_file_path);
    task_cnt = length(tasks);
            
    SHOW_TRIAL_DATA = 1;
    if (SHOW_TRIAL_DATA == 1)
        viz_figs.run_traj_fig     = figure();    
        viz_figs.all_trials_fig    = figure('units','normalized','outerposition',[0 0 1 1]);
        viz_figs.single_trials_fig = figure('units','normalized','outerposition',[0 0 1 1]);
    end
    
    session_id = run_obj.session_id;
    experiment_dir = run_obj.experiment_dir;
    sessiod_id_hdl = run_obj.sessiod_id_hdl;
    
    % Setup data structures for read / write on the daq board
    session_obj = daq.createSession('ni');
    deviceId = 'Dev3';
    
    session_obj.addAnalogOutputChannel( deviceId, [0 1 2 3], 'Voltage');    
    session_obj.addDigitalChannel( deviceId, 'port0/line2:4', 'OutputOnly' );
    
    % These are for inputs: motion sensor 1 x,y; motion sensor 2 x,y; frame
    % clock; stim left; stim right;
    ai_channels_used = [0:31];
    aI = session_obj.addAnalogInputChannel( deviceId, ai_channels_used, 'Voltage' );
    for i=1:length(ai_channels_used)
        aI(i).InputType = 'SingleEnded';
    end
    
    % This is the stim control: stim left, stim right
    settings = sensor_settings;
    
    % total duration is set by LED stim
    pre_stim_LED = 0.5;
    stim_t_LED = 0.25;
    post_stim_t_LED = 3.0;
  
    each_bout_t = pre_stim_LED + stim_t_LED + post_stim_t_LED;
    NUMBER_OF_BOUTS = 3;
    
    total_duration = each_bout_t * NUMBER_OF_BOUTS;
    
    %total_duration = run_obj.pre_stim_t + run_obj.stim_t + run_obj.post_stim_t + run_obj.inter_trial_t;
    
    SAMPLING_RATE = settings.sampRate;
    session_obj.Rate = SAMPLING_RATE;
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% NEW MAPPING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Analog Out: External command
    pre_out_chan_0 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Analog Out: WideFieldLight
    pre_out_chan_1 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Analog Out: Left LED
    pre_out_chan_2 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Analog Out: Right LED
    pre_out_chan_3 = zeros( task_cnt, SAMPLING_RATE * total_duration );

    % Digital Out: Camera triggers
    pre_out_chan_4 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Digital Out: Pico inject
    pre_out_chan_5 = zeros( task_cnt, SAMPLING_RATE * total_duration );

    %  Digital Out: Natural Odor stim
    pre_out_chan_6 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% OLD MAPPING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Digital Out: Left LED
    %pre_out_chan_0 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Digital Out: Right LED
    %pre_out_chan_1 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Digital Out: Camera triggers
    %pre_out_chan_2 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Digital Out: Pico inject
    %pre_out_chan_3 = zeros( task_cnt, SAMPLING_RATE * total_duration );

    %  Digital Out: Natural Odor stim
    %pre_out_chan_4 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Analog Out: External command
    %pre_out_chan_5 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    
    % Analog Out: WideFieldLight
    %pre_out_chan_6 = zeros( task_cnt, SAMPLING_RATE * total_duration );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pre_stim_t = run_obj.pre_stim_t;
    stim_t     = run_obj.stim_t;
    
    % Setup analog out LED stim for 3 LED intensities
    stim_LED = zeros(1,SAMPLING_RATE * total_duration);
    
    MAX_VOLT = 0.5;
    
    LED_voltage = [ MAX_VOLT/3.0, 2.0*MAX_VOLT/3.0, MAX_VOLT ];
    
    begin_bout_t = 0;   
    for i = 1:NUMBER_OF_BOUTS        
       
       begin_idx = (begin_bout_t+pre_stim_LED) * SAMPLING_RATE;
       end_idx = (begin_bout_t+pre_stim_LED+stim_t_LED) * SAMPLING_RATE;
       
       stim_LED(begin_idx:end_idx) = LED_voltage(i);

       begin_bout_t = begin_bout_t + each_bout_t;
    end
    
    
    % Setup general STIM
    begin_idx = run_obj.pre_stim_t * SAMPLING_RATE;
    end_idx = (run_obj.pre_stim_t+run_obj.stim_t) * SAMPLING_RATE;
    stim = zeros(1,SAMPLING_RATE * total_duration);
    stim(begin_idx:end_idx) = 1.0;

    % Setup external command stim
    CURRENT_INJECTION_IN_pA_PER_VOLT = 127.0; % This number assumes a 0.0637 voltage drop across the downstep resistors    
    injection_current = run_obj.injection_current;    
    external_command = zeros( SAMPLING_RATE*total_duration , 1 );    
    external_command(begin_idx:end_idx) = injection_current ./ CURRENT_INJECTION_IN_pA_PER_VOLT;
    
    camera_triggers = zeros(1,SAMPLING_RATE * total_duration);
    
    CAMERA_FPS = 32.0;    
    camera_triggers(1:(SAMPLING_RATE/CAMERA_FPS):end) = 1;
    
    for i = 1:task_cnt
        cur_task = tasks{i}; 
    
        % Camera triggers     
        pre_out_chan_4(i,:) = camera_triggers;
        
        if( strcmp(cur_task, 'LeftOdor') == 1 )
            pre_out_chan_2(i,:) = stim_LED;
        elseif( strcmp(cur_task, 'RightOdor') == 1 )
            pre_out_chan_3(i,:) = stim_LED;
        elseif( strcmp(cur_task, 'BothOdor') == 1 )
            pre_out_chan_2(i,:) = stim_LED;
            pre_out_chan_3(i,:) = stim_LED;
        elseif( strcmp(cur_task, 'PicoPumpInject') == 1 )
            pre_out_chan_5(i,:) = stim;            
        elseif( strcmp(cur_task, 'NaturalOdor') == 1 )
            pre_out_chan_6(i,:) = stim;            
        elseif( strcmp(cur_task, 'WideFieldLight') == 1 )
            pre_out_chan_1(i,:) = stim*5.0;
        elseif( strcmp(cur_task, 'ExternalCommandDepol') == 1 )
            pre_out_chan_0(i,:) = external_command;
        elseif( strcmp(cur_task, 'ExternalCommandHypopol') == 1 )
            pre_out_chan_0(i,:) = -1.0 * external_command;
        else            
            disp(['ERROR: Task: ' task ' is not recognized.']);
        end
    end
    
    out_chan_0 = reshape( pre_out_chan_0', [size(pre_out_chan_0,1)*size(pre_out_chan_0,2) 1]);
    out_chan_1 = reshape( pre_out_chan_1', [size(pre_out_chan_1,1)*size(pre_out_chan_1,2) 1]);
    out_chan_2 = reshape( pre_out_chan_2', [size(pre_out_chan_2,1)*size(pre_out_chan_2,2) 1]);
    out_chan_3 = reshape( pre_out_chan_3', [size(pre_out_chan_3,1)*size(pre_out_chan_3,2) 1]);
    out_chan_4 = reshape( pre_out_chan_4', [size(pre_out_chan_4,1)*size(pre_out_chan_4,2) 1]);
    out_chan_5 = reshape( pre_out_chan_5', [size(pre_out_chan_5,1)*size(pre_out_chan_5,2) 1]);
    out_chan_6 = reshape( pre_out_chan_6', [size(pre_out_chan_6,1)*size(pre_out_chan_6,2) 1]);
    
    if 0
    figure;
    hold on;
    plot(out_chan_0, 'b');
    plot(out_chan_1, 'g');
    end
    
    buffer = zeros(SAMPLING_RATE,1);
    
    out_chan_0 = vertcat( out_chan_0, buffer );
    out_chan_1 = vertcat( out_chan_1, buffer );
    out_chan_2 = vertcat( out_chan_2, buffer );
    out_chan_3 = vertcat( out_chan_3, buffer );
    out_chan_4 = vertcat( out_chan_4, buffer );    
    out_chan_5 = vertcat( out_chan_5, buffer );
    out_chan_6 = vertcat( out_chan_6, buffer );
    
    output_data = [ out_chan_0, out_chan_1, out_chan_2, out_chan_3, out_chan_4, out_chan_5, out_chan_6 ];
    
    queueOutputData( session_obj, output_data );
    
    addlistener( session_obj, 'DataAvailable', @processTrialData );
    session_obj.NotifyWhenDataAvailableExceeds = session_obj.Rate * total_duration;
    session_obj.IsContinuous = true;
    session_obj.startBackground();
    
else
    disp(stim_type);
    disp(['ERROR: stim_type: ' stim_type ' is not supported.']);
end

end

function processTrialData(src,event)
    global tasks;
    global viz_figs;
    global current_trial_idx;
    global session_id;
    global experiment_dir;
    global sessiod_id_hdl;
    global total_duration;
    global pre_stim_t;
    global stim_t;
    global SHOW_TRIAL_DATA;
    
    cur_task = tasks{current_trial_idx};
    
    cur_trial_corename = [cur_task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(session_id) '_tid_' num2str(current_trial_idx-1)];
    trial_bdata = event.Data;
    trial_time  = event.TimeStamps;
    
    if (SHOW_TRIAL_DATA == 1)  
        %display_all_trials( cur_task, trial_time, trial_bdata, viz_figs, pre_stim_t, stim_t, experiment_dir );  
        display_single_trials( cur_task, trial_time, trial_bdata, viz_figs, total_duration, pre_stim_t, stim_t, experiment_dir );  
    end
    
    disp(['Finished with trial: ' num2str(current_trial_idx-1) ]);

    cur_trial_file_name = [ experiment_dir '\bdata_' cur_trial_corename '.mat' ];
    save( cur_trial_file_name, 'trial_bdata', 'trial_time' );
    current_trial_idx = current_trial_idx + 1;
    
    if( current_trial_idx == (length(tasks)+1) )
        src.stop();
        release( src );
        
        
        if (SHOW_TRIAL_DATA == 1)  
            saveas( viz_figs.run_traj_fig, [ experiment_dir '\run_traj_' datestr(now, 'yyyy_mmdd_HH_MM_SS') '_sid_' num2str(session_id) '.fig'] );
            saveas( viz_figs.all_trials_fig, [ experiment_dir '\all_tc_' datestr(now, 'yyyy_mmdd_HH_MM_SS') '_sid_' num2str(session_id) '.fig'] );
            saveas( viz_figs.single_trials_fig, [ experiment_dir '\single_tc_' datestr(now, 'yyyy_mmdd_HH_MM_SS') '_sid_' num2str(session_id) '.fig'] );
        end
    
        % Update session id    
        set(sessiod_id_hdl, 'String', num2str(session_id+1));
    
        disp('Trials complete.')
    end
end


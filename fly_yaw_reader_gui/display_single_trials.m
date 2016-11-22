function [] = display_single_trials( task, trial_time, trial_data, viz_figs, total_duration, pre_stim_t, stim_t )

colors = { rgb('Red'), rgb('Green'), rgb('Blue'), rgb('Black'), rgb('Brown'), rgb('Purple') };
cur_color = '';

if( (strcmp(task, 'LeftOdor') == 1 ) || (strcmp(task, 'WideFieldLight') == 1 ) )
    cur_color = colors{1};
elseif( strcmp(task, 'RightOdor') == 1 )
    cur_color = colors{2};
elseif( strcmp(task, 'BothOdor') == 1 )
    cur_color = colors{3};
elseif( strcmp(task, 'NaturalOdor') == 1 )
    cur_color = colors{4};
elseif( strcmp(task, 'ExternalCommandDepol') == 1 )
    cur_color = colors{5};
elseif( strcmp(task, 'ExternalCommandHypopol') == 1 )
    cur_color = colors{6};
else
    disp(['ERROR: Task: ' task ' is not recognized.']);
end

[ t, vel_forward, vel_side, vel_yaw ] = get_velocity_ephysrig(trial_time, trial_data); 

set( 0, 'CurrentFigure', viz_figs.single_trials_fig )

t_vel_0 = t(1);
t_0 = trial_time(1);

% Plot forward
subplot(4,1,1);
hold on;
plot( t-t_vel_0, vel_forward, 'color', cur_color );
ylabel('Fwd velocity (mm/s)');
xlim([0 total_duration]);
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ pre_stim_t pre_stim_t (pre_stim_t+stim_t) (pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

subplot(4,1,2);
hold on;
plot( t-t_vel_0, vel_yaw, 'color', cur_color );
ylabel('Yaw velocity (deg/s)');
xlim([0 total_duration]);
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ pre_stim_t pre_stim_t (pre_stim_t+stim_t) (pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

current = trial_data(:,1);
voltage = trial_data(:,2);

subplot(4,1,3);
hold on;
CURRENT_SCALING_FACTOR = 500;
plot(trial_time-t_0, CURRENT_SCALING_FACTOR * current, 'color', cur_color );
xlim([0 total_duration]);
ylabel('Current (pA)');
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ pre_stim_t pre_stim_t (pre_stim_t+stim_t) (pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

subplot(4,1,4);
VOLTAGE_SCALING_FACTOR = 10;
hold on;
plot(trial_time-t_0, VOLTAGE_SCALING_FACTOR * voltage, 'color', cur_color );
xlim([0 total_duration]);
xlabel('Time (s)');
ylabel('Voltage (mV)')
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ pre_stim_t pre_stim_t (pre_stim_t+stim_t) (pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

end


function [] = display_all_trials( task, trial_time, trial_data, viz_figs, pre_stim_t, stim_t )

colors = {'red', 'green', 'blue', 'black', 'brown'};
cur_color = '';

if( (strcmp(task, 'LeftOdor') == 1 ) )
    cur_color = colors{1};
elseif( strcmp(task, 'RightOdor') == 1 )
    cur_color = colors{2};
elseif( strcmp(task, 'BothOdor') == 1 )
    cur_color = colors{3};
elseif( strcmp(task, 'NaturalOdor') == 1 )
    cur_color = colors{4};
elseif( strcmp(task, 'ExternalCommand') == 1 )
    cur_color = colors{5};
    legend_idx = 5;
elseelse
    disp(['ERROR: Task: ' task ' is not recognized.']);
end

[ t, vel_forward, vel_side, vel_yaw ] = get_velocity_ephysrig(trial_time, trial_data); 

% Display trial raw trajectory
% figure(viz_figs.run_traj_fig);
set( 0, 'CurrentFigure', viz_figs.run_traj_fig )

settings = sensor_settings;
dt = 1.0/settings.sensorPollFreq;
%[disp_x, disp_y, theta] = calculate_fly_position_with_yaw(vel_forward, vel_side, vel_yaw, dt, 0, 0, 0);
[disp_x, disp_y] = calculate_fly_position_no_yaw(vel_forward, vel_side, dt, 0, 0);
hold on;
plot(disp_x, disp_y, 'color', cur_color);
xlabel('X displacement (au)');
ylabel('Y displacement (au)');

set( 0, 'CurrentFigure', viz_figs.all_trials_fig )

% Plot forward
subplot(4,1,1);
hold on;
plot( t, vel_forward, 'color', cur_color );
ylabel('Fwd velocity (au/s)');
xlim([0 trial_time(end)]);

t_vel_first = t(1);

yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ t_vel_first+pre_stim_t t_vel_first+pre_stim_t (t_vel_first+pre_stim_t+stim_t) (t_vel_first+pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

subplot(4,1,2);
hold on;
plot( t, vel_yaw, 'color', cur_color );
ylabel('Yaw velocity (au/s)');
xlim([0 trial_time(end)]);
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ t_vel_first+pre_stim_t t_vel_first+pre_stim_t (t_vel_first+pre_stim_t+stim_t) (t_vel_first+pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

current = trial_data(:,1);
voltage = trial_data(:,2);
t_first = trial_time(1);

subplot(4,1,3);
hold on;
CURRENT_SCALING_FACTOR = 0.5;
plot(trial_time, CURRENT_SCALING_FACTOR * current, 'color', cur_color );
xlim([0 trial_time(end)]);
ylabel('Current (pA)');
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ t_first+pre_stim_t t_first+pre_stim_t (t_first+pre_stim_t+stim_t) (t_first+pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

subplot(4,1,4);
VOLTAGE_SCALING_FACTOR = 10;
hold on;
plot(trial_time, VOLTAGE_SCALING_FACTOR * voltage, 'color', cur_color );
xlim([0 trial_time(end)]);
xlabel('Time (s)');
ylabel('Voltage (mV)')
yy = ylim;
y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
hh = fill([ t_first+pre_stim_t t_first+pre_stim_t (t_first+pre_stim_t+stim_t) (t_first+pre_stim_t+stim_t) ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

end


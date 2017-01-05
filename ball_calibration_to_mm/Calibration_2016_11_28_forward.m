%%% analyzing calibration
%%% Tatsuo Okubo
%%% 2016/07/15

clear;
experiment_dir = 'C:\Users\sasha\Dropbox\Wilson_lab\data\ephys\161128_ball_callibration_01\';
cd(experiment_dir)
Dir = dir('*sid*');
%Sessions = [0:6]; FWD
Sessions = [11:17]; %SIDE

D = 6.35; % diameter of the ball [mm] (1/4 inches)
Gear = 104;

%%
settings = sensor_settings;
use_calibration = 0;

figure(1); clf;
for n=1:length(Sessions)
    File = dir(['*sid_',num2str(Sessions(n)),'_*']);
    load(File.name);
    [ t, vel_forward, vel_side, vel_yaw ] = get_velocity_ephysrig(trial_time, trial_bdata, experiment_dir, use_calibration );
    %Enc1 = trial_bdata(:,13);
    Enc1 = trial_bdata(:,14);
    Thres = 5;
    a = find((Enc1(1:end-1)<Thres)&Enc1(2:end)>Thres)+1; % find upward threshold crossing
    b = diff(a)./settings.sampRate; % period  [s]
    R(n) = (1/mean(b))/Gear; % number of rotations/s of the ball (not the motor)
    
    %%plot
    s(1)=subplot(311);
    hold on
    plot(t,vel_forward);
    Mean_forward(n) = mean(vel_forward);
    s(2)=subplot(312);
    hold on
    plot(t,vel_side)
    s(3)=subplot(313);
    hold on
    plot(t,vel_yaw)
    Mean_yaw(n) = mean(vel_yaw);
%     s(4)=subplot(414);
%     hold on
%     plot(trial_time,Enc1)
%     hold on
%     xl = xlim;
%     line([0 xl(2)],[Thres Thres],'color','r','linestyle',':')
%     plot(Y,Thres,'ro','markersize',3) % display threshold crossing points
%     ylim([-1 11])
%     s(3)=subplot(313);
%     plot(trial_time,Enc2)
%     ylim([-1 11])
    linkaxes(s,'x')
end
R = R.*([1 1 1 0 -1 -1 -1]);
R(4) = 0; % not rotating

%% formatting the plot
subplot(311)
%ylim([-0.5 0.5])
ylabel('Forward vel. (A.U.)','fontsize',12)
set(gca,'color','none')
legend('-6V','-4.5V','-3V','0V','+3V','+4.5V','+ 6V')
legend('boxon')
subplot(312)
ylim([-0.5 0.5])
ylabel('Side vel. (A.U.)','fontsize',12)
set(gca,'color','none')
subplot(313)
ylim([-0.5 0.5])
ylabel('Yaw vel. (A.U.)','fontsize',12)
set(gca,'color','none')
xlabel('Time (s)','fontsize',12)

%% mean forward
figure(2); clf;
X = fliplr([6 4.5 3 0 -3 -4.5 -6]);
plot(X,Mean_forward,'ro','linewidth',2)
P = polyfit(X,Mean_forward,1);
Y = polyval(P,X);
hold on
plot(X,Y,':k')
box off
set(gca,'color','none')
xlabel('Voltage of the motor (V)')
ylabel('Mean forward velocity')

%%
v_forward = R*pi*D;
figure(3); clf;
plot(v_forward,Mean_forward,'ro','linewidth',2)
P = polyfit(v_forward,Mean_forward,1);
Y = polyval(P,v_forward);
hold on
plot(v_forward,Y,':k')
box off
set(gca,'color','none')
xlabel('Mean v_forward of the ball (mm/s)','interpreter','none')
ylabel('Mean forward output (V)')
text(-20,-0.1,['y = ',num2str(P(1),3),' * x + ',num2str(P(2),2)],'fontsize',14)
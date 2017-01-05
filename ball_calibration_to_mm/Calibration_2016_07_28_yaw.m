%%% analyzing calibration
%%% Tatsuo Okubo
%%% 2016/07/15

clear;
cd('Z:\Tots\Behavior\Tethered_walking\ballData\2016-07-28_third_setup_calibration')
Dir = dir('*sid*');
Sessions = [5,3,1,0,2,4,6];
D = 6.35; % diameter of the ball [mm] (1/4 inches)
Gear = 104;

%%
settings = sensor_settings;

figure(1); clf;
for n=1:length(Sessions)
    File = dir(['*sid_',num2str(Sessions(n)),'_*']);
    File
    load(File.name);
    [ t, vel_forward, vel_side, vel_yaw ] = get_velocity(trial_time, trial_bdata);
    Enc1 = trial_bdata(:,5);
    Enc2 = trial_bdata(:,6);
    Thres = 5;
    a = find((Enc1(1:end-1)<Thres)&Enc1(2:end)>Thres)+1; % find upward threshold crossing
    b = diff(a)./settings.sampRate; % period  [s]
    R(n) = (1/mean(b))/Gear; % number of rotations/s of the ball (not the motor)
    
    %%plot
    s(1)=subplot(311);
    hold on
    plot(t,vel_forward)
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
    %     linkaxes(s,'x')
%     figure(3); clf;
%     hold on
%     plot(trial_time,Enc1,'r')
%     plot(trial_time,Enc2,'b')
%     xlim([0 0.05])
%     zoom xon  
end
R = R.*([1 1 1 0 -1 -1 -1]);
R(4) = 0; % not rotating

%% formatting the plot
figure(1)
subplot(311)
ylim([-0.5 0.5])
ylabel('Forward vel. (A.U.)','fontsize',12)
set(gca,'color','none')
subplot(312)
ylim([-0.5 0.5])
ylabel('Side vel. (A.U.)','fontsize',12)
set(gca,'color','none')
subplot(313)
ylim([-0.5 0.5])
ylabel('Yaw vel. (A.U.)','fontsize',12)
legend('+6V','+4.5V','+3V','0V','-3V','-4.5V','-6V')
legend('boxon')
set(gca,'color','none')
xlabel('Time (s)','fontsize',12)

%% mean yaw
% figure(2); clf;
% X = [6 4.5 3 0 -3 -4.5 -6];
% plot(X,Mean_yaw,'ro','linewidth',2)
% P = polyfit(X,Mean_yaw,1);
% Y = polyval(P,X);
% hold on
% plot(X,Y,':k')
% box off
% set(gca,'color','none')
% xlabel('Voltage of the motor (V)')
% ylabel('Mean yaw velocity')

%%
v_yaw = R*360; % [deg/s]
figure(3); clf;
plot(v_yaw,Mean_yaw,'ro','linewidth',2)
P = polyfit(v_yaw,Mean_yaw,1);
Y = polyval(P,v_yaw);
hold on
plot(v_yaw,Y,':k')
box off
set(gca,'color','none')
xlabel('Mean v_yaw of the ball (deg/s)','interpreter','none')
ylabel('Mean yaw output (V)')
text(-400,-0.3,['y = ',num2str(P(1),3),' * x + ',num2str(P(2),2)],'fontsize',14)
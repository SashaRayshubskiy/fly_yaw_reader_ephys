%%% analyzing calibration
%%% Tatsuo Okubo
%%% 2016/07/15

clear;
cd('Z:\Tots\Behavior\Tethered_walking\ballData\2016-07-28_third_setup_calibration')
Dir = dir('*sid*');
Sessions = [11,9,7,0,8,10,12];

D = 6.35; % diameter of the ball [mm] (1/4 inches)
Gear = 104; % gear ratio
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
    Mean_side(n) = mean(vel_side);
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
ylim([-0.5 0.5])
ylabel('Forward vel. (A.U.)','fontsize',12)
set(gca,'color','none')
subplot(312)
ylim([-0.5 0.5])
ylabel('Side vel. (A.U.)','fontsize',12)
set(gca,'color','none')
legend('+6V','+4.5V','+3V','0V','-3V','-4.5V','-6V')
subplot(313)
ylim([-0.5 0.5])
ylabel('Yaw vel. (A.U.)','fontsize',12)
set(gca,'color','none')
xlabel('Time (s)','fontsize',12)

%% mean side
figure(2); clf;
X = [6 4.5 3 0 -3 -4.5 -6];
plot(X,Mean_side,'ro','linewidth',2)
P = polyfit(X,Mean_side,1);
Y = polyval(P,X);
hold on
plot(X,Y,':k')
box off
set(gca,'color','none')
xlabel('Voltage of the motor (V)')
ylabel('Mean side velocity')

%%
v_side = R*pi*D;
figure(3); clf;
plot(v_side,Mean_side,'ro','linewidth',2)
P = polyfit(v_side,Mean_side,1);
Y = polyval(P,v_side);
hold on
plot(v_side,Y,':k')
box off
set(gca,'color','none')
xlabel('Mean v_side of the ball (mm/s)','interpreter','none')
ylabel('Mean side output (V)')
text(-20,-0.2,['y = ',num2str(P(1),3),' * x + (',num2str(P(2),2),')'],'fontsize',14)
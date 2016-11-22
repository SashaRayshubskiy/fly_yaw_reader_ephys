function [v_fwd,v_side,v_yaw] = convert_velocity_TO(vel_fwd, vel_side, vel_yaw)
%%% converting the velocity signal using the calibration results
%%% v_old: v_forward, v_side, v_yaw
%%% 2p imaging setup
%%% Tatsuo Okubo
%%% 2016/10/18

%% parameters (for device 3 for 2P imaging)
a_forward = 0.00745;
b_forward = 0.0046;
a_side = 0.00607;
b_side = -0.014;
a_yaw = 0.000395;
b_yaw = 0.0034;

%% convert
v_fwd = (vel_fwd-b_forward)./a_forward;
v_side = (vel_side-b_side)./a_side;
v_yaw = (vel_yaw-b_yaw)./a_yaw;

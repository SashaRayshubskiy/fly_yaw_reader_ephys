function [ avg_zero_volt, std_zero_volt ] = get_zero_velocity_for_channel( raw_data )

settings = sensor_settings;

rate = 2*(settings.cutoffFreq/settings.sampRate);
[kb, ka] = butter(2,rate);
smoothedData = filtfilt(kb, ka, raw_data);

dt = settings.sampRate/settings.sensorPollFreq;

x = floor(length(smoothedData)/dt);
cut_length = x*dt;
smoothedData_downsampled = squeeze(mean(reshape(smoothedData(1:cut_length), [dt, x])));

%%%%% 
% Turn these on to recalibrate the average and std of zero volts.
%   figure;
%hold on;
%plot(smoothedData_downsampled);
%plot([1:length(smoothedData_downsampled)], repmat(mean(smoothedData_downsampled), [length(smoothedData_downsampled)] ));

avg_zero_volt = mean(smoothedData_downsampled);
std_zero_volt = 2.0*std(smoothedData_downsampled,1);

disp(['mean: ' num2str(avg_zero_volt) ' std: ' num2str(std_zero_volt)]);

end


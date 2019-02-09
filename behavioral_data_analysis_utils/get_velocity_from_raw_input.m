function [ t, vel ] = get_velocity_from_raw_input( raw_data, time, zero_volt_mark, zero_volt_noise_2std, samplingRate )

settings = sensor_settings;
if(nargin == 5 )
   cur_samplingRate = samplingRate;
else
   cur_samplingRate = settings.sampRate; 
end

dt = cur_samplingRate / settings.sensorPollFreq;

rate = 2*(settings.cutoffFreq/settings.sampRate);
[kb, ka] = butter(2,rate);
smoothedData = filtfilt(kb, ka, raw_data);



x = floor(length(smoothedData)/dt);
cut_length = x*dt;
smoothedData_downsampled = squeeze(mean(reshape(smoothedData(1:cut_length), [dt, x])));
time_downsampled = squeeze(mean(reshape(time(1:cut_length), [dt, x])));

%%%%% 
% Turn these on to recalibrate the average and std of zero volts.
%   figure;
%hold on;
%plot(smoothedData_downsampled);
%plot([1:length(smoothedData_downsampled)], repmat(mean(smoothedData_downsampled), [length(smoothedData_downsampled)] ));
%disp(['mean: ' num2str(mean(smoothedData_downsampled)) ' std: ' num2str(2.0*std(smoothedData_downsampled,1))]);

sdz = smoothedData_downsampled - repmat(zero_volt_mark, [1 size(smoothedData_downsampled,2)]);

NOISE_LEVEL_FACTOR = 6.0;
noize_level = NOISE_LEVEL_FACTOR*zero_volt_noise_2std;

sdz(find( (sdz < noize_level) & (sdz > -1.0*noize_level))) = 0.0;

vel = sdz;
t = time_downsampled;

end


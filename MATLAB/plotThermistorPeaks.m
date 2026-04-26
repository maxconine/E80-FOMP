%% 1. Datatype Sizes and Mapping
dataSizes.('float')    = 4; dataSizes.('ulong')    = 4;
dataSizes.('int')      = 4; dataSizes.('int32')    = 4;
dataSizes.('uint8')    = 1; dataSizes.('uint16')   = 2;
dataSizes.('char')     = 1; dataSizes.('bool')     = 1;
dataSizes.('uint8_t')  = 1; dataSizes.('uint16_t') = 2;
dataSizes.('uint32_t') = 4; dataSizes.('int8_t')   = 1;
dataSizes.('int16_t')  = 2; dataSizes.('int32_t')  = 4;

typeMap = containers.Map(...
    {'float','ulong','int','int32','uint8','uint16','char','bool',...
     'uint8_t','uint16_t','uint32_t','int8_t','int16_t','int32_t'},...
    {'float','uint32','int32','int32','uint8','uint16','uchar','uint8',...
     'uint8','uint16','uint32','int8','int16','int32'});

%% 2. File Inputs 
infofile   = 'inf106.txt';
datafile   = 'log106.bin';
dataFreqHz = 10; % 10 Hz logging rate

%% 3. Read Data
fileID = fopen(infofile);
items  = textscan(fileID, '%s', 'Delimiter', ',', 'EndOfLine', '\r\n');
fclose(fileID);

ncols    = numel(items{1}) / 2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varTypes = strrep(varTypes, '_t', ''); 

varLengths = zeros(size(varTypes));
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
colLength = 256; 

fid = fopen(datafile, 'rb');
sensorData = struct();
for i = 1:numel(varTypes)
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    matlabType = typeMap(varTypes{i});
    sensorData.(varNames{i}) = single(fread(fid, Inf, ['*' matlabType], colLength - varLengths(i)));
end
fclose(fid);

%% 4. Extract and Align Variables
depth_raw = double(sensorData.('depth'));
depth_des = double(sensorData.('depth_des')); 
sens_B    = double(sensorData.('AS7343_CH0'));  
sens_G    = double(sensorData.('AS7343_CH15')); 
sens_R    = double(sensorData.('AS7343_CH9'));  
therm_raw = double(sensorData.('Therm_Raw')); 

num_samples = min([numel(depth_raw), numel(depth_des), numel(sens_R), numel(sens_G), numel(sens_B), numel(therm_raw)]);
depth_raw = depth_raw(1:num_samples);
depth_des = depth_des(1:num_samples);
sens_R    = sens_R(1:num_samples);
sens_G    = sens_G(1:num_samples);
sens_B    = sens_B(1:num_samples);
therm_raw = therm_raw(1:num_samples);

data_time = (0:(num_samples-1)) / dataFreqHz;

%% 5. Identify Thermistor Peaks
% Use findpeaks to locate spikes that are at least 50% of the max value
% MinPeakDistance of 5 (0.5 seconds) prevents it from finding multiple peaks in one cluster
peak_threshold = max(therm_raw) * 0.5;
[pks, locs] = findpeaks(therm_raw, 'MinPeakHeight', peak_threshold, 'MinPeakDistance', 5);

% Extract the exact times the peaks occurred
peak_times = data_time(locs);

%% 6. Plot the Data
figure('Name', 'Sensor Data with Thermistor Peaks', 'Position', [100, 100, 1500, 400], 'Color', 'w');

% -- Plot 1: Depth vs Time (With Peak Markers) --
subplot(1, 3, 1);
hold on;
plot(data_time, depth_raw, 'b-', 'LineWidth', 1.5);
plot(data_time, depth_des, 'r-', 'LineWidth', 1.5);
% Add vertical dashed lines indicating exactly when the motors were off
for i = 1:length(peak_times)
    xline(peak_times(i), 'k--', 'Alpha', 0.3);
end
xlabel('Time (s)');
ylabel('Depth (m)');
title('Depth vs Time (Dashed lines = Motor Off)');
legend('Measured Depth', 'Desired Depth', 'Location', 'best');
set(gca, 'YDir', 'reverse');
grid on;

% -- Plot 2: Sensor RGB Lux vs Depth --
subplot(1, 3, 2);
hold on;
plot(depth_raw, sens_R, 'r-', 'LineWidth', 1);
plot(depth_raw, sens_G, 'g-', 'LineWidth', 1);
plot(depth_raw, sens_B, 'b-', 'LineWidth', 1);
xlabel('Depth (m)');
ylabel('Lux (lm/m^2)');
title('RGB Lux vs Depth');
legend('Red Lux', 'Green Lux', 'Blue Lux', 'Location', 'best');
grid on;

% -- Plot 3: Thermistor Raw vs Time (Highlighting Peaks) --
subplot(1, 3, 3);
hold on;
plot(data_time, therm_raw, 'k-', 'LineWidth', 1);
% Plot the extracted peaks as distinct red circles
plot(peak_times, pks, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
yline(peak_threshold, 'r:', 'Threshold', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
xlabel('Time (s)');
ylabel('Therm\_Raw Voltage');
title('Thermistor Voltage with Detected Peaks');
legend('Raw Signal', 'Detected Peaks', 'Location', 'best');
grid on;
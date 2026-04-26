% Final Project Plotting
% Max, Pierce, Octavia, Freja
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
datafile   = 'log112.bin';
videofile  = 'E80_Test_a.MOV'; % Update to your video name
outputVideoFile = 'Dashboard_Plots.mp4'; 

dataFreqHz = 10; % Set to your data logging frequency

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
therm_raw = double(sensorData.('Therm_Raw')); % Extract Thermistor data

% Ensure all arrays are the exact same length
num_samples = min([numel(depth_raw), numel(depth_des), numel(sens_R), numel(sens_G), numel(sens_B), numel(therm_raw)]);
depth_raw = depth_raw(1:num_samples);
depth_des = depth_des(1:num_samples);
sens_R    = sens_R(1:num_samples);
sens_G    = sens_G(1:num_samples);
sens_B    = sens_B(1:num_samples);
therm_raw = therm_raw(1:num_samples);

data_time = (0:(num_samples-1)) / dataFreqHz;

%% 5. Setup Video Reader, Writer, and Dashboard Figure
vr = VideoReader(videofile);
vw = VideoWriter(outputVideoFile, 'MPEG-4');
vw.FrameRate = vr.FrameRate; 
open(vw);

% Create a 1920x1080 figure so it exports in HD for iMovie
fig = figure('Name', 'Exporting Dashboard', 'Position', [100, 100, 1920, 1080], 'Color', 'w');

% -- Plot 1: Depth and Desired Depth vs Time (Top Left) --
ax_depthTime = subplot(2, 2, 1);
hold(ax_depthTime, 'on');
h_depthMeas = plot(ax_depthTime, nan, nan, 'b', 'LineWidth', 1.5);
h_depthDes  = plot(ax_depthTime, nan, nan, 'r', 'LineWidth', 1.5);
xlabel(ax_depthTime, 'Time (s)');
ylabel(ax_depthTime, 'Depth (m)');
title(ax_depthTime, 'Desired and Measured Depth vs Time');
legend([h_depthMeas, h_depthDes], {'Measured Depth', 'Desired Depth'}, 'Location', 'northeast');
set(ax_depthTime, 'YDir', 'reverse'); 
grid(ax_depthTime, 'on');
xlim(ax_depthTime, [0, 10]); 

% -- Plot 2: Sensor RGB Lux vs Depth (Top Right) --
ax_sensDepth = subplot(2, 2, 2);
hold(ax_sensDepth, 'on');
h_sensR = plot(ax_sensDepth, nan, nan, 'r', 'LineWidth', 1.5);
h_sensG = plot(ax_sensDepth, nan, nan, 'g', 'LineWidth', 1.5);
h_sensB = plot(ax_sensDepth, nan, nan, 'b', 'LineWidth', 1.5);
xlabel(ax_sensDepth, 'Depth (m)');
ylabel(ax_sensDepth, 'Lux (lm/m^2)');
title(ax_sensDepth, 'RGB Lux vs Depth (PhotoDiodes)');
legend([h_sensR, h_sensG, h_sensB], {'Red Lux', 'Green Lux', 'Blue Lux'}, 'Location', 'northeast');
grid(ax_sensDepth, 'on');

% -- Plot 3: GoPro RGB vs Depth (Bottom Left) --
ax_camDepth = subplot(2, 2, 3);
hold(ax_camDepth, 'on');
h_camR = plot(ax_camDepth, nan, nan, 'r', 'LineWidth', 1.5);
h_camG = plot(ax_camDepth, nan, nan, 'g', 'LineWidth', 1.5);
h_camB = plot(ax_camDepth, nan, nan, 'b', 'LineWidth', 1.5);
xlabel(ax_camDepth, 'Depth (m)');
ylabel(ax_camDepth, 'RGB values');
title(ax_camDepth, 'GoPro RGB Value vs Depth');
legend([h_camR, h_camG, h_camB], {'Red', 'Green', 'Blue'}, 'Location', 'southwest');
grid(ax_camDepth, 'on');

% -- Plot 4: Thermistor Voltage vs Time (Bottom Right) --
ax_therm = subplot(2, 2, 4);
h_therm = plot(ax_therm, nan, nan, 'k', 'LineWidth', 1.5); % Black line
xlabel(ax_therm, 'Time (s)');
ylabel(ax_therm, 'Therm_Raw');
title(ax_therm, 'Thermistor Voltage vs Time');
grid(ax_therm, 'on');
xlim(ax_therm, [0, 10]); 

% Arrays to hold the GoPro data we extract on the fly
gopro_depths = [];
gopro_R = []; gopro_G = []; gopro_B = [];

%% 6. Frame-by-Frame Processing Loop
vr.CurrentTime = 0; 
disp('Extracting frames and exporting video... Grab a coffee.');

firstFrame = true;
targetSize = [];

while hasFrame(vr) && ishandle(fig)
    vidFrame = readFrame(vr);
    t_curr   = vr.CurrentTime; 
    
    % Find corresponding data index
    idx = data_time <= t_curr;
    
    if any(idx)
        % 1. Update Depth vs Time
        set(h_depthMeas, 'XData', data_time(idx), 'YData', depth_raw(idx));
        set(h_depthDes, 'XData', data_time(idx), 'YData', depth_des(idx));
        
        % 4. Update Thermistor vs Time
        set(h_therm, 'XData', data_time(idx), 'YData', therm_raw(idx));
        
        % Expand Time X-axis dynamically for both Time plots
        if t_curr > ax_depthTime.XLim(2) * 0.8
            new_lim = [0, ax_depthTime.XLim(2) + 10];
            xlim(ax_depthTime, new_lim); 
            xlim(ax_therm, new_lim);
        end
        
        % 2. Update Sensor Lux vs Depth
        set(h_sensR, 'XData', depth_raw(idx), 'YData', sens_R(idx));
        set(h_sensG, 'XData', depth_raw(idx), 'YData', sens_G(idx));
        set(h_sensB, 'XData', depth_raw(idx), 'YData', sens_B(idx));
        
        % 3. Calculate GoPro RGB from current frame
        curr_idx = find(idx, 1, 'last');
        gopro_depths = [gopro_depths, depth_raw(curr_idx)];
        gopro_R = [gopro_R, mean(vidFrame(:,:,1), 'all')];
        gopro_G = [gopro_G, mean(vidFrame(:,:,2), 'all')];
        gopro_B = [gopro_B, mean(vidFrame(:,:,3), 'all')];
        
        % Update GoPro RGB vs Depth
        set(h_camR, 'XData', gopro_depths, 'YData', gopro_R);
        set(h_camG, 'XData', gopro_depths, 'YData', gopro_G);
        set(h_camB, 'XData', gopro_depths, 'YData', gopro_B);
    end
    
    drawnow limitrate; 
    
    % Capture and write frame with guaranteed dimensions
    frame = getframe(fig);
    img = frame.cdata;
    
    if firstFrame
        targetSize = [size(img, 1), size(img, 2)];
        firstFrame = false;
    else
        if size(img, 1) ~= targetSize(1) || size(img, 2) ~= targetSize(2)
            img = imresize(img, targetSize);
        end
    end
    
    writeVideo(vw, img);
end

close(vw);
disp(['Export Complete! Saved as: ', outputVideoFile]);
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

%% 2. File Inputs for the 6 Trials
logFiles = {'log105.bin', 'log106.bin', 'log108.bin', 'log109.bin', 'log111.bin', 'log112.bin'};
infFiles = {'inf105.txt', 'inf106.txt', 'inf108.txt', 'inf109.txt', 'inf111.txt', 'inf112.txt'};

numTrials = length(logFiles);
dataFreqHz = 10; 
smoothWindow = 15; % Smoothing window

%% 3. Setup Figure
figure('Name', '6 Trials: Cropped & Curved RGB Fit', 'Position', [100, 100, 800, 600], 'Color', 'w');
hold on;
grid on;

% Colors for the plot
color_R = [1.0, 0.2, 0.2]; % Red
color_G = [0.2, 0.8, 0.2]; % Green
color_B = [0.2, 0.2, 1.0]; % Blue

% Variables to track handles for the legend
h_R = []; h_G = []; h_B = [];

%% 4. Loop Through Each Trial
for k = 1:numTrials
    % --- A. Read Info File ---
    fileID = fopen(infFiles{k});
    if fileID == -1
        warning('Could not open %s. Skipping...', infFiles{k});
        continue;
    end
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
    
    % --- B. Read Binary Data ---
    fid = fopen(logFiles{k}, 'rb');
    if fid == -1
        warning('Could not open %s. Skipping...', logFiles{k});
        continue;
    end
    sensorData = struct();
    for i = 1:numel(varTypes)
        fseek(fid, sum(varLengths(1:i-1)), 'bof');
        matlabType = typeMap(varTypes{i});
        sensorData.(varNames{i}) = single(fread(fid, Inf, ['*' matlabType], colLength - varLengths(i)));
    end
    fclose(fid);
    
    % --- C. Extract & Align ---
    depth_raw = double(sensorData.('depth'));
    sens_B    = double(sensorData.('AS7343_CH0'));  
    sens_G    = double(sensorData.('AS7343_CH15')); 
    sens_R    = double(sensorData.('AS7343_CH9'));  
    
    num_samples = min([numel(depth_raw), numel(sens_R), numel(sens_G), numel(sens_B)]);
    depth_raw = depth_raw(1:num_samples);
    sens_R    = sens_R(1:num_samples);
    sens_G    = sens_G(1:num_samples);
    sens_B    = sens_B(1:num_samples);
    
    % --- D. Smooth Data ---
    depth_smooth = smoothdata(depth_raw, 'movmedian', smoothWindow);
    sens_R_sm    = smoothdata(sens_R, 'movmedian', smoothWindow);
    sens_G_sm    = smoothdata(sens_G, 'movmedian', smoothWindow);
    sens_B_sm    = smoothdata(sens_B, 'movmedian', smoothWindow);
    
    % --- E. Filter Saturated Data (< 1000 Lux) ---
    % Create independent valid indices for each color channel
    valid_idx_R = depth_smooth > 0.1 & sens_R_sm < 1000;
    valid_idx_G = depth_smooth > 0.1 & sens_G_sm < 1000;
    valid_idx_B = depth_smooth > 0.1 & sens_B_sm < 1000;
    
    % If a trial has barely any valid data after filtering, skip it
    if sum(valid_idx_R) < 10 || sum(valid_idx_G) < 10 || sum(valid_idx_B) < 10
        continue; 
    end
    
    % --- F. Calculate Curved Line of Best Fit (Quadratic: Degree 2) ---
    p_R = polyfit(depth_smooth(valid_idx_R), sens_R_sm(valid_idx_R), 2);
    p_G = polyfit(depth_smooth(valid_idx_G), sens_G_sm(valid_idx_G), 2);
    p_B = polyfit(depth_smooth(valid_idx_B), sens_B_sm(valid_idx_B), 2);
    
    % Determine the depth range specifically based on the un-saturated data
    min_d = min([depth_smooth(valid_idx_R); depth_smooth(valid_idx_G); depth_smooth(valid_idx_B)]);
    max_d = max([depth_smooth(valid_idx_R); depth_smooth(valid_idx_G); depth_smooth(valid_idx_B)]);
    d_range = linspace(min_d, max_d, 100);
    
    % Evaluate the polynomial
    fit_R = polyval(p_R, d_range);
    fit_G = polyval(p_G, d_range);
    fit_B = polyval(p_B, d_range);
    
    % --- G. Plot the Fits ---
    p1 = plot(d_range, fit_R, '-', 'Color', [color_R, 0.7], 'LineWidth', 1.5);
    p2 = plot(d_range, fit_G, '-', 'Color', [color_G, 0.7], 'LineWidth', 1.5);
    p3 = plot(d_range, fit_B, '-', 'Color', [color_B, 0.7], 'LineWidth', 1.5);
    
    % Save handles for the legend
    if isempty(h_R)
        h_R = p1; h_G = p2; h_B = p3;
    end
end

%% 5. Finalize Plot Details
xlabel('Depth (m)');
ylabel('Lux (lm/m^2)');
title('Cropped & Curved Fit: RGB Lux vs Depth (6 Trials)');
legend([h_R, h_G, h_B], {'Red Fit', 'Green Fit', 'Blue Fit'}, 'Location', 'northeast');
hold off;
%% Final Project Plotting

%% Datatype sizes
dataSizes.('float')    = 4;
dataSizes.('ulong')    = 4;
dataSizes.('int')      = 4;
dataSizes.('int32')    = 4;
dataSizes.('uint8')    = 1;
dataSizes.('uint16')   = 2;
dataSizes.('char')     = 1;
dataSizes.('bool')     = 1;
dataSizes.('uint8_t')  = 1;
dataSizes.('uint16_t') = 2;
dataSizes.('uint32_t') = 4;
dataSizes.('int8_t')   = 1;
dataSizes.('int16_t')  = 2;
dataSizes.('int32_t')  = 4;

typeMap = containers.Map(...
    {'float','ulong','int','int32','uint8','uint16','char','bool',...
     'uint8_t','uint16_t','uint32_t','int8_t','int16_t','int32_t'},...
    {'float','uint32','int32','int32','uint8','uint16','uchar','uint8',...
     'uint8','uint16','uint32','int8','int16','int32'});

%%

% channel-to-wavelength mapping
channel_names = {
    'AS7343_CH12',  ... % 405 nm  (F1  - violet)
    'AS7343_CH6',   ... % 425 nm  (F2  - deep blue)
    'AS7343_CH0',   ... % 450 nm  (FZ  - blue, wide)
    'AS7343_CH7',   ... % 475 nm  (F3  - sky blue)
    'AS7343_CH8',   ... % 515 nm  (F4  - cyan-green)
    'AS7343_CH15',  ... % 550 nm  (F5  - green, narrow)
    'AS7343_CH1',   ... % 555 nm  (FY  - green, very wide)
    'AS7343_CH2',   ... % 600 nm  (FXL - orange, wide)
    'AS7343_CH9',   ... % 640 nm  (F6  - red-orange)
    'AS7343_CH13',  ... % 690 nm  (F7  - deep red)
    'AS7343_CH14',  ... % 745 nm  (F8  - near-IR edge)
    'AS7343_CH3',   ... % 855 nm  (NIR)
};

default_wavelengths = [405 425 450 475 515 550 555 600 640 690 745 855];

% set visually accurate wavelength colors for plotting
wavelength_colors = [
    0.55, 0.00, 0.85;   % 405 nm - violet
    0.25, 0.00, 1.00;   % 425 nm - deep blue-violet
    0.00, 0.20, 1.00;   % 450 nm - blue
    0.00, 0.60, 1.00;   % 475 nm - cyan-blue
    0.00, 0.90, 0.20;   % 515 nm - green
    0.60, 1.00, 0.00;   % 550 nm - yellow-green
    0.65, 1.00, 0.00;   % 555 nm - yellow-green
    1.00, 0.50, 0.00;   % 600 nm - orange
    1.00, 0.10, 0.00;   % 640 nm - red-orange
    0.85, 0.00, 0.00;   % 690 nm - deep red
    0.55, 0.00, 0.00;   % 745 nm - dark red (near-IR)
    0.25, 0.00, 0.00;   % 855 nm - very dark red (NIR)
];

% Depth binning resolution for averaged plots
depth_bin_size = 0.5; % meters

%% File input here
infofile = 'inf126.txt';
datafile = 'log126.bin';

% Read info file
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

%% Read binary data file
fid = fopen(datafile, 'rb');
sensorData = struct();
for i = 1:numel(varTypes)
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    matlabType = typeMap(varTypes{i});
    sensorData.(varNames{i}) = single(fread(fid, Inf, ['*' matlabType], colLength - varLengths(i)));
end
fclose(fid);

%% Extract depth and spectral channels
depth_raw = double(sensorData.('depth'));

num_channels = numel(channel_names);

% First pass: read all channels, find minimum length
channel_data = cell(num_channels, 1);
for c = 1:num_channels
    if isfield(sensorData, channel_names{c})
        channel_data{c} = double(sensorData.(channel_names{c}));
    else
        warning('Channel %s not found in data', channel_names{c});
        channel_data{c} = [];
    end
end

% Truncate everything to the shortest vector (fread stride rounding)
all_lengths = [numel(depth_raw); cellfun(@numel, channel_data)];
num_samples = min(all_lengths);

depth_raw = depth_raw(1:num_samples);

spectral_raw = nan(num_samples, num_channels);
for c = 1:num_channels
    if ~isempty(channel_data{c})
        spectral_raw(:, c) = channel_data{c}(1:num_samples);
    end
end

%% Bin data by depth
depth_min  = floor(min(depth_raw) / depth_bin_size) * depth_bin_size;
depth_max  = ceil( max(depth_raw) / depth_bin_size) * depth_bin_size;
depth_edges = depth_min : depth_bin_size : depth_max;
depth_bins  = depth_edges(1:end-1) + depth_bin_size/2;  % bin centers
num_bins    = numel(depth_bins);

intensities = nan(num_bins, num_channels);
for b = 1:num_bins
    in_bin = depth_raw >= depth_edges(b) & depth_raw < depth_edges(b+1);
    if any(in_bin)
        intensities(b, :) = mean(spectral_raw(in_bin, :), 1, 'omitnan');
    end
end

% Remove bins with no data
valid_bins  = any(~isnan(intensities), 2);
depth_bins  = depth_bins(valid_bins);
intensities = intensities(valid_bins, :);
num_bins    = numel(depth_bins);

%% Plot 1: Spectrum at one depth
figure(1); clf;
plot(default_wavelengths, intensities(1,:), 'k-o');
title(sprintf('Intensity by Wavelength at %.2f m depth', depth_bins(1)));
xlabel('Wavelength [nm]');
ylabel('Relative Intensity');

%% Plot 2: Peak wavelength vs depth
peak_wavelengths = nan(num_bins, 1);
for b = 1:num_bins
    [~, max_idx]       = max(intensities(b,:));
    peak_wavelengths(b) = default_wavelengths(max_idx);
end

figure(2); clf;
plot(depth_bins, peak_wavelengths, 'k-o');
title('Most Intense Wavelength vs Depth');
xlabel('Depth [m]');
ylabel('Peak Wavelength [nm]');

%% Plot 3: All spectra overlaid, one line per depth bin
figure(3); clf; hold on;
colors = jet(num_bins);
for b = 1:num_bins
    plot(default_wavelengths, intensities(b,:), ...
        'Color', colors(b,:), ...
        'DisplayName', sprintf('%.2f m', depth_bins(b)));
end
hold off;
colormap(jet);
cb = colorbar;
cb.Label.String = 'Depth [m]';
clim([depth_bins(1), depth_bins(end)]);
legend off;  % colorbar replaces legend for continuous depth
title('Intensity vs Wavelength at Various Depths');
xlabel('Wavelength [nm]');
ylabel('Relative Intensity');

%% Plot 4; each wavelength vs depth 
figure(4); clf; hold on;
for c = 1:num_channels
    plot(depth_bins, intensities(:,c), 'o-', ...
        'Color', wavelength_colors(c,:), ...
        'DisplayName', sprintf('%d nm', default_wavelengths(c)));
end
hold off;
legend('Location','best');
title('Intensity by Depth for Each Wavelength');
xlabel('Depth [m]');
ylabel('Relative Intensity');

%% Plot 5 wavelength vs depth heatmap
figure(5); clf;
imagesc(default_wavelengths, depth_bins, intensities);
set(gca, 'YDir', 'normal');
colorbar;
title('Spectral Intensity Heatmap');
xlabel('Wavelength [nm]');
ylabel('Depth [m]');

%% Summary
fprintf('Depth range: %.2f to %.2f m', ...
    depth_bins(1), depth_bins(end));
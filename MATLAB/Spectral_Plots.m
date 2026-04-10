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

%% Configuration
default_wavelengths = [405 425 450 475 515 550 555 600 640 690 745 855];

% FIX: updated to match exact INF field names
channel_names = {
    'AS7343_CH0',   ... % 405 nm
    'AS7343_CH1',   ... % 425 nm
    'AS7343_CH2',   ... % 450 nm
    'AS7343_CH3',   ... % 475 nm
    'AS7343_CH4',   ... % 515 nm
    'AS7343_CH5',   ... % 550 nm
    'AS7343_CH6',   ... % 555 nm
    'AS7343_CH7',   ... % 600 nm
    'AS7343_CH8',   ... % 640 nm
    'AS7343_CH9',   ... % 690 nm
    'AS7343_CH10',  ... % 745 nm
    'AS7343_CH11',  ... % 855 nm
};

file_pairs = {
    'inf080.txt', 'log080.bin', 0;
    'inf079.txt', 'log079.bin', 5;
    % add more rows here
};

num_depths   = size(file_pairs, 1);
num_channels = numel(channel_names);
Depth        = cell2mat(file_pairs(:,3)) .* 0.3048;
intensities  = nan(num_depths, num_channels); % FIX: was zeros, use nan

%% Read all files
%% Read all files
for d = 1:num_depths
    infofile = file_pairs{d,1};
    datafile = file_pairs{d,2};

    fileID = fopen(infofile);
    items  = textscan(fileID, '%s', 'Delimiter', ',', 'EndOfLine', '\r\n');
    fclose(fileID);

    ncols      = numel(items{1}) / 2;
    varNames   = items{1}(1:ncols)';
    varTypes   = items{1}(ncols+1:end)';
    varLengths = zeros(size(varTypes));
    colLength  = sum(varLengths); % FIX: calculate actual record size

    for i = 1:numel(varTypes)
        varLengths(i) = dataSizes.(varTypes{i});
    end
    colLength = sum(varLengths); % recalculate after filling varLengths

    fid = fopen(datafile, 'rb');
    sensorData = struct();
    for i = 1:numel(varTypes)
        fseek(fid, sum(varLengths(1:i-1)), 'bof');
        matlabType = typeMap(varTypes{i});
        sensorData.(varNames{i}) = single(fread(fid, Inf, ['*' matlabType], colLength - varLengths(i)));
    end
    fclose(fid);
    for c = 1:num_channels
        if isfield(sensorData, channel_names{c})
            intensities(d, c) = mean(sensorData.(channel_names{c}), 'omitnan');
        else
            warning('Channel %s not found', channel_names{c});
        end
    end
end

%% Plot 1: Spectrum at one depth
d = 1;
figure(1); clf;
plot(default_wavelengths, intensities(d,:));
% FIX: title() doesn't take sprintf-style args directly, wrap in sprintf
title(sprintf('Intensity by Wavelength at %.2f m', Depth(d)));
ylabel('Relative Intensity');
xlabel('Wavelength [nm]');

%% Plot 2: Peak wavelength vs depth (needs >1 depth)
peak_wavelengths = nan(num_depths, 1);
for i = 1:num_depths
    [~, max_idx]      = max(intensities(i,:));
    peak_wavelengths(i) = default_wavelengths(max_idx);
end

if num_depths > 1
    figure(2); clf;
    plot(Depth, peak_wavelengths);
    title('Most Intense Wavelength at Each Depth');
    xlabel('Depth [m]');
    ylabel('Wavelength [nm]');
end

%% Plot 3: All spectra overlaid, one line per depth
if num_depths > 1
    figure(3); clf; hold on;
    % FIX: legend is a built-in MATLAB function, don't use it as variable name
    % FIX: 'Display Name' had a space (invalid), use 'DisplayName'
    % FIX: loop used d as index but Depth(d) should be Depth(i)
    % FIX: ytitle/xtitle don't exist in MATLAB, use ylabel/xlabel
    for i = 1:num_depths
        plot(default_wavelengths, intensities(i,:), 'DisplayName', sprintf('%.2f m', Depth(i)));
    end
    hold off;
    legend('Location','best');
    title('Intensity vs Wavelength at Various Depths');
    xlabel('Wavelength [nm]');
    ylabel('Relative Intensity');
end

%% Plot 4: All channels vs depth, one line per wavelength
if num_depths > 1
    figure(4); clf; hold on;
    % FIX: loop variable was d but indexing used c, standardized to c
    for c = 1:num_channels
        plot(Depth, intensities(:,c), 'o-', 'DisplayName', sprintf('%d nm', default_wavelengths(c)));
    end
    hold off;
    legend('Location','best');
    title('Intensity by Depth for Each Wavelength');
    xlabel('Depth [m]');
    ylabel('Relative Intensity');
end

disp('Intensities matrix:')
disp(intensities)
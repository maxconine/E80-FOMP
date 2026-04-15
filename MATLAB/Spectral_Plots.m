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


% Correct channel-to-wavelength mapping for SparkFun AS7343 library
%  channels are NOT in wavelength order
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

file_pairs = {
    'inf100.txt', 'log100.bin', 0;
    'inf079.txt', 'log079.bin', 5;
    % add more rows here
};

num_depths   = size(file_pairs, 1);
num_channels = numel(channel_names);
Depth        = cell2mat(file_pairs(:,3));
intensities  = nan(num_depths, num_channels); % FIX: was zeros, use nan

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
colors = jet(num_depths);
for i = 1:num_depths
    plot(default_wavelengths, intensities(i,:), 'Color', colors(i,:), 'DisplayName', sprintf('%.2f m', Depth(i)));
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
    for c = 1:num_channels
        plot(Depth, intensities(:,c), 'o-', 'DisplayName', sprintf('%d nm', default_wavelengths(c)));
    end
    
    hold off;
    legend('Location','best');
    title('Intensity by Depth for Each Wavelength');
    xlabel('Depth [m]');
    ylabel('Relative Intensity');
end

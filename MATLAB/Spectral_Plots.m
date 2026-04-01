%Final Project Plotting
%run by section for certain plots
%take inputs as depth, spectral sensor data
%5 different spreadsheets, each has different depth?
%% map from datatype to length in bytes (logreader)
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int')   = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16')= 2;
dataSizes.('char')  = 1;
dataSizes.('bool')  = 1;



%set default wavelength values
default_wavelengths = [405 425 450 475 515 550 555 600 640 690 745 855];
channel_cols  = [1 2 3 4 5 6 7 8 9 10 11 13];

%set channel names
channel_names = {'CH_PURPLE_F1_405NM','CH_DARK_BLUE_F2_425NM', 'CH_BLUE_FZ_450NM','CH_LIGHT_BLUE_F3_475NM', 'CH_BLUE_F4_515NM','CH_GREEN_F5_550NM','CH_GREEN_FY_555NM','CH_ORANGE_FXL_600NM', 'CH_BROWN_F6_640NM','CH_RED_F7_690NM', 'CH_DARK_RED_F8_745NM', 'CH_NIR_855NM'};

%INF file, BIN file, associated depth
file_pairs = {
    'INF004.TXT', 'LOG004.BIN', 0;
    'INF005.TXT', 'LOG005.BIN', 5;
    %expand here
    };

num_depths = size(file_pairs, 1);
num_channels = numel(channel_names);

Depth = cell2mat(files(:,3)).*0.3048; %convert to meters

%define matrix size- x depths, y channels
intensities = zeros(num_depths, num_channels);




%% ---- READ EVERYTHING IN FIRST ----
% intensities is num_depths x num_channels
% row = one depth, col = one channel

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
    colLength  = 256;
    for i = 1:numel(varTypes)
        varLengths(i) = dataSizes.(varTypes{i});
    end

    fid = fopen(datafile, 'rb');
    bin = struct();
    for i = 1:numel(varTypes)
        fseek(fid, sum(varLengths(1:i-1)), 'bof');
        bin.(varNames{i}) = single(fread(fid, Inf, ['*' varTypes{i}], colLength - varLengths(i)));
    end
    fclose(fid);

    for c = 1:num_channels
        if isfield(bin, channel_names{c})
            intensities(d, c) = mean(bin.(channel_names{c}), 'omitnan');
        end
    end
end


%Plot intensity vs wavelength for a given depth
d = 1;
%set depth entry here
figure(1)
plot(default_wavelengths, intensities(d,:)') 
title('Intensity by wavelength for %.2fm', Depth(d));
ylabel('Relative intensity');
xlabel('Wavelength [nm]');

%plot highest intensity wavelength over depth
%for each depth (row of intensities) select largest intensity
peak_wavelengths = nan(num_depths, 1);
for i = 1:num_depths
    [~, max_idx] = max(intensities(i,:));       % index of brightest channel
    peak_wavelengths(i) = default_wavelengths(max_idx); % look up its wavelength
end

figure(2)
if num_depths > 1
    plot(Depth, peak_wavelengths);
    title("Most intense wavelength for each depth");
    ylabel('Wavelength (nm)');
    xlabel('Depth (m)');
end


%plot of magnitude on y axis vs wavelength on x axis with each line at a
%different depth

figure(3)
legend = cell(num_depths,1);
if num_depths > 1
    for i = 1:num_depths
        plot(default_wavelengths, intensities(i,:), 'Display Name', sprintf('%.2f m', Depth(d)));
    end
    ytitle('Relative intensity')
    xtitle('Wavelength [nm]')
    title('Intensity vs wavelength at various depths')
end

%plot of magnitude on y axis vs depth on x axis qith each line at a
%different wavelength
figure(4)
if num_depths > 3
for d = 1:num_channels
    plot(Depth, intensities(:,c), 'DisplayName', sprintf('%d nm', default_wavelengths(c)));
end
title('Intensity by Depth for Each Wavelength');
xlabel('Depth [m]');
ylabel('Relative Intensity');
end






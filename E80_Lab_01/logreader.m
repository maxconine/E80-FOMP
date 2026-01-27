% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '004'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

%% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

%% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

%% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);

%% Process your data here
axis_length = 0.1*size(accelX,1);
ymax = 2000;
ymin = -500;
% crop settings (seconds)
xmin = 1;
xmax = length(accelX) / 10;
time = linspace(0, axis_length, size(accelX,1)); %generate time axis

% X Axis acceleration
XFig = figure('Name', 'Accel-X');
plot(time, accelX); %plot data
axis([0 axis_length ymin ymax]); %format axis
xlim([xmin xmax])
grid on
title('X Acceleration Plot');
xlabel('Time (Seconds)');
ylabel('X-acceleration-axis');

% Y Axis acceleration
YFig = figure('Name', 'Accel-Y');
plot(time, accelY); %plot data
axis([0 axis_length ymin ymax]); %format axis
xlim([xmin xmax])
grid on
title('Y Acceleration Plot');
xlabel('Time (Seconds)');
ylabel('Y-acceleration-axis');

% Z Axis acceleration
ZFig = figure('Name', 'Accel-Z');
plot(time, accelZ); %plot data
axis([0 axis_length ymin ymax]); %format axis
xlim([xmin xmax])
grid on
title('Z Acceleration Plot');
xlabel('Time (Seconds)');
ylabel('Z-acceleration-axis');

% Crop data using xmin & xmax
accelX = accelX(xmin : xmax*10);
accelY = accelY(xmin : xmax*10);
accelZ = accelZ(xmin : xmax*10);
time = time(xmin : xmax*10);

% Export each plot to a .csv for stats processing. 
% Note that data is collected every 0.1 seconds.
writematrix(accelX, ['accelX_', filenum, '.csv']);
writematrix(accelY, ['accelY_', filenum, '.csv']);
writematrix(accelZ, ['accelZ_', filenum, '.csv']);
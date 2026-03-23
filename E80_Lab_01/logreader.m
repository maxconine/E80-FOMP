% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '016'; % file number for the data you want to read
infofile = strcat('inf', filenum, '.txt');
datafile = strcat('log', filenum, '.bin');

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

% Acceleration conversion (From lab data)
accelX = accelX;%* 0.01027254819;
accelY = accelY;% * 0.009546516154;
accelZ = accelZ;% * 0.009420916162;

axis_length = 0.1*size(accelX,1);
% crop settings 
ymax = 16;
ymin = -10;
xmin = 1400; 
xmax = 1850;
time = linspace(0, axis_length, size(accelX,1)); %generate time axis (Not used)

% X Axis acceleration
XFig = figure('Name', 'Accel-X');
set(XFig, 'color', [1 1 1]);
p1 = plot(accelX, 'r-'); %plot data

axis([0 axis_length ymin ymax]); %format y axis
xlim([xmin xmax]) % format x axis
grid on
title('XYZ Acceleration Plot');
xlabel('Sample #');
ylabel('Acceleration (m/s^2)');

hold on; % make plots overlayed on same fig

p2 = plot(accelY, 'g-'); %plot Y data
axis([0 axis_length ymin ymax]); %format axis
xlim([xmin xmax])
grid on

p3 = plot(accelZ, 'b-'); %plot Z data
axis([0 axis_length ymin ymax]); %format axis
xlim([xmin xmax])
grid on

legend('acceleration in x-axis', 'acceleration in y-axis', 'acceleration in z-axis');
% change width of lines
p1.LineWidth = 2;
p2.LineWidth = 2;
p3.LineWidth = 2;

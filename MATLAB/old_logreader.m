% logreader.m
% Use this script to read data from your micro SD card

clear;
clf;

filenum = '112'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

%% map from datatype to length in bytes
%% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('int32_t') = 4;    % Added
dataSizes.('uint32_t') = 4;   % Added
dataSizes.('uint8') = 1;
dataSizes.('uint8_t') = 1;    % Added
dataSizes.('uint16') = 2;
dataSizes.('uint16_t') = 2;   % Added this to fix your error
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
varTypes = strrep(varTypes, '_t', '');
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

% acceleration x vs tim
plot(accelX)
xlabel('time (s)')
ylabel('accelX')

% depth and depth desired
figure(2);
plot(depth)
xlabel('time (s)')
ylabel('depth (m)')
hold on;
plot(depth_des);

%
figure(3);
plot(depth, Therm_Raw);
xlabel('depth (m)')
ylabel('therm_raw (v)')

figure(4)
plot(Therm_Raw);


figure(5);
plot(AS7343_CH1);

figure(6);
plot(depth, AS7343_CH6, 'b');
hold on;
plot(depth, AS7343_CH2, 'y');

%  channels are NOT in wavelength order
% channel_names = {
%     'AS7343_CH12',  ... % 405 nm  (F1  - violet)
%     'AS7343_CH6',   ... % 425 nm  (F2  - deep blue)
%     'AS7343_CH0',   ... % 450 nm  (FZ  - blue, wide)
%     'AS7343_CH7',   ... % 475 nm  (F3  - sky blue)
%     'AS7343_CH8',   ... % 515 nm  (F4  - cyan-green)
%     'AS7343_CH15',  ... % 550 nm  (F5  - green, narrow)
%     'AS7343_CH1',   ... % 555 nm  (FY  - green, very wide)
%     'AS7343_CH2',   ... % 600 nm  (FXL - orange, wide)
%     'AS7343_CH9',   ... % 640 nm  (F6  - red-orange)
%     'AS7343_CH13',  ... % 690 nm  (F7  - deep red)
%     'AS7343_CH14',  ... % 745 nm  (F8  - near-IR edge)
%     'AS7343_CH3',   ... % 855 nm  (NIR)
% };


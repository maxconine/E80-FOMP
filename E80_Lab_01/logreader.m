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


%% 
%Statistical Measurements for accelerometer data
%figure out how to import data

% Script for analysis of data. It assumes the data set is stationary and
% does not have a functional dependence on other variables. For example, a
% set of readings from a voltmeter or mass readings from a scale would
% qualify.

A = importdata('test.csv')
%import second data set

B = importdata('test.csv')

% The inputs consist of the data set and the desired confidence level.
% The script calculates the following:
%    1. The mean or average of the data
%    2. The sample standard deviation of the data
%    3. The count of the data
%    4. The estimated standard error of the data
%    5. The Student-t value
%    6. The confidence interval
% It plots a histogram of the data, with a fitted normal distribution, and
% the 
data1 = A % Replace these with your data set
%second data set
data2 = B
confLev = 0.95;
xbar = mean(data1) % Arithmetic mean
S = std(data1) % Standard Deviation
N = length(data1); % Count
ESE = S/sqrt(N) % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE;% 1/2 of the confidence interval ąlambda
conf_interval = 2*lambda

%two-sided t test
[h,p,ci,stats] = ttest2(data1,data2)


h = histfit(data1); % Plot histogram and normal curve
hold on
bob = get(h(2)); % Get the normal curve data
mx = max(h(2).YData); % Get the max in the normal curve data
line([xbar xbar], [0 mx*1.05], 'LineWidth',3) % Plot a line for the mean
line([xbar-S xbar-S], [0 mx*0.65], 'LineWidth',3) % Plot a line for 1 S
                                                  % below the mean
line([xbar+S xbar+S], [0 mx*0.65], 'LineWidth',3) % Plot a line for
                                                  % 1 S above the mean
line([xbar-lambda xbar+lambda], [mx*1.07 mx*1.07]) % Plot the conf. int.
line([xbar-lambda xbar-lambda], [mx*1.02 mx*1.12])
line([xbar+lambda xbar+lambda], [mx*1.02 mx*1.12])
title('Histogram and Fitted Normal Distribution of Data')
xlabel('Data Range')
ylabel('Count')
txt2 = '$\leftarrow \bar{x} + S$';
text(xbar+S,mx*0.65,txt2,'Interpreter','latex')
txt3 = '$\bar{x} - S \rightarrow$';
text(xbar-S-0.55*S,mx*0.65,txt3,'Interpreter','latex')
txt4 = '  Confidence Interval';
text(xbar+lambda,mx*1.07,txt4)
hold off

Displaying FIGURE_20180724_01_CalculateStatsForDataSet.m.



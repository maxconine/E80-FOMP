%Statistical Measurements for accelerometer data
%figure out how to import data

% Script for analysis of data. It assumes the data set is stationary and
% does not have a functional dependence on other variables. For example, a
% set of readings from a voltmeter or mass readings from a scale would
% qualify.

%accelX_filenumber.csv
X = importdata('test.csv');d
%import second data set

%accelX_filenumber.csv
Y = importdata('test.csv');

%accelX_filenumber.csv
Z = importdata('test.csv');

data1 = X;
data2 = Y;
data3 = Z;

confLev = 0.95;

%mean
disp('means')
xbarX = mean(data1) 
xbarY = mean(data2)
XbarZ = mean(data3)

% Standard Deviation
disp('standard deviation')
SX = std(data1) 
SY = std(data2)
SZ = std(data3)

%count
N1 = length(data1);
N2 = length(data2);
N3 = length(data3);

disp('esimated standard error')
% Estimated Standard Error
ESEX = SX/sqrt(N1) 
ESEY = SY/sqrt(N2)
ESEZ = SZ/sqrt(N3)

% tinv is for 1-tailed, for 2-tailed we need to halve the range
% The Student t value
StdT1 = tinv((1-0.5*(1-confLev)),N1-1); 
StdT2 = tinv((1-0.5*(1-confLev)),N2-1); 
StdT3 = tinv((1-0.5*(1-confLev)),N3-1); 

disp('confidence intervals')

lambdaX = StdT1*ESEX;   % 1/2 of the confidence interval ąlambda
conf_intervalX = 2*lambdaX

lambdaY = StdT2*ESEY;   % 1/2 of the confidence interval ąlambda
conf_intervalY = 2*lambdaY

lambdaZ = StdT3*ESEZ;% 1/2 of the confidence interval ąlambda
conf_intervalZ = 2*lambdaZ


%two-sided t test

disp('comparing x axis and y axis zeroes')
[h1,p1,ci1,stats1] = ttest2(data1,data2)

disp('comparing x axis and z axis zeroes')
[h2,p2,ci2,stats2] = ttest2(data1,data3)

disp('comparing z axis and y axis zeroes')
[h3,p3,ci3,stats3] = ttest2(data2,data3)



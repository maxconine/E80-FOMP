% Team 23
% Freja, Max, Pierce, Octavia
% Feb 11 2026

% Example Data:
x = [11 870 632 222]; % x should be calibrated turbidity of the solutions NTU
y = [0.1441077441 0.07803921569 0.07960784314 0.09294117647]; % ratio of the 90° Vpp to the transmission Vpp

% OUR DATA
% x = [0.1 0.2 0.4 0.6 0.8]; % x should be calibrated turbidity of the solutions NTU
% y = [0.5 1 2.5 3 4]; % ratio of the 90° Vpp to the transmission Vpp

% Line of best fit has equation y=beta0 ​+ beta1​*x
% Slope 95% conf. interval: beta1 ± lambdaBeta1
% Intercept 95% conf. interval: beta0 ± lambdaBeta0

% Script for the linear fit of data. The independent values are
% in the x array and the matched dependent values are in the y array. This
% script does not use MATLAB's built-in fitting functions, but uses the
% formulas from the videos/class notes.
% You also need to enter the confidence level, typically 95%. The values
% that are calculated and displayed are:
% 1. Beta_hat_1 (the best-fit slope)
% 2. Beta_hat_0 (the best-fit y-intercept)
% 3. The Root Mean Square Residual, Se
% 4. The Standard Error for beta0, Sbeta0
% 5. The Standard Error for beta1, Sbeta1
% 6. The confidence intervals for beta1 and beta0.
% After calculating these quantities, the script plots the original data,
% the best fit line, and the upper and lower bounds for the confidence
% interval on the best fit line.
confLev = 0.95; % The confidence level
N = length(y); % The number of data points
xbar = mean(x);
ybar = mean(y);
Sxx = dot((x-xbar),(x-xbar));
%Sxx = (x-xbar)*transpose(x-xbar);
% beta1 is the estimated best slope of the best-fit line
beta1 = dot((x-xbar),(y-ybar))/Sxx
% beta1 = ((x-xbar)*transpose(y-ybar))/Sxx
% beta0 is the estimated best-fit y-intercept of the best fit line
beta0 = ybar - beta1*xbar
yfit = beta0 + beta1*x;
SSE = dot((y - yfit),(y - yfit)) % Sum of the squared residuals
% SSE = (y - yfit)*transpose(y - yfit) % Sum of the squared residuals
Se = sqrt(SSE/(N-2)) % The Root Mean Square Residual
Sbeta0 = Se*sqrt(1/N + xbar^2/Sxx)
Sbeta1 = Se/sqrt(Sxx)
% tinv defaults to 1-sided test. We need 2-sises, hence:(1-0.5*(1-confLev))
StdT = tinv((1-0.5*(1-confLev)),N-2) % The Student's t factor
lambdaBeta1 = StdT*Sbeta1 % The 1/2 confidence interval on beta1
lambdaBeta0 = StdT*Sbeta0 % The 1/2 confidence interval on beta0
range = max(x) - min(x);
xplot = min(x):range/30:max(x); % Generate array for plotting
yplot = beta0 + beta1*xplot; % Generate array for plotting
Syhat = Se*sqrt(1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambdayhat = StdT*Syhat;
Sy = Se*sqrt(1+1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambday = StdT*Sy;
figure(1)
plot(x,y,'x')
hold on
plot(xplot,yplot)
plot(xplot,yplot+lambdayhat,'-.b',xplot,yplot-lambdayhat,'-.b')
plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
xlabel('Calculated Turbidity Measurements')
ylabel('Ratio of 90 degree Vpp to trasmission Vpp')
if beta1 > 0
   location = 'northwest';
else
   location = 'northeast';
end
bfl = sprintf('Best Fit Line: y = %.3f + %.5fx', beta0, beta1); % 3 decimal places
legend('Data Points',bfl,'Upper Func. Bound',...
   'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
   'Location', location)
hold off

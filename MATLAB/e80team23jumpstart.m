% e80team23jumpstart.m
% This file uses measured data of the robot's acceleration in the x and y
% direction to cacluate the robot's velocity and position, and
% then adds gaussian white noise to the true acceleration to generate the
% simulated measured acceleration. It then integrates the measured
% acceleration once to get calculated velocity, and then a second time to
% get calculated position. It calculates the error bounds for the position
% and velocity based on the standard deviation of the sensor and the
% specified confidence level.

dt = 0.01; % The sampling rate
t = 0:dt:20; % The time array (unsure, might have to be longer)
%a = 1 + sin( pi*t -pi/2); % The modeled acceleration
%la = length(a);
%la2 = round(length(a)/5);
%a([la2:end]) = 0; % We only want one cycle of the sine wave.

accels = readtable("b12.csv");
accels = accels';
ax = accels(1,:);
ay = accels (2,:);
lax = length(ax);
lay = length (ay);

sigma = .2; % The standard deviation of the noise in the accel.
confLev = 0.95; % The confidence level for bounds
preie = sqrt(2)*erfinv(confLev)*sigma*sqrt(dt); % the prefix to the sqrt(t)
preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
plusie=preie*t.^0.5; % The positive noise bound for one integration
plusiie = preiie*t.^1.5; % The positive noise bound for double integration

% for ax
en_x = sigma*randn(1, lax); % Generate the noise
vx = cumtrapz(t,ax); % Integrate the true acceleration to get the true velocity
rx = cumtrapz(t,vx); % Integrate the true velocity to get the true position.
an_x = ax + en; % Generate the noisy measured acceleration
vn_x = cumtrapz(t,an_x); % Integrate the measured acceleration to get the velocity
vnp_x = vn_x + plusie; % Velocity plus confidence bound
vnm_x = vn_x - plusie; % Velocity minus confidence bound
rn_x = cumtrapz(t,vn_x); % Integrate the velocity to get the position
%rnp_x = rn_x + plusiie; % Position plus confidence bound
%rnm_x = rn_x - plusiie; % Position minus confidence bound

% for ay
en_y = sigma*randn(1, lay); % Generate the noise
vy = cumtrapz(t,ay); % Integrate the true acceleration to get the true velocity
ry = cumtrapz(t,vy); % Integrate the true velocity to get the true position.
an_y = ay + en_y; % Generate the noisy measured acceleration
vn_y = cumtrapz(t,an_y); % Integrate the measured acceleration to get the velocity
vnp_y = vn_y + plusie; % Velocity plus confidence bound
vnm_y = vn_y - plusie; % Velocity minus confidence bound
rn_y = cumtrapz(t,vn_y); % Integrate the velocity to get the position
%rnp_y = rn_y + plusiie; % Position plus confidence bound
%rnm_y = rn_y - plusiie; % Position minus confidence bound


% linear regression for plotting x vs y position
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
N = length(rn_x); % The number of data points
xbar = mean(rn_x);
ybar = mean(rn_y);
Sxx = dot((rn_x-xbar),(rn_x-xbar));
%Sxx = (rn_x-xbar)*transpose(x-xbar);
% beta1 is the estimated best slope of the best-fit line
beta1 = dot((rn_x-xbar),(rn_y-ybar))/Sxx
% beta1 = ((rn_x-xbar)*transpose(rn_y-ybar))/Sxx
% beta0 is the estimated best-fit y-intercept of the best fit line
beta0 = ybar - beta1*xbar
yfit = beta0 + beta1*rn_x;
SSE = dot((rn_y - yfit),(rn_y - yfit)) % Sum of the squared residuals
% SSE = (rn_y - yfit)*transpose(rn_y - yfit) % Sum of the squared residuals
Se = sqrt(SSE/(N-2)) % The Root Mean Square Residual
Sbeta0 = Se*sqrt(1/N + xbar^2/Sxx)
Sbeta1 = Se/sqrt(Sxx)
% tinv defaults to 1-sided test. We need 2-sises, hence:(1-0.5*(1-confLev))
StdT = tinv((1-0.5*(1-confLev)),N-2) % The Student's t factor
lambdaBeta1 = StdT*Sbeta1 % The 1/2 confidence interval on beta1
lambdaBeta0 = StdT*Sbeta0 % The 1/2 confidence interval on beta0
range = max(rn_x) - min(rn_x);
xplot = min(rn_x):range/30:max(rn_x); % Generate array for plotting
yplot = beta0 + beta1*xplot; % Generate array for plotting
Syhat = Se*sqrt(1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambdayhat = StdT*Syhat;
Sy = Se*sqrt(1+1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambday = StdT*Sy;

figure(1)
plot(rn_x,rn_y,'rn_x')
hold on
plot(xplot,yplot)
plot(xplot,yplot+lambdayhat,'-.b',xplot,yplot-lambdayhat,'-.b')
plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
xlabel('x Position (m)')
ylabel('y Position(m)')
title('x vs y Robot Position')
%if beta1 > 0 % Fix this
%    location = 'northwest';
%else
%    location = 'northeast';
%end
%legend('Data Points','Best Fit Line','Upper Func. Bound',...
%    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
%    'Location', location)
hold off


% linear regression for plotting y position vs time
N = length(rn_y); % The number of data points
xbar = mean(t);
ybar = mean(rn_y);
Sxx = dot((t-xbar),(t-xbar));
%Sxx = (rn_x-xbar)*transpose(x-xbar);
% beta1 is the estimated best slope of the best-fit line
beta1 = dot((t-xbar),(rn_y-ybar))/Sxx
% beta1 = ((t-xbar)*transpose(rn_y-ybar))/Sxx
% beta0 is the estimated best-fit y-intercept of the best fit line
beta0 = ybar - beta1*xbar
yfit = beta0 + beta1*t;
SSE = dot((rn_y - yfit),(rn_y - yfit)) % Sum of the squared residuals
% SSE = (rn_y - yfit)*transpose(rn_y - yfit) % Sum of the squared residuals
Se = sqrt(SSE/(N-2)) % The Root Mean Square Residual
Sbeta0 = Se*sqrt(1/N + xbar^2/Sxx)
Sbeta1 = Se/sqrt(Sxx)
% tinv defaults to 1-sided test. We need 2-sises, hence:(1-0.5*(1-confLev))
StdT = tinv((1-0.5*(1-confLev)),N-2) % The Student's t factor
lambdaBeta1 = StdT*Sbeta1 % The 1/2 confidence interval on beta1
lambdaBeta0 = StdT*Sbeta0 % The 1/2 confidence interval on beta0
range = max(t) - min(t);
xplot = min(t):range/30:max(t); % Generate array for plotting
yplot = beta0 + beta1*xplot; % Generate array for plotting
Syhat = Se*sqrt(1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambdayhat = StdT*Syhat;
Sy = Se*sqrt(1+1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambday = StdT*Sy;

figure(2)
plot(t,rn_y,'rn_y')
hold on
plot(xplot,yplot)
plot(xplot,yplot+lambdayhat,'-.b',xplot,yplot-lambdayhat,'-.b')
plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
xlabel('Time (s)')
ylabel('y Position (m)')
title('Robot y Position Over Time')
%if beta1 > 0 % Fix this
%    location = 'northwest';
%else
%    location = 'northeast';
%end
%legend('Data Points','Best Fit Line','Upper Func. Bound',...
%    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
%    'Location', location)
hold off
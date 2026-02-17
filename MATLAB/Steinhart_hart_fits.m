%% Non-linear data fitting. 
% Since we are fitting the Steinhart-Hart equation to the
%  data, we first converted the temperature to Kelvin. Next, because the
%  Steinhart-Hart equation has T as a function of R, we use T or 1/T as y
%  and R or ln(R) as x. 

% Insert 6 digital thermometer temperatures here
T = [0 15 30 45 60 70 80];

% Insert 6 resistance values here
R = [29510 15710 8777 4543 2200 750 250];


confLev = 0.95; % We set the confidence level for the data fits here.


% Since a plot of 1/T vs ln(R) should be close to linear, we will convert
% the data to the correct forms and do linear and polynomial fits with
% them.
ooT = 1./T;
lnR = log(R);


%We need starting guess for the steinhart fit, so run a polynomial fit
[Xout,Yout] = prepareCurveData(lnR, ooT); 
[f3,stat3] = fit(Xout,Yout,'poly3'); % 3rd-order fit with statistics.
%Now we can plot the steinhart hart fit

%% Nonlinear Fit
% do a non-linear fit using the Steinhart-Hart equation (but we'll include
% the 2nd-order term.
range = max(R) - min(R); % Get range for our xplot data
xplot = min(R):range/30:max(R); % Generate x data for some of our plots.

% First we have to define the function we will fit.
% Things work better if we have starting points for a, b, c, and d. We'll
% use our values from above and 'fitoptions'
fo = fitoptions('Method','NonlinearLeastSquares',...
    'StartPoint',[f3.p4 f3.p3 f3.p2 f3.p1]);
ft = fittype('1/(a+b*log(R)+c*(log(R)^2)+d*(log(R)^3))','independent',...
    'R','options',fo);
% Next, we have to get our data into the correct format for 'fit'.
[Xout,Yout] = prepareCurveData(R, T); 
% Now we'll do our fit.
[f4,stat4] = fit(Xout,Yout,ft);
f4
p11 = predint(f4,xplot,confLev,'observation','off'); % Gen conf bounds
p21 = predint(f4,xplot,confLev,'functional','off'); % Gen conf bounds
figure(8)
plot(f4,Xout,Yout) 
hold on
plot(xplot, p21, '-.b') % Upper and lower functional confidence limits
plot(xplot, p11, '--m') % Upper and lower observational confidence limits
xlabel('Resistance (\Omega)')
ylabel('Temperature (K)')
title('Steinhart-Hart Fit, Noisy Data')
legend('Data Points','Best Fit Line','Upper Func. Bound',...
    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
    'Location', 'northeast')
hold off

%% Nonlinear Residuals
% And finally, the residuals
figure(9)
plot(f4,Xout,Yout,'residuals')
xlabel('Resistance (\Omega)')
ylabel('Residuals (K)')
title('Steinhart-Hart Fit')
%voltage depth calibration
%voltages here
V = [0 15 30 45 80];

% Depth here
D = [0 10 20 30 40];

confLev = 0.95;

[f,stat] = fit(D',V', 'poly1');
figure(1)
plot(f,D, V)
range = max(D) - min(D); % Get range for our xplot data
xplot = min(D):range/30:max(D);

p11 = predint(f,xplot,confLev,'observation','off'); % Gen conf bounds
p21 = predint(f,xplot,confLev,'functional','off'); % Gen conf bounds


xlabel('Voltage [V]')
ylabel('Depth [cm]')
title('Depth vs Voltage Plot')
hold on
plot(xplot, p21, '-.b') % Upper and lower functional confidence limits
plot(xplot, p11, '--m')
legend('Data Points','Best Fit Line','Upper Func. Bound',...
    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
    'Location', 'northwest')
hold off
stat

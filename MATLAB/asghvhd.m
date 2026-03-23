%voltage depth calibration
%voltages here
D = [0.82271294
0.82901336
0.83531378
0.84154991
0.84785033];
% Depth here
V = [1.98
1.75
1.59
1.38
1.25];
confLev = 0.95;
[f,stat] = fit(D,V, 'poly1');
figure(1)
plot(f,D, V)
range = max(D) - min(D); % Get range for our xplot data
xplot = min(D)-5:range/30:max(D)+5;
p11 = predint(f,xplot,confLev,'observation','off'); % Gen conf bounds
p21 = predint(f,xplot,confLev,'functional','off'); % Gen conf bounds
xlabel('Op-Amp Input [V]')
ylabel('Op-Amp Output [V]')
title('Op-Amp Input vs Output Plot')
hold on
plot(xplot, p21, '-.b') % Upper and lower functional confidence limits
plot(xplot, p11, '--m')
legend('Data Points','Best Fit Line','Upper Func. Bound',...
   'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
   'Location', 'northwest')
hold off
stat
f

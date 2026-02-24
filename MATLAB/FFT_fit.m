%Fitting a model to acoustic data

%insert data here
Vdata = [1 1/2 1/3 1/4 1/5 1/6 1/7];
Ddata = [1 2 3 4 5 6 7];

%analytical model

myfittype = fittype("k*(1/Ddata)", ...
    dependent = "Vdata", independent = "Ddata", ...
    coefficients=["k"]);

%this line prints out the constant of proportionality
myfit = fit(Ddata', Vdata', myfittype)

%plot analytical model
figure(1)
plot(Ddata, Vdata) 
hold on
plot(myfit,Ddata, Vdata);
xlabel('Distance from source (meters)')
ylabel('Voltage recorded (dBV)')
title('Voltage in dBV vs distance from source (meters)')
legend('Analytical Model','Data Points')

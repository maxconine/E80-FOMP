%% Lab 5 Interface

samplingFreq = 100E3; % Hz [100E3 max]
numSamples = 1000; % the higher this is the longer sampling will take

bytesPerSample = 2; % DO NOT CHANGE
micSignal = zeros(numSamples,1); % DO NOT CHANGE

% close and delete serial ports in case desired port is still open
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% Modify first argument of serial to match Teensy port under Tools tab of Arduino IDE.  Second to match baud rate.
% Note that the timeout is set to 60 to accommodate long sampling times.
s = serial('usb:1100000','BaudRate',115200); 
set(s,{'InputBufferSize','OutputBufferSize'},{numSamples*bytesPerSample,4});
s.Timeout = 60; 

fopen(s);
pause(2);
fwrite(s,[numSamples,samplingFreq/2],'uint16');
dat = fread(s,numSamples,'uint16');
fclose(s);

% Some convenience code to begin converting data for you.
micSignal = dat.*(3.3/1023); % convert from Teensy Units to Volts
samplingPeriod = 1/samplingFreq; % s
totalTime = numSamples*samplingPeriod; % s
t = linspace(0,totalTime,numSamples)'; % time vector of signal

%% Code for plotting
samplingPeriod = 1/samplingFreq; % s
totalTime = numSamples*samplingPeriod; % s
t = linspace(0,totalTime,numSamples)'; % time vector of signal

% For plotting time series
figure;
plot(t, micSignal, '-o');
xlabel('Time (s)');
ylabel('Voltage (V)');
title(sprintf('Time samples for %g kS/s data', samplingFreq/1e3));

[X2,f2] = fdomain(micSignal, samplingFreq);

% uncomment these lines when ready to run this part
% Note you need to convert from frequency to wavenumber for the horizontal axis
% To=numSamples/samplingFreq;
% k = f2*To;

stem(f2,abs(X2))
xlabel('wavenumber k')
ylabel('Magnitude X[k]')
title(sprintf('FFT magnitude for %g kS/s data', samplingFreq/1e3));


% For plotting stem plot
N = numSamples;
T = numSamples/samplingFreq;
% w = hann(N)'; % hann window
% xw = x .* w; % hann window of x
% 
% % From fdomain.m
% if mod(N,2)==0
%     k=-N/2:N/2-1; % N even
% else
%     k=-(N-1)/2:(N-1)/2; % N odd
% end
% 
% f=k/T;     % wavenumbers (k) divided by T0 = frequencies
% X=fft(x)/N    ; % Matlab's FFT uses a different convention without the 1/N so we put it in here.
% X=fftshift(X);
% 
% figure;
% stem(f/1000,abs(X));
% xlabel('Frequency (kHz)');
% ylabel('Magnitude (X)');
% title(sprintf('FFT magnitude for %g kS/s data', samplingFreq/1e3));


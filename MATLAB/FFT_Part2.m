% Team 23 Lab 5
% Max, Octavia, Pierce, Freja
% Feb 25, 2026

clear; clc; close all;

% Read our data
x = readtable('scope_31.csv');
x = x(3:end, :); % remove first 2 rows
fs = 12500000; %1 / abs((x(2,1) - x(1,1))); % fs = 1/diff in time
x = x(:,2); % get right column
new_x = table2array(x);
N = length(new_x);
T = N/fs;

% % From fdomain.m
if mod(N,2)==0
    k=-N/2:N/2-1; % N even
else
    k=-(N-1)/2:(N-1)/2; % N odd
end

f=k/T;     % wavenumbers (k) divided by T0 = frequencies
X=fft(abs(new_x))/N    ; % Matlab's FFT uses a different convention without the 1/N so we put it in here.
X=fftshift(X);

figure(1);
stem(f/1000,abs(X));
xlabel('Frequency (kHz)');
ylabel('Magnitude (X)');

% draw now;
% [X2,f2] = fdomain(new_x, fs);
% 
% % uncomment these lines when ready to run this part
% % Note you need to convert from frequency to wavenumber for the horizontal axis
% To=N/fs;
% k = f2*To;
% 
% stem(k,abs(X2))
% xlabel('wavenumber k')
% ylabel('X[k]')

% w = hann(N)'; % hann window to avoid discontinuity
% xw = x .* w; % hann window of x
% 
% 11kHz Sine Wave Example
% f0 = 11000; % signal frequency (Hz)
% A  = 1.5; % Vp
% fs = 100000; % 2*f0 (Maximum 1 Ghz on osciliscope)
% T  = 0.02; % total sampling time (seconds)
% N = round(T*fs); % number of samples
% t = (0:N-1)/fs;
% x = A*sin(2*pi*f0*t); % sin wave
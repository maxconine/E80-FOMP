
filenum = '013'; % file number for the data you want to read
 X = importdata(['accelX_', filenum, '.csv']);
 %import second data set
 
% %accelY_filenumber.csv
 Y = importdata(['accelY_', filenum, '.csv']);
% 
% %accelZ_filenumber.csv
 Z = importdata(['accelZ_', filenum, '.csv']);

data_x = X;
data_y = Y;
data_z = Z;

% Define the range for x
x = [data_x(0), length(data_x)]; 

% Define the functions
y1 = sin(x);
y2 = cos(x);
y3 = sin(x - 0.5);

% Start a new figure window (optional but good practice)
figure;

% Plot the first function
plot(x, y1, 'r-'); % 'r-' specifies a red solid line

% Hold the current plot so subsequent plots are added to the same axes
hold on; 

% Plot the other functions
plot(x, y2, 'b--'); % 'b--' specifies a blue dashed line
plot(x, y3, 'g:');  % 'g:' specifies a green dotted line

% Add labels, title, and legend
xlabel('X values');
ylabel('Y values');
title('Multiple Functions Plot using hold on');
legend('sin(x)', 'cos(x)', 'sin(x-0.5)');

% Turn off the hold state
hold off;

% Add a grid for better readability (optional)
grid on;

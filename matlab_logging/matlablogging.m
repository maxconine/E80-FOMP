% matlablogging
% reads from Teensy data stream

function teensyanalog=matlablogging(length)
    length = 5000;  % 5000 is hardcoded buffer size on Teensy
    s = serial('COM7','BaudRate',115200);
    set(s,'InputBufferSize',2*length)
    fopen(s);
    fprintf(s,'%d',2*length)         % Send length to Teensy
    dat = fread(s,2*length,'uint8');      
    fclose(s);
    teensyanalog = uint8(dat);
    teensyanalog = typecast(teensyanalog,'uint16');
end


%str = fscanf(s);
%teensyanalog = str2num(str);

%[teensyanalog, count] = fscanf(s,['%d']);

%% Plot data -- RUN SECTIONS SEPARATE
data = teensyanalog(5000);

axis_length = size(data);

% Voltage vs sample $
Fig = figure('Name', 'Teensy Unit Voltage vs Sample Number');
set(Fig, 'color', [1 1 1]);
p1 = plot(data); % plot data
p1(1).LineWidth = 3; % change line width

% axis([0 axis_length ymin ymax]); %format y axis
% xlim([xmin xmax]) % format x axis
grid on
title('Teensy Unit Voltage vs Sample Number');
xlabel('Sample #');
ylabel('Teensy Unit Voltage');
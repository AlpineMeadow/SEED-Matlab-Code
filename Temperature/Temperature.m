%This script will read in the data files from the TVAC output and fix them
%and plot them.

dbstop if error;

clearvars;
close all;
fclose('all');

filename = '/home/jdw/Downloads/TemperatureValues_07-25-2023_121057.txt';
TemperatureFileName = '/home/jdw/Downloads/TVACTesting07252023.png';

TData = importdata(filename);

lastDataValue = 3217;
TData(871, 4) = 13;
TData(877, 4) = 13;

fig = figure();
fig.Position = [750 25 1200 500];

subplot(3, 1, 1)
plot(TData(1:lastDataValue, 7))
title('Control')
ylabel('Temperature ^{\circ}C')

subplot(3, 1, 2)
plot(TData(1:lastDataValue, 4))
title('Experiment')
ylabel('Temperature ^{\circ}C')
subplot(3, 1, 3)

plot(TData(1:lastDataValue, 6))
title('Plate')
xlabel('Time (s)')
ylabel('Temperature ^{\circ}C')

%Save the time series to a file.
saveas(fig, TemperatureFileName);
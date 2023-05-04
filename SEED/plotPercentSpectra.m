%This script will plot the percent of spectra per day for the year 2022.

dbstop if error;

clearvars;
close all;
fclose('all');

%Read in the data file.
numSpectraFilename = '/SS1/STPSat-6/SummaryNumSpectra.txt';

A = readmatrix(numSpectraFilename);

percentPre = mean(A(1:138, 3));
percentDuring = mean(A(139:229, 3));
percentAfter = mean(A(230:end, 3));

percentPreStr = ['Percent Possible : ', num2str(percentPre, '%4.2f'), '%'];
percentDuringStr = ['Percent Possible : ', num2str(percentDuring, '%4.2f'), '%'];
percentAfterStr = ['Percent Possible : ', num2str(percentAfter, '%4.2f'), '%'];
yearlyPercentStr = ['Yearly Percent Coverage : ', num2str(92.57), '%'];

%Set up some plotting variables.
satellite = "Falcon";
instrument = "SEED";
plotType = "Percent Valid Spectra ";
dateStr = '2022';


titStr = satellite + " " + instrument + " " + plotType + " " + dateStr;

saveName = satellite + instrument + "_PercentValidSpectra" + "_2022";

percentSpectraFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

fig1 = figure();
fig1.Position = [750 25 1200 500];

p = plot(A(:,1), A(:,3), [139, 139],[0, 100], 'black', [229, 229], [0 100], 'black');
p(1).LineWidth = 2;
p(2).LineWidth = 3;
p(3).LineWidth = 3;
title(titStr);
ylim([0 100])
xlim([A(1,1) A(end, 1)])
ylabel('Percent Possible Spectra')
xlabel('Days of Year')
text('Units', 'Normalized', 'Position', [0.01, 0.9], 'string', 'Original Reset Schedule  -- 20 Minutes', ...
      'FontSize', 12, 'FontWeight', 'bold');
text('Units', 'Normalized', 'Position', [0.05, 0.8], 'string', percentPreStr, ...
      'FontSize', 12, 'FontWeight', 'bold');
text('Units', 'Normalized', 'Position', [0.03, 0.65], 'string', yearlyPercentStr, ...
      'FontSize', 12, 'FontWeight', 'bold');
text('Units', 'Normalized', 'Position', [0.36, 0.9], 'string', 'New Schedule -- 40 Minutes', ...
      'FontSize', 12, 'FontWeight', 'bold');
text('Units', 'Normalized', 'Position', [0.37, 0.8], 'string', percentDuringStr, ...
      'FontSize', 12, 'FontWeight', 'bold');
text('Units', 'Normalized', 'Position', [0.65, 0.9], 'string', 'Original Reset Schedule -- 20 Minutes', ...
      'FontSize', 12, 'FontWeight', 'bold');
text('Units', 'Normalized', 'Position', [0.65, 0.8], 'string', percentAfterStr, ...
      'FontSize', 12, 'FontWeight', 'bold');


%Save the time series to a file.
saveas(fig1, percentSpectraFileName);










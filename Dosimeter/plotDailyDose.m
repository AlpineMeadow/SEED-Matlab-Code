function plotDailyDose(info, totalDosePerDay, dailyDose, dailyDoseRate, ...
    time, numTimeEventsPerDay, includedDays)

%This function will produce plots of the dosimeter data.
%This function is called by Dosimeter.m.

plotName = 'DosimeterSummary_';

%Create an outfile name.  If the time span is more than a year handle that
%specially.
outFilename = [info.dosimeterPlotDir, plotName, info.startDateStr, ...
    '_', info.startDayOfYearStr, '-', info.endDateStr, '_', ...
    info.endDayOfYearStr, '_.png'];
dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr, ...
	' - ', info.endYearStr '/', info.endMonthStr, '/', info.endDayOfMonthStr];

%Set a variable to the number of events.
numEvents = length(dailyDose.channel1);

%Set up some daily variables.
xtit = 'Time (hours)';

%Set up a vector of values to be used in the xticks plot function.
xtickValues = [1:numEvents/24:numEvents, numEvents];
xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
    ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};
JulianDay = info.startDayOfYearStr;

% 
% %Lets find the cumulative dose.
% cumulativeDose = zeros(1, numEvents);
% for i = 1 : numEvents
%     if (i == 1) 
%         cumulativeDose(i) = dosePerDay(i);
%     else
%         cumulativeDose(i) = cumulativeDose(i - 1) + dosePerDay(i);
%     end
% end  %End of for loop - for i = 1 : numEvents

%We need to deal with the missing days.
% channel1DosePerDay = NaN(1, numEvents);
% totalCumulativeDose = NaN(1, numEvents);

% for i = 1 : numEvents
%     channel1DosePerDay(i) = dosePerDay(i);
%     totalCumulativeDose(i) = cumulativeDose(i);
% end  



%Set up some plotting variables.
Spacecraft = " Daily Falcon";
Instrument = "SEED";
plotType = "Integrated Over Reset Dosimeter Dose";

%Generate a plot title
titStr = Spacecraft + " " + Instrument + " " + plotType + " " + dateStr + " " + JulianDay;
    
%Set the figure width and height and x position.  
numSubplots = 2;
[left, width, height, bottom] = getSubplotPositions(numSubplots);


totalDose1Str = ['Total Dose : ', num2str(totalDosePerDay.channel1, '%6.3f'), ...
    ' Rads'];
totalDose2Str = ['Total Dose : ', num2str(totalDosePerDay.channel2, '%6.3f'), ...
    ' Rads'];

%Set the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];
ax = axes(fig1);

sp1 = subplot(numSubplots, 1, 1);
plot(dailyDose.channel1, 'b')
title(titStr)
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Hourly Value', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', totalDose1Str, ...
      'FontSize', 15);
xlim([0 numEvents])
ylabel('Daily Dose (Rad)')
xlabel(xtit)
%ylim([0 20])
set(sp1, 'Position', [left, bottom(1), width, height]);
sp1.XTick = xtickValues;
sp1.XTickLabel = xtickLabels;

sp2 = subplot(numSubplots, 1, 2);
plot(dailyDose.channel2, 'b')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Hourly Value', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', totalDose2Str, ...
      'FontSize', 15);


set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
ylabel('Dose (Rad)')
%ylim([0 100])
xlim([0 numEvents])
xlabel(xtit)
set(sp2, 'Position', [left, bottom(2), width, height]);
sp2.XTick = xtickValues;
sp2.XTickLabel = xtickLabels;


%Save the plot to a file.  
saveas(fig1, outFilename);



end  %End of function plotDailyDose.m
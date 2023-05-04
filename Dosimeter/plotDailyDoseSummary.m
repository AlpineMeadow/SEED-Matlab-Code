function plotDailyDoseSummary(info, totalDosePerDay1, totalDosePerDay2, dailyDose1, ...
	dailyDose2, UTCTime, xvalues, xdays)

%This function is called by DailyDosimeterDoseSummary.m

%Generate a plot name.
plotName1 = 'DosimeterSummaryChannel1_';
plotName2 = 'DosimeterSummaryChannel2_';

%Create an outfile name.  If the time span is more than a year handle that
%specially.
outFilename1 = [info.dosimeterPlotDir, 'Summary/Channel1/', plotName1, info.startYearStr, ...
	info.startMonthStr, info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_.png'];
outFilename2 = [info.dosimeterPlotDir, 'Summary/Channel2/', plotName2, info.startYearStr, ...
	info.startMonthStr, info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_.png'];	


dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr];

%Set a variable to the number of events.
numEvents1 = length(dailyDose1);
numEvents2 = length(dailyDose2);

%Set up some daily variables.
xtit = 'Time (UTC)';

%Set up a vector of values to be used in the xticks plot function.
xtickValues = (numEvents1/24)*[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
	' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};
JulianDay = info.startDayOfYearStr;

%Add some code to determine information about the Gamma Ray Burst on day
%282.
if info.startDayOfYear == 282

	%Find the GRB event time.
	eventHour = 13;
	eventMinute = 21;
	eventSecond = 0.0;  %I do not have the exact time.  I will go with zero seconds.

	eventTimeStart = eventHour*3600 + eventMinute*60 + eventSecond;
	eventTimeEnd = eventHour*3600 + eventMinute*60 + eventSecond + 60;

	eventIndex = find(UTCTime > eventTimeStart & UTCTime < eventTimeEnd);

	%Since I am plotting reset time on the x-axis I will need to convert the
	%eventIndex values into that coordinate system.
	resetRolloverSeconds = 1200;
	eventTimes = UTCTime(eventIndex)/resetRolloverSeconds;
	eventStart = eventTimes(1);
	eventEnd = eventTimes(end);
end

%Lets find the cumulative dose.
cumulativeDose1 = zeros(1, numEvents1);
cumulativeDose2 = zeros(1, numEvents2);

for i = 1 : numEvents1
    if (i == 1) 
        cumulativeDose1(i) = dailyDose1(i);
    else
        cumulativeDose1(i) = cumulativeDose1(i - 1) + dailyDose1(i);
    end
end  %End of for loop - for i = 1 : numEvents1

for i = 1 : numEvents2
    if (i == 1) 
        cumulativeDose2(i) = dailyDose2(i);
    else
        cumulativeDose2(i) = cumulativeDose2(i - 1) + dailyDose2(i);
    end
end  %End of for loop - for i = 1 : numEvents1


%Set up some plotting variables.
Spacecraft = " Daily Falcon";
Instrument = "SEED";
plotType = "Dosimeter Dose";

%Generate a plot title
titStr = Spacecraft + " " + Instrument + " " + plotType + " " + dateStr + " " + JulianDay;
    
%Set the figure width and height and x position.  
numSubplots = 2;
[left, width, height, bottom] = getSubplotPositions(numSubplots);


%Set the figure handle.
%fig1 = figure('DefaultAxesFontSize', 12, 'Visible', 'off');
fig1 = figure('DefaultAxesFontSize', 12, 'Visible', 'off');
fig1.Position = [750 25 1200 700];
ax = axes(fig1);

sp1 = subplot(numSubplots, 1, 1);
plot(dailyDose1, 'b')
title(titStr)
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.76, 0.9], 'string', '20 Minute Increments', ...
      'FontSize', 15);
%set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
set(gca, 'XTickLabel', []);
ylabel('Dose (Rad)')
%xlabel(xtit)
xlim([0 length(dailyDose1)])
set(sp1, 'Position', [left, bottom(1), width, height]);

if xdays == 282
	hold on
	plot([eventStart, eventStart], [sp1.YLim(1), sp1.YLim(2)], 'r')
	plot([eventStart, eventEnd], [sp1.YLim(1), sp1.YLim(1)], 'r')
	plot([eventStart, eventEnd], [sp1.YLim(2), sp1.YLim(2)], 'r')
	plot([eventEnd, eventEnd], [sp1.YLim(1), sp1.YLim(2)], 'r')
	text('Units', 'Normalized', 'Position', [0.42, 0.8], 'string', 'GRB Event', ...
		'FontSize', 15);
	x = [0.52 0.545];
	y = [0.84 0.84];
	annotation('textarrow',x,y, 'FontSize',13,'Linewidth',2)
end

sp2 = subplot(numSubplots, 1, 2);
plot(cumulativeDose1, 'b')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.15], 'string', 'Cumulative Dose', ...
      'FontSize', 15);
set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
ylabel('Dose (Rad)')
xlim([0 length(cumulativeDose1)])
xlabel(xtit)
set(sp2, 'Position', [left, bottom(2), width, height]);

%Save the plot to a file.  
saveas(fig1, outFilename1);



%Set the figure handle.
fig2 = figure('DefaultAxesFontSize', 12, 'Visible', 'off');
fig2.Position = [750 25 1200 700];
ax = axes(fig2);

sp3 = subplot(numSubplots, 1, 1);
plot(dailyDose2, 'b')
title(titStr)
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.76, 0.9], 'string', '20 Minute Increments', ...
      'FontSize', 15);
set(gca, 'XTick', xtickValues);
set(gca, 'XTickLabel', []);
ylabel('Dose (Rad)')
xlim([0 length(dailyDose1)])
set(sp3, 'Position', [left, bottom(1), width, height]);

if xdays == 282
	hold on
	plot([eventStart, eventStart], [sp3.YLim(1), sp3.YLim(2)], 'r')
	plot([eventStart, eventEnd], [sp3.YLim(1), sp3.YLim(1)], 'r')
	plot([eventStart, eventEnd], [sp3.YLim(2), sp3.YLim(2)], 'r')
	plot([eventEnd, eventEnd], [sp3.YLim(1), sp3.YLim(2)], 'r')
	text('Units', 'Normalized', 'Position', [0.42, 0.8], 'string', 'GRB Event', ...
		'FontSize', 15);
	x = [0.52 0.545];
	y = [0.84 0.84];
	annotation('textarrow',x,y, 'FontSize',13,'Linewidth',2)
end

sp4 = subplot(numSubplots, 1, 2);
plot(cumulativeDose2, 'b')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.15], 'string', 'Cumulative Dose', ...
      'FontSize', 15);
set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
ylabel('Dose (Rad)')
xlim([0 length(cumulativeDose1)])
xlabel(xtit)
set(sp4, 'Position', [left, bottom(2), width, height]);

%Save the plot to a file.  
saveas(fig2, outFilename2);


end  %End of the function plotDailyDoseSummary.m
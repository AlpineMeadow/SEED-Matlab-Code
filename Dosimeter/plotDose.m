function plotDose(info, DosePerDay, rawTime, xvalues, xdays)

%This function will produce plots of the dosimeter data.
%This function is called by Dosimeter.m.


plotName = 'DosimeterSummary_';


%Create an outfile name.  If the time span is more than a year handle that
%specially.
if(info.startYear == info.endYear)
    outFilename = [info.dosimeterPlotDir, plotName, num2str(info.startYear), ...
        '_', num2str(info.startDayOfYear, '%03d'), '-', ...
        num2str(info.endDayOfYear, '%03d'), '_.png'];
    dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr, ...
        ' - ', info.endYearStr '/', info.endMonthStr, '/', info.endDayOfMonthStr];
else
    outFilename = [info.dosimeterPlotDir, plotName, num2str(info.startYear), ...
        '-', num2str(info.startDayOfYear, '%03d'), '_', ...
        num2str(info.endYear), '-', num2str(info.endDayOfYear, '%03d'), '_.png'];
    dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr, ...
        ' - ', info.endYearStr, '/', info.endMonthStr, '/', info.endDayOfMonthStr]
end

%Set a variable to the number of events.
[numChannels, numEvents] = size(DosePerDay);

%Set up some daily variables.
if(strcmp(info.plotType,'day')) 
    xtit = 'Time (hours)';

    %Set up a vector of values to be used in the xticks plot function.
    xtickValues = (numEvents/24)*[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
    xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
        ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};
    JulianDay = info.startDayOfYearStr;
    XTickLabelRotationValue = 0;
end

%Set up some month variables.
if(strcmp(info.plotType,'month')) 
    xtit = 'Time (days)';
    
    %Set up a vector of values to be used in the xticks plot function.
    xtickValues = (numEvents/15)*[1 3 5 7 9 11 13 15 17 19 21 23 25 27 29];
    xtickLabels = {'1', '3', '5', '7', '9', '11', '13', '15', '17', '19', '21', ...
        '23', '25', '27', '29'};
    JulianDay = [info.startDayOfYearStr, '-', info.endDayOfYearStr];
    XTickLabelRotationValue = 0;
end

%Set up some year variables.
if(strcmp(info.plotType,'year'))
    xtit = 'Time (Months)';

    %Set up a vector of values to be used in the xticks plot function.
    xtickValues = [15 45 75 106 136 167 197 228 259 289 320 350];
    xtickLabels = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', ...
        'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
    JulianDay = [info.startDayOfYearStr, '-', info.endDayOfYearStr];
    XTickLabelRotationValue = 90;   
end


%We need to get the data into monthly values.
dayMonthStartIndex = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
dayMonthEndIndex = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

%Determine the number of months.
numMonths = 12*(info.endYear - info.startYear) + info.endMonth - info.startMonth + 1;

%Set up a variable that will hold the average monthly dose.
monthlyAverageDose = zeros(1, numMonths);

%Loop through the days to get the monthly average.
for i = 1 : numMonths
    dayIndex = find(xdays >= dayMonthStartIndex(i) & xdays <= dayMonthEndIndex(i));

    dailyDoses = DosePerDay(1, dayIndex);
    monthAverageDose(i) = mean(dailyDoses);

end  %End of for loop - for i = 1 : 12

%Lets find the cumulative dose.
cumulativeDose = zeros(1, numEvents);
for i = 1 : numEvents
    if (i == 1) 
        cumulativeDose(i) = DosePerDay(1, i);
    else
        cumulativeDose(i) = cumulativeDose(i - 1) + DosePerDay(1, i);
    end
end  %End of for loop - for i = 1 : numEvents

%Set up some plotting variables.
Spacecraft = " Daily Falcon";
Instrument = "SEED";
plotType = "Dosimeter Dose";


%Generate a plot title
titStr = Spacecraft + " " + Instrument + " " + plotType + " " + dateStr + " " + JulianDay;
    
%Set the figure width and height and x position.  
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.71, 0.42, 0.11];

%Set the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];
ax = axes(fig1);
ax.XTickLabelRotation = XTickLabelRotationValue;

  
channel1DosePerDay = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
    NaN, NaN, NaN, NaN, NaN, DosePerDay(1, :)];
cumulativeDose = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
    NaN, NaN, NaN, NaN, NaN, cumulativeDose];

sp1 = subplot(3, 1, 1);
plot(channel1DosePerDay, 'b')
title(titStr)
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Daily Value', ...
      'FontSize', 15);
set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
ylabel('Dose (Rad)')
xlabel(xtit)
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(3, 1, 2);
plot(cumulativeDose, 'b')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.15], 'string', 'Cumulative Dose', ...
      'FontSize', 15);
set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
ylabel('Dose (Rad)')
ylim([0 100])
xlabel(xtit)
set(sp2, 'Position', [left, bottom(2), width, height]);



sp3 = subplot(3, 1, 3);
X = categorical({'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'});
X = reordercats(X, {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'});
bar(X, monthAverageDose, 'b')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Monthly Average', ...
      'FontSize', 15);
ylabel('Dose (Rad)')
set(sp3, 'Position', [left, bottom(3), width, height]);



%Save the plot to a file.  
saveas(fig1, outFilename);

end  %End of the function plotDose.m
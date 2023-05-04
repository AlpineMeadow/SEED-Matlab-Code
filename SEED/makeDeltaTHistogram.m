function makeDeltaTHistogram(info, time);


numEvents = length(time.eventSeconds);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";

dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

%Generate a histogram of the time differences.
plotType = 'Time Interval Histogram';
titStr2 = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;
saveName = 'Histogram' + satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + num2str(info.numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;


fig2FileName = strcat(info.SEEDPlotDir, 'Histogram/', saveName, '.png');

fig2 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig2.Position = [750 25 1200 500];

xTickLabels = {[15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195]};
xTicks = [7.5, 22.5, 37.5, 52.5, 67.5, 82.5, 97.5, 112.5, 127.5, 142.5, 157.5, ...    
        172.5, 187.5, 202.5];

orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.
tDiff = diff(time.eventSeconds);

%Make a binning plan.  We want to use 15 as the bin width.
binEdges = xTicks;

%Now make the histogram.
histogram(tDiff, binEdges)
title(titStr2);
ylabel('Frequency');
xticks(xTicks + 7.5);
xticklabels(xTickLabels);
%xlim(xLimValues);

%Save the spectra to a file.
saveas(fig2, fig2FileName);


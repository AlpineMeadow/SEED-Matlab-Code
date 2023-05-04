function plotCountsPercentage(info, xdays, eventPercent)


%Now make a histogram of the large negative
satellite = "Falcon";
instrument = "SEED";
plotType = "PercentEvents";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;


saveName2 = satellite + instrument + plotType + dateStr + "_" + ...
	info.startDayOfYearStr + '-' + info.endDayOfYearStr;

fig2FileName = strcat(info.dosimeterPlotDir, saveName2, '.png');

%Lets make some plots.
%Set the figure width and height and x position.  
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.71, 0.42, 0.08];

%Set the figure handle.
fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 700];
ax = axes(fig2);

titStr = ['Dosimeter Percent Total Events for Day of Year : ', ...
	info.startDayOfYearStr, ' - ', info.endDayOfYearStr];


%Plot a histogram of the counts.
plot(xdays, eventPercent)
title(titStr)
xlabel('Days')
ylabel('Event Percent (%)')
ylim([0 100])

%Save the spectra to a file.
saveas(fig2, fig2FileName);


end
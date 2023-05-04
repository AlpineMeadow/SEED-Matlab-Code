function timeDifference15Index = showSEEDTimeIntervals(info, ...
    countDifference, timeDifference, uniqueTime, uniqueDateNumber)

%This function is called by getUniqueDifferencedData.m.  It will make plots
%of the data points using different time difference(delta t) intervals for
%which the data is kept.  We believe that there might be something wrong
%with data for which the delta t value is greater than 15.  First of all we
%do not really understand why the delta t is greater than 15 second.  For
%times when the instrument is reset(72 per day) there could be a delta t
%that is greater than 15 but it happens much more frequently than 72 times
%per day.  I need to get with Richard about this.

%Set a flag for making a plot.
makePlot = 0;


%Find indices that have time differences around 15 seconds.
timeDifference15Index = find(timeDifference >= 14.8 & timeDifference <= 15.2);

%Tony asked me to look at other delta time differences.  I have found that
%the delta times are 15, 46, 61 and other values that are close to but not
%exactly multiples of 15.  Not sure what this means.  Also, interestingly
%there does not seem to be any delta t values of 30.
timeDifference45Index = find(timeDifference >= 40 & timeDifference <= 50);
timeDifference60Index = find(timeDifference >= 55 & timeDifference <= 65);
timeDifference75Index = find(timeDifference >= 70 & timeDifference <= 80);
timeDifference90Index = find(timeDifference >= 85 & timeDifference <= 95);
timeDifference105Index = find(timeDifference >= 100 & timeDifference <= 110);
timeDifference120Index = find(timeDifference >= 115 & timeDifference <= 125);


%Now get count difference that corresponds to the delta t = 15.
countDifference15 = countDifference(timeDifference15Index, :);
countDifference45 = countDifference(timeDifference45Index, :);
countDifference60 = countDifference(timeDifference60Index, :);
countDifference75 = countDifference(timeDifference75Index, :);
countDifference90 = countDifference(timeDifference90Index, :);
countDifference105 = countDifference(timeDifference105Index, :);
countDifference120 = countDifference(timeDifference120Index, :);

%Do the same for the time structure.
%eventSeconds15 = uniqueTime(timeDifference15Index);
eventSeconds15 = uniqueDateNumber(timeDifference15Index);
eventSeconds45 = uniqueDateNumber(timeDifference45Index);
eventSeconds60 = uniqueDateNumber(timeDifference60Index);
eventSeconds75 = uniqueDateNumber(timeDifference75Index);
eventSeconds90 = uniqueDateNumber(timeDifference90Index);
eventSeconds105 = uniqueDateNumber(timeDifference105Index);
eventSeconds120 = uniqueDateNumber(timeDifference120Index);


%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "TimeSeries";
plotTypeStr = "Time Series";

dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotTypeStr + " " + dateStr + ...
    " " + doyStr;
saveName = satellite + instrument + plotType + dateStr + "_" + doyStr;


fig1FileName = strcat(info.SEEDPlotDir, 'TimeSeries/', saveName, '.png');

if makePlot == 1
    fig1 = figure('DefaultAxesFontSize', 12);
    ax = axes();
    fig1.Position = [750 25 1200 500];
end


%Set the figure width and height and x position.  
numSubplots = 3;
[left, width, height, bottom] = getSubplotPositions(numSubplots);

%Shift the plots to be slightly smaller in the vertical dimension.
bottom = [0.65, 0.35, 0.08];
height = 0.25;

%Generate a legend string.
legendStr = {'Delta t = 15s', 'Delta t = 45s', 'Delta t = 60s', ...
    'Delta t = 75s', 'Delta t = 90s', 'Delta t = 105s', ...
    'Delta t = 120s', 'Raw Data'};
legendStr = {'Delta t = 15s', 'Raw Data'};

%Choose some energy bins to look at.
energyBin1 = 130;
energyBin2 = 200;
energyBin3 = 300;

deltaEnergy = 0.1465;  %In units of keV.
energyBinOffset = -3.837; 

energy1Str = ['Energy : ', num2str(energyBin1*deltaEnergy + energyBinOffset, ...
    '%5.2f'), ' keV'];
energy2Str = ['Energy : ', num2str(energyBin2*deltaEnergy + energyBinOffset,...
    '%5.2f'), ' keV'];
energy3Str = ['Energy : ', num2str(energyBin3*deltaEnergy + energyBinOffset,...
    '%5.2f'), ' keV'];


titStr1 = satellite + " " + instrument + " " + plotTypeStr + " " + dateStr + ...
    " " + doyStr;
xtit = 'Time (s)';

%Lets set some y axis limits.
if (info.startDayOfYear == 64)
    ylim1 = [0 500];
    ylim2 = [0 300];
    ylim3 = [0 300];
elseif (info.startDayOfYear == 88)
    ylim1 = [0 200];
    ylim2 = [0 100];
    ylim3 = [0 100];
elseif (info.startDayOfYear == 112)
    ylim1 = [0 500];
    ylim2 = [0 300];
    ylim3 = [0 300];
else
    ylim1 = [0 500];
    ylim2 = [0 300];
    ylim3 = [0 300]; 
end

 
if makePlot == 1
    sp1 = subplot(3, 1, 1);
    plot(eventSeconds15, countDifference15(:, energyBin1), 'b*')
    hold on
    %plot(eventSeconds45, countDifference45(:, energyBin1), 'Color', '#f44336')
    %plot(eventSeconds60, countDifference60(:, energyBin1), 'Color', '#e4b634')
    %plot(eventSeconds75, countDifference75(:, energyBin1), 'Color', '#bd7fc9')
    %plot(eventSeconds90, countDifference90(:, energyBin1), 'Color', '#000090')
    %plot(eventSeconds105, countDifference105(:, energyBin1), 'Color', '#5e00ff')
    %plot(eventSeconds120, countDifference120(:, energyBin1), 'Color', '#7d5a59')
    plot(uniqueDateNumber(2:end), countDifference(:, energyBin1), 'g.')
    title(titStr1)
    text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', energy1Str, ...
        'FontSize', 15, 'Color', 'black');
    ylabel('Counts')
    xticklabels([])
    ylim(ylim1)
    set(sp1, 'Position', [left, bottom(1), width, height]);
    legend(legendStr, 'orientation', 'vertical', 'location', 'east')

    sp2 = subplot(3, 1, 2);
    plot(eventSeconds15, countDifference15(:,  energyBin2), 'b*')
    hold on
    %plot(eventSeconds45, countDifference45(:, energyBin2), 'Color', '#f44336')
    %plot(eventSeconds60, countDifference60(:, energyBin2), 'Color', '#e4b634')
    %plot(eventSeconds75, countDifference75(:, energyBin2), 'Color', '#bd7fc9')
    %plot(eventSeconds90, countDifference90(:, energyBin2), 'Color', '#000090')
    %plot(eventSeconds105, countDifference105(:, energyBin2), 'Color', '#5e00ff')
    %plot(eventSeconds120, countDifference120(:, energyBin2), 'Color', '#7d5a59')
    plot(uniqueDateNumber(2:end), countDifference(:, energyBin2), 'g.')
    text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', energy2Str, ...
      'FontSize', 15, 'Color', 'black');
    xticklabels([])
    ylim(ylim2)
    ylabel('Counts')
    set(sp2, 'Position', [left, bottom(2), width, height]);

    sp3 = subplot(3, 1, 3);
    plot(eventSeconds15, countDifference15(:,  energyBin3), 'b*')
    hold on
    %plot(eventSeconds45, countDifference45(:, energyBin3), 'Color', '#f44336')
    %plot(eventSeconds60, countDifference60(:, energyBin3), 'Color', '#e4b634')
    %plot(eventSeconds75, countDifference75(:, energyBin3), 'Color', '#bd7fc9')
    %plot(eventSeconds90, countDifference90(:, energyBin3), 'Color', '#000090')
    %plot(eventSeconds105, countDifference105(:, energyBin3), 'Color', '#5e00ff')
    %plot(eventSeconds120, countDifference120(:, energyBin3), 'Color', '#7d5a59')
    plot(uniqueDateNumber(2:end), countDifference(:, energyBin3), 'g.')
    datetick('x', 'HH:MM')
    text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', energy3Str, ...
        'FontSize', 15, 'Color', 'black');
    ylim(ylim3)
    ylabel('Counts')
    xlabel(xtit)
    set(sp3, 'Position', [left, bottom(3), width, height]);

    %Save the plot to a file.
    saveas(fig1, fig1FileName);

end
end  %End of the function showSEEDTimeIntervals.m
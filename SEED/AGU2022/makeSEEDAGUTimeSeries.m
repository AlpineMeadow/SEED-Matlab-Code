function makeSEEDAGUTimeSeries(info, flux, energyBins, UTCTime, numEnergyBinsToSum)

%This function is called by SEEDAGU.m


%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "TimeSeries";
dateStr = datestr(datetime(info.startYear, info.startMonth, info.startDayOfMonth));
startDate = [info.startYearStr, info.startMonthStr, info.startDayOfYearStr];
startDayOfYear = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + "Flux Versus Time" + " " + dateStr + ...
    " " + info.startDayOfYearStr;
saveName = satellite + instrument + plotType + startDate + "_" + info.startDayOfYearStr + ...
    "_" + info.startHourStr + "_" + info.endHourStr + "_" + num2str(numEnergyBinsToSum);


fig1FileName = strcat(info.SEEDRootDir, 'Plots/AGU/', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Let's find the energy channels of interest.
goodEnergyIndex = find(energyBins(:, 2) >= info.startEnergy & ...
    energyBins(:, 2) <= info.endEnergy);

%Now we find the times of interest.
timeInSecondsStart = info.startHour*3600 + info.startMinute*60 + info.startSecond;
timeInSecondsEnd = info.endHour*3600 + info.endMinute*60 + info.endSecond;

%Get the index of the times to be plotted.
timeIndex = find(UTCTime > timeInSecondsStart & UTCTime < timeInSecondsEnd);
numEvents = length(timeIndex);

%Set up a datenum array to be used for the plotting labels.
year = repmat(info.startYear, 1, numEvents);
month = repmat(info.startMonth, 1, numEvents);
day = repmat(info.startDayOfMonth, 1, numEvents);
hours = floor(UTCTime(timeIndex)/3600);
minutes = floor((UTCTime(timeIndex) - hours*3600))/60;
seconds = UTCTime(timeIndex) - hours*3600 - minutes*60;
sdate = datenum(year, month, day, hours', minutes', seconds');

%Get the number of hours.
numHours = info.endHour - info.startHour + 1;

if numHours < 12
    xTicks = zeros(1, numHours*6);
    tickFormat = 'HH:MM';
    for i = 1 : numHours
        for j = 1 : 6
            hh = info.startHour + i - 1;
            mm = (j- 1)*10;
            ss = 0;
            xTicks(6*(i - 1) + j) = datenum(info.startYear, info.startMonth, ...
                info.startDayOfMonth, hh, mm, ss);
        end
    end
    xCoord = 0.1;
else
    %Make the datetick tick values.
    xTicks = zeros(1, numHours);
    tickFormat = 'HH';
    for i = 1 : numHours
        hh = info.startHour + i - 1;
        mm = 0;
        ss = 0;
        xTicks(i) = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
            hh, mm, ss);

    end
    xCoord = 0.82;
end


if info.startDayOfYear == 64
    pointOfInterestHour = 11;
    pointOfInterestMinute = 31;
    pointOfInterestSecond = 30;
end

if info.startDayOfYear == 88
    pointOfInterestHour = 11;
    pointOfInterestMinute = 31;
    pointOfInterestSecond = 30;
end

if info.startDayOfYear == 112
    pointOfInterestHour = 17;
    pointOfInterestMinute = 10;
    pointOfInterestSecond = 0;
end


%Get the flux.
data = log10(flux.fluxActual);

%Find the energy bin to plot.
nominalEnergyBin = 69.6;

energyBinIndex = find(energyBins(:,2) >= nominalEnergyBin);
middleEnergyBinIndex = energyBinIndex(1);
lowEnergyBinIndex = middleEnergyBinIndex - 20;
lowLowEnergyBinIndex = middleEnergyBinIndex - 30;
highEnergyBinIndex = middleEnergyBinIndex + 20;


energyBinStr1 = ['Energy : ', num2str(energyBins(lowLowEnergyBinIndex, 2), '%5.2f'), ' keV'];
energyBinStr2 = ['Energy : ', num2str(energyBins(lowEnergyBinIndex, 2), '%5.2f'), ' keV'];
energyBinStr3 = ['Energy : ', num2str(energyBins(middleEnergyBinIndex, 2), '%5.2f'), ' keV'];
energyBinStr4 = ['Energy : ', num2str(energyBins(highEnergyBinIndex, 2), '%5.2f'), ' keV'];


p = plot(sdate, smoothdata(data(timeIndex, lowEnergyBinIndex), 'sgolay', 15), 'b', ...
    sdate, smoothdata(data(timeIndex, middleEnergyBinIndex), 'sgolay', 15), 'g', ...
    sdate, smoothdata(data(timeIndex, highEnergyBinIndex), 'sgolay', 15), 'r', ...
    sdate, smoothdata(data(timeIndex, lowLowEnergyBinIndex), 'sgolay', 15), 'magenta');
ylabel('Log_{10} Flux (Counts/(keV s cm^2 ster))');
title(titStr);
xlim([sdate(1) sdate(end)])
xticks(xTicks);
xlabel('Hours (UTC)');
datetick('x', tickFormat, 'keepticks', 'keeplimits')
text('Units', 'Normalized', 'Position', [xCoord, 0.95], 'string', ...
    		energyBinStr1, 'FontSize', 11, 'Color' , 'magenta');
text('Units', 'Normalized', 'Position', [xCoord, 0.9], 'string', ...
    		energyBinStr2, 'FontSize', 11, 'Color' , 'blue');
text('Units', 'Normalized', 'Position', [xCoord, 0.85], 'string', ...
    		energyBinStr3, 'FontSize', 11, 'Color', 'green');
text('Units', 'Normalized', 'Position', [xCoord, 0.8], 'string', ...
    		energyBinStr4, 'FontSize', 11, 'Color', 'red');

hold on
sd = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
    pointOfInterestHour, pointOfInterestMinute, pointOfInterestSecond);
plot([sd, sd], [4 8], 'black', 'LineWidth', 2)

%Create a flag to determine if we will plot the local time on the x-axis.
ltAxis = 3;

if ltAxis == 1
	additionalAxisTicks = {[19 21 23 1 3 5 7 9 11 13 15 17]};

	% Set up multi-line ticks
	allTicks = [cell2mat(xTickLabels'); cell2mat(additionalAxisTicks')];
	
	tickLabels = compose('%4d\\newline%4d', allTicks(:).');
	% The %4d adds space to the left so the labels are centered.
	% You'll need to add "%.1f\\newline" for each row of labels (change formatting as needed).
	% Alternatively, you can use the flexible line below that works with any number
	% of rows but uses the same formatting for all rows.
	%    tickLabels = compose(repmat('%.2f\\newline',1,size(allTicks,1)), allTicks(:).');

	% Decrease axis height & width to make room for labels
	ax.Position(3:4) = ax.Position(3:4) * .75; % Reduced to 75%
	ax.Position(2) = ax.Position(2) + .2;  % move up

	% Add x tick labels
	set(ax, 'XTickLabel', tickLabels, 'TickDir', 'out', 'XTickLabelRotation', 0)

	% Define each row of labels
	ax2 = axes('Position',[sum(ax.Position([1,3]))*1.08, ax.Position(2), .02, 0.001]);
	linkprop([ax,ax2],{'TickDir','FontSize'});

	axisLabels = {'Time (UTC)', 'LT'}; % one for each x-axis
	set(ax2,'XTick',0.5,'XLim',[0,1],'XTickLabelRotation',0, 'XTickLabel', strjoin(axisLabels,'\\newline'))
	ax2.TickLength(1) = 0.2; % adjust as needed to align ticks between the two axes
end  %End of if statement - if ltAxis == 1

%Save the spectra to a file.
saveas(fig1, fig1FileName);


end  %End of function makeSEEDAGUTimeSeries.m


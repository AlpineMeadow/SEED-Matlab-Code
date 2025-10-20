function makeSEEDTimeSeries(info, flux, energyBins, time)

%This function is called by FalconSEEDFlux.m


%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "TimeSeries";
plotType1 = "Time Series";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;


titStr = satellite + " " + instrument + " " + plotType1 + " " + dateStr + ...
    " " + doyStr;
saveName = satellite + instrument + plotType + dateStr + "_" + doyStr + ...
    "_" + num2str(numEnergyBinsToSum);


fig1FileName = strcat(info.SEEDPlotDir, 'TimeSeries/', saveName, '.png');

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
minutes = floor((UTCTime(timeIndex) - 3600*hours)/60.0);
%seconds = UTCTime(timeIndex) - 3600*hours - 60*minutes;
seconds = repmat(0, 1, numEvents);

sdate = datenum(year, month, day, hours', minutes', seconds);


%Get the flux.
data = log10(flux.fluxActual);

%Find the energy bin to plot.
nominalEnergyBin = 69.6;

energyBinIndex = find(energyBins(:,2) >= nominalEnergyBin);
firstEnergyBinIndex = energyBinIndex(1);
energyBinStr1 = ['Energy : ', num2str(energyBins(firstEnergyBinIndex, 2), '%5.2f'), ' keV'];
energyBinStr2 = ['Energy : ', num2str(energyBins(firstEnergyBinIndex + 5, 2), '%5.2f'), ' keV'];
energyBinStr3 = ['Energy : ', num2str(energyBins(firstEnergyBinIndex - 5, 2), '%5.2f'), ' keV'];


plot(sdate, data(timeIndex, firstEnergyBinIndex), 'b', ...
    sdate, data(timeIndex, firstEnergyBinIndex + 5), 'g', ...
    sdate, data(timeIndex, firstEnergyBinIndex - 5), 'r')
ylabel('Log_{10} Flux (Counts/(keV s cm^2 ster))');
title(titStr);
datetick('x', 'HH:MM')
text('Units', 'Normalized', 'Position', [0.82, 0.9], 'string', ...
    		energyBinStr1, 'FontSize', 11, 'Color' , 'blue');
text('Units', 'Normalized', 'Position', [0.82, 0.85], 'string', ...
    		energyBinStr2, 'FontSize', 11, 'Color', 'green');
text('Units', 'Normalized', 'Position', [0.82, 0.95], 'string', ...
    		energyBinStr3, 'FontSize', 11, 'Color', 'red');


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


end  %End of function makeSEEDTimeSeries.m
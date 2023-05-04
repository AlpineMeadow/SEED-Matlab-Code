function plotSEEDSummarySpectrogram(info, time, flux)


%This function is called by FalconSEEDSummarySpectrogram.m
energyBins = info.energyBins;

%Determine the number of events.
[numEvents, numEnergyBins] = size(flux.fluxActual);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;
saveName = satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + num2str(info.numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;


fig1FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Let's find the energy channels of interest.
energyIndex = find(energyBins(:, 2) >= info.startEnergy & ...
    energyBins(:, 2) <= info.endEnergy);

%Set up the y-axis labels and limits.
xTickLabels = {[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23]};

yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [energyBins(energyIndex(1), 1), energyBins(energyIndex(end), 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set up the x-axis limits.
xLimLow = time.eventDateNumber(1);
xLimHigh = time.eventDateNumber(end);

xLimValues = [xLimLow, xLimHigh];
%Set the formatting for the datetick function call.  Here we are asking for
%the format to be "HH:MM".   
dateFormat = 'HH';

%Get the number of hours.
numHours = info.endHour - info.startHour + 1;

%set up the data array for plotting.
data = log10(flux.fluxActual(:, energyIndex));


%Make the datetick tick values.
xTicks = zeros(1, numHours);
for i = 1 : numHours
    hh = info.startHour + i - 1;
    mm = 0;
    ss = 0;
    xTicks(i) = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
        hh, mm, ss);

end

imagesc(time.eventDateNumber, energyBins(energyIndex, 2), data')
xticks(xTicks)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
caxis([5 7.5])
title(titStr);
ylabel('Energy (keV)');
ylim(yLimValues)
yticklabels(yTickLabels)
yticks(yTickValues)
xlim(xLimValues);
set(gca,'YDir','normal')
cb = colorbar;
ylabel(cb,'Log10(Flux)') 

%Create a flag to determine if we will plot the local time on the x-axis.
ltAxis = 1;

if ltAxis == 1
%	additionalAxisTicks = {[19 21 23 1 3 5 7 9 11 13 15 17]};
    additionalAxisTicks = {[18 19 20 21 22 23 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17]};

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

end  %End of function plot plotSEEDSummarySpectrogram.m


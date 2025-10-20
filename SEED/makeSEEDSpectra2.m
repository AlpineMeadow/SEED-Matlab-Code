function makeSEEDSpectra2(info, time, flux)

%This function is called by FalconSEEDSummary.m

%Determine the number of events.
[numEvents, numEnergyBins] = size(flux.fluxActual);

%Set the energyBins variable.
energyBins = info.energyBins;

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram Version2 ";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;
ratioOfGoodSpectraToTotalSpectra = [num2str(numEvents), '/', num2str(5760)];

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr + " " + ratioOfGoodSpectraToTotalSpectra;
saveName = satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + num2str(info.numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;


fig1FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Let's find the energy channels of interest.
energyIndex = find(info.energyBins(:, 2) >= info.startEnergy & ...
    info.energyBins(:, 2) <= info.endEnergy);

%Now we find the times of interest.
timeInSecondsStart = info.startHour*3600 + info.startMinute*60 + info.startSecond;
timeInSecondsEnd = info.endHour*3600 + info.endMinute*60 + info.endSecond;

%Get the index of the times to be plotted.
timeIndex = find(time.eventSeconds > timeInSecondsStart & time.eventSeconds < timeInSecondsEnd);
numEvents = length(timeIndex);

%Set up the y-axis labels and limits.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [energyBins(energyIndex(1), 1), energyBins(energyIndex(end), 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set the time parameter to the variable dateNum.
dateNum = time.eventDateNumber;

%Set up the x-axis limits.
xLimLow = dateNum(1);
xLimHigh = dateNum(end);

xLimValues = [xLimLow, xLimHigh];

%Set the formatting for the datetick function call.  Here we are asking for
%the format to be "HH:MM".   
if timeInSecondsEnd - timeInSecondsStart > 7200
    dateFormat = 'HH';
else
    dateFormat = 'HH:MM';
end

%Get the number of hours.
numHours = info.endHour - info.startHour + 1;

%set up the data array for plotting.
fluxActual = flux.fluxActual;
fluxActual(fluxActual <= 0) = 1.0;
data = log10(fluxActual);

%Make the datetick tick values.
xTicks = zeros(1, numHours);
for i = 1 : numHours
    hh = info.startHour + i - 1;
    mm = 0;
    ss = 0;
    xTicks(i) = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
        hh, mm, ss);
end


%Now make a spectrogram of the data.
imagesc(dateNum, energyBins(:, 2), data')
xticks(xTicks)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
%caxis([5 7.5])
caxis('auto')
title(titStr);
ylabel('Energy (keV)');
ylim(yLimValues)
yticklabels(yTickLabels)
yticks(yTickValues)
xlim(xLimValues);
set(gca,'YDir','normal')
cb = colorbar;
ylabel(cb,'Log10(Flux)') 

hold on
if info.startDayOfYear == 37
  
    hour = 9;
    xposition = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
        hour, 0, 0);

    disp(['The x plot position is : ', num2str(xposition)])  
    disp(['The x spectra position is : ', num2str(dateNum(1))])

    plot([xposition, xposition], [yLimValues(1), yLimValues(2)], ...
         'r', 'LineWidth', 1)
end

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


% %Generate a histogram of the time differences.
% plotType = 'Time Interval Histogram';
% titStr2 = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
%     " " + doyStr;
% saveName = 'Histogram' + satellite + instrument + dateStr + "_" + doyStr + ...
%     "_" + num2str(info.numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
%     info.endHourStr;
% 
% 
% fig2FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');
% 
% fig2 = figure('DefaultAxesFontSize', 12);
% ax = axes();
% fig2.Position = [750 25 1200 500];
% 
% xTickLabels = {[15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195]};
% xTicks = [7.5, 22.5, 37.5, 52.5, 67.5, 82.5, 97.5, 112.5, 127.5, 142.5, 157.5, ...    
%         172.5, 187.5, 202.5];
% 
% orderOfDifference = 1;  %This will always be what we want.
% arrayDimension = 1;  %This will always be what we want.
% tDiff = diff(time.eventSeconds);
% 
% %Make a binning plan.  We want to use 15 as the bin width.
% binEdges = xTicks;
% 
% %Now make the histogram.
% histogram(tDiff, binEdges)
% title(titStr2);
% ylabel('Frequency');
% xticks(xTicks + 7.5);
% xticklabels(xTickLabels);
% %xlim(xLimValues);
% 
% %Save the spectra to a file.
% saveas(fig2, fig2FileName);
% 


end
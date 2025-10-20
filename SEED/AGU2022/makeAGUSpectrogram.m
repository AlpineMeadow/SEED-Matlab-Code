function makeAGUSpectrogram(info, flux, energyBins, UTCTime, numEnergyBinsToSum, ...
    dataDateNum)

%This function is called by FalconSEEDSummary.m

%Determine the number of events.
[numEvents, numEnergyBins] = size(flux.fluxActual);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram ";
dateStr = datestr(datetime(info.startYear, info.startMonth, info.startDayOfMonth));
startDate = [info.startYearStr, info.startMonthStr, info.startDayOfYearStr];
doyStr = info.startDayOfYearStr;
ratioOfGoodSpectraToTotalSpectra = [num2str(numEvents), '/', num2str(5760)];

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;
saveName = satellite + instrument + startDate + "_" + doyStr + ...
    "_" + num2str(numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;


fig1FileName = strcat(info.SEEDRootDir, 'Plots/AGU/', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Let's find the energy channels of interest.
energyIndex = find(energyBins(:, 2) >= info.startEnergy & ...
    energyBins(:, 2) <= info.endEnergy);

%Now we find the times of interest.
timeInSecondsStart = info.startHour*3600 + info.startMinute*60 + info.startSecond;
timeInSecondsEnd = info.endHour*3600 + info.endMinute*60 + info.endSecond;

%Get the index of the times to be plotted.
timeIndex = find(UTCTime > timeInSecondsStart & UTCTime < timeInSecondsEnd);
numEvents = length(timeIndex);

%We want to use the datetick method.  This requires a vector of year,
%month, day of month, hour, minute and seconds for each entry to be
%plotted.  Also, we need to make sure that each of the vectors are either
%column vectors or row vectors, we cannot have a mixture of the two types.
year = repmat(info.startYear, 1, numEvents);
month = repmat(info.startMonth, 1, numEvents);
day = repmat(info.startDayOfMonth, 1, numEvents);
hours = floor(UTCTime(timeIndex)/3600);
minutes = floor((UTCTime(timeIndex) - 3600*hours)/60.0);
seconds = UTCTime(timeIndex) - 3600*hours - 60*minutes;

sdate = datenum(year, month, day, hours', minutes', seconds');



if info.startDayOfYear == 64
    preInjectionHour = 10;
    preInjectionMinute = 30;
    preInjectionSecond = 0;

    postInjectionHour = 11;
    postInjectionMinute = 15;
    postInjectionSecond = 0;

    %Calculate the pre- and post- injection times in terms of daynumbers.
    preInjectionTime = datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, preInjectionHour, preInjectionMinute, ...
        preInjectionSecond);

    postInjectionTime = datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, postInjectionHour, postInjectionMinute, ...
        postInjectionSecond);

end

if info.startDayOfYear == 88
    preInjectionHour = 18;
    preInjectionMinute = 30;
    preInjectionSecond = 0;

    postInjectionHour = 19;
    postInjectionMinute = 30;
    postInjectionSecond = 0;

    %Calculate the pre- and post- injection times in terms of daynumbers.
    preInjectionTime = datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, preInjectionHour, preInjectionMinute, ...
        preInjectionSecond);

    postInjectionTime = datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, postInjectionHour, postInjectionMinute, ...
        postInjectionSecond);

end


if info.startDayOfYear == 112
    preInjectionHour = 17;
    preInjectionMinute = 8;
    preInjectionSecond = 0;

    postInjectionHour = 18;
    postInjectionMinute = 0;
    postInjectionSecond = 0;

    %Calculate the pre- and post- injection times in terms of daynumbers.
    preInjectionTime = datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, preInjectionHour, preInjectionMinute, ...
        preInjectionSecond);

    postInjectionTime = datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, postInjectionHour, postInjectionMinute, ...
        postInjectionSecond);

end


%Set up the y-axis labels and limits.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [energyBins(energyIndex(1), 1), energyBins(energyIndex(end), 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set up the x-axis limits.
xLimLow = sdate(1);
xLimHigh = sdate(end);

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
data = log10(flux.fluxActual(timeIndex, energyIndex));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Here is Geoff's code for interpolating the data %%%%%%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[interpolatedTime, interpolatedData] = interpolateSEEDData(info, sdate, ...
    energyBins(energyIndex, 2), data);


%Make the datetick tick values.
xTicks = zeros(1, numHours);
for i = 1 : numHours
    hh = info.startHour + i - 1;
    mm = 0;
    ss = 0;
    xTicks(i) = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
        hh, mm, ss);
end


imagesc(interpolatedTime, energyBins(energyIndex, 2), interpolatedData)
%imagesc(sdate, energyBins(energyIndex, 2), data')
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
xlabel('Time (UTC)')

hold on   
plot([preInjectionTime, preInjectionTime], [yLimValues(1), yLimValues(2)], ...
         'Color', 'magenta', 'LineWidth', 3)
plot([postInjectionTime, postInjectionTime], [yLimValues(1), yLimValues(2)], ...
         'Color', 'black', 'LineWidth', 3)





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

end  %End of function makeAGUSpectrogram.m
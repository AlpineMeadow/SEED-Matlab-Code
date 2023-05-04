function makeSpectra1(info, flux, energyBins, UTCTime, numEnergyBinsToSum, ...
    uniqueDateNum)

%This function is called by FalconSEEDFlux.m

%Determine the number of events.
[numEvents, numEnergyBins] = size(flux.fluxActual);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;
ratioOfGoodSpectraToTotalSpectra = [num2str(numEvents), '/', num2str(5760)];

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr + " " + ratioOfGoodSpectraToTotalSpectra;
saveName = satellite + instrument + plotType + dateStr + "_" + doyStr + ...
    "_" + num2str(numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;

%Generate the output file name for the spectra.
fig1FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');

%Set the figure handle and figure position.
fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Let's find the energy channels of interest.
goodEnergyIndex = find(energyBins(:, 2) >= info.startEnergy & ...
    energyBins(:, 2) <= info.endEnergy);

% %First we convert the integer seconds from midnight of January 6, 1980 into
% %fractional seconds from midnight of January 6, 1980.
% time = rawTime/86400.0;
% 
% %Next we convert this time into serial date numbers starting from Matlab's
% %incomprehensible starting point of January 0 of the year 0000. 
% time = time + datenum([info.epochYear, info.epochMonth, info.epochDayOfMonth, ...
%     info.epochHour, info.epochMinute, info.epochSecond]);
% 
% %Now we can convert the time from serial date numbers to time in normal
% %users dates and times.  
% d = datetime(time, 'ConvertFrom', 'datenum');
% normalTimeYears = d.Year;
% normalTimeMonths = d.Month;
% normalTimeDaysOfMonth = d.Day;
% normalTimeHours = d.Hour;
% normalTimeMinutes = d.Minute;
% normalTimeSeconds = d.Second;

%Get the index of the energy bins to be plotted.
energyIndex = find(energyBins(:, 2) > info.startEnergy & ...
    energyBins(:, 2) < info.endEnergy);

%Now we find the times of interest.
timeInSecondsStart = info.startHour*3600 + info.startMinute*60 + info.startSecond;
timeInSecondsEnd = info.endHour*3600 + info.endMinute*60 + info.endSecond;

%Get the index of the times to be plotted.
timeIndex = find(UTCTime > timeInSecondsStart & UTCTime < timeInSecondsEnd);
numEvents = length(timeIndex);


%set up the data array for plotting.
data = log10(flux.fluxActual(timeIndex, energyIndex));


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

%Check to see if the imput datenums will work.
sdate = uniqueDateNum;




numSecondsPerHour = 3600;
xTickValues = zeros(1, 12);
for i = 1 : 12
	temp = find(UTCTime >= (2*i - 0.5)*numSecondsPerHour);
	xTickValues(i) = UTCTime(temp(1));
end


%Set up the x-axis tick labels and limits.
xTickLabels = {[1, 3, 5, 7, 9, 11, 13, 15, ...
	17, 19, 21, 23]};
xLimValues = [UTCTime(1), UTCTime(end)];

%Set up the y-axis labels and limits.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [energyBins(energyIndex(1), 1), energyBins(energyIndex(end), 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set up the x-axis limits.
%xLimValues = [sdate(1), sdate(end)];
dayNumStart = datenum([info.startYear, info.startMonth, info.startDayOfMonth, ...
    info.startHour, info.startMinute, info.startSecond]);
dayNumEnd = datenum([info.endYear, info.endMonth, info.endDayOfMonth, ...
    info.endHour, info.endMinute, info.endSecond]);

xLimValues = [dayNumStart, dayNumEnd];

sdateIndex = find(sdate >= dayNumStart & sdate <= dayNumEnd);



%set up the data array for plotting.
data = log10(flux.fluxActual(sdateIndex, energyIndex));

%Set the formatting for the datetick function call.  Here we are asking for
%the format to be "HH:MM".   
if timeInSecondsEnd - timeInSecondsStart > 7200
    dateFormat = 'HH';
else
    dateFormat = 'HH:MM';
end


%Now make the image.
%imagesc([timeStart, timeEnd],[info.startEnergy, info.endEnergy], data)
%imagesc(UTCTime, [info.startEnergy, info.endEnergy], data)
imagesc(sdate(sdateIndex), energyBins(energyIndex, 2), data')
%imagesc(sdate, energyBins(energyIndex, 2), data')
caxis('auto')
caxis([5 8.1])
datetick('x', dateFormat)
ylabel('Energy (keV)');
title(titStr);
cb = colorbar;
ylabel(cb,'Log10(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;
%ax.XTick = xTickValues; 
ax.XLim = xLimValues; 
%ax.XTickLabel = xTickLabels;

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


%Set the figure handle and figure position.
fig2 = figure('DefaultAxesFontSize', 12);
ax2 = axes();
fig2.Position = [750 25 1200 500];

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Histogram";
plotTypeName = "Histogram of Events Per Hour";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotTypeName + " " + dateStr + ...
    " " + doyStr;
saveName = satellite + instrument + plotType + dateStr + "_" + doyStr + ...
    "_" + num2str(numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;

%Generate the output file name for the spectra.
fig2FileName = strcat(info.SEEDPlotDir, 'Histogram/', saveName, '.png');

xTickValues = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, ...
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]; 
xLimValues = [0, 24]; 
xTickLabels = {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, ...
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]};



%Determine the bins for the histogram.  We want bins for every hour.  This
%means we need to convert daynums to hours.
% %Now we can convert the time from serial date numbers to time in normal
% %users dates and times.  
d = datetime(uniqueDateNum, 'ConvertFrom', 'datenum');
normalTimeYears = d.Year;
normalTimeMonths = d.Month;
normalTimeDaysOfMonth = d.Day;
normalTimeHours = d.Hour;
normalTimeMinutes = d.Minute;
normalTimeSeconds = d.Second;

%Set up the bins.
bins = 0 : 24;

%Make the histogram.
histogram(normalTimeHours, bins)
ylabel('Frequency');
title(titStr);
xlabel('Hours');
ax2.XTick = xTickValues; 
ax2.XLim = xLimValues; 
ax2.XTickLabel = xTickLabels;


%Save the spectra to a file.
saveas(fig2, fig2FileName);




end  %End of function makeSpectra1.m
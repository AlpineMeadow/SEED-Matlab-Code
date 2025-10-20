function makeAGU2023SEEDPlots(info, CDFInfo, CDFData, visibleFlag, ...
    missionDayNumber, plotSectorBoundaries)
%Now plot a spectrogram of the data.

%Convert mission day of year into year, month and day of month.
[year, month, dayOfMonth] = MDNToMonthDay(missionDayNumber);
[dayOfYear, year] = MDNToDN(missionDayNumber);

dVec = [year*ones(1, 25); month*ones(1, 25); ...
    dayOfMonth*ones(1, 25); [0:24]; zeros(1, 25); zeros(1, 25)]';

xTickVals = datenum(dVec);


if visibleFlag == 1
    fig1 = figure('DefaultAxesFontSize', 12);
else
    fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
end

ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.02, 0.995, 0.950];

yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [CDFData.SEED_Energy_Channels(1), ...
    CDFData.SEED_Energy_Channels(end)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set the plot time format.
dateFormat = 'HH';

%Get the variables out of the CDFData structure.
time = CDFData.Epoch;
energyBins = CDFData.SEED_Energy_Channels;
data = double(CDFData.SEED_Electron_Flux_Total);
numEnergyBins = length(energyBins);

%Due to the difference between UTC and GPS time systems the data may have
%been taken during the previous day.  Let us remove any data that
%corresponds to the day before. This should only be a couple of data
%points.
datetimeTime = datetime(time, 'ConvertFrom', 'datenum');
goodDayIndex = find(datetimeTime.Day == dayOfMonth);
datetimeTime = datetimeTime(goodDayIndex);
time = time(goodDayIndex);

satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [num2str(year), num2str(month, '%02d'), num2str(dayOfMonth, '%02d')];
doyStr = num2str(dayOfYear, '%03d');

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

SEEDFileName = strcat('/SS1/STPSat-6/AGU2023/', saveName, '.png');

%Let us now interpolate and smooth the data.
%First make an interpolation vector. We will interpolate onto a time grid
%with a delta t of 15 seconds.
ttDatetime = datetime(time,'ConvertFrom','datenum');

timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
    ttDatetime.Second;

%Convert from the datetime structure into seconds from start of the day.
%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;

%Create a vector of interpolated times in the form of datenums.  Imagesc
%does not seem to take datetimes as an input.  Matlab sucks.
interpTime = datenum(datetime(info.startYear, info.startMonth, ...
    info.startDayOfMonth) + seconds(tt));

%Set up an interpolated flux array of size [5760,904]
interpFlux = zeros(length(tt), numEnergyBins);

smoothConstant = 50;

%Now we loop through the energy channels.
for e = 1 : numEnergyBins
    y = data(goodDayIndex, e);
    interpFlux(:, e) = smoothdata(interp1(timeSeconds, y, tt, 'linear'), ...
        'gaussian', smoothConstant);
end

%The array interpFlux can potentially have negative values most likely due
%to the interpolation/smoothing.  Lets get rid of them.
interpFlux(interpFlux < 0) = 0.001;

dt = datetime(time, 'ConvertFrom', 'datenum');

%Here we find the local time boundaries in terms of UTC time.
%dawnLocalTimeIndex = find(dt.Hour == 12 & dt.Minute == 0);
%noonLocalTimeIndex = find(dt.Hour == 18 & dt.Minute == 0);
%duskLocalTimeIndex = find(dt.Hour == 0 & dt.Minute == 0);
%midnightLocalTimeIndex = find(dt.Hour == 6 & dt.Minute == 0);
dawnLocalTimeIndex = find(dt.Hour == 9);
noonLocalTimeIndex = find(dt.Hour == 15);
duskLocalTimeIndex = find(dt.Hour == 21);
midnightLocalTimeIndex = find(dt.Hour == 3);


imagesc(interpTime, energyBins, log10(interpFlux)')
%caxis('auto')
xticks(xTickVals)
datetick('x', dateFormat, 'keepticks')
ylabel('Energy (keV)');
title(titStr);
%caxis([2 8])
caxis([3 8])
%caxis([info.cAxisLow info.cAxisHigh])
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;

if (info.startDayOfYear == 64 & info.startYear == 2022)
    text('Units', 'Normalized', 'Position', [0.46, 0.45], 'string', 'I', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.31, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.25, 0.25], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.35, 0.25], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.58, 0.45], 'string', 'I', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.71, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.14, 0.35], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.07, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.91, 0.45], 'string', 'E or I', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.8, 0.45], 'string', 'E or I', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.41, 0.15], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
elseif (info.startDayOfYear == 62 & info.startYear == 2023)
    text('Units', 'Normalized', 'Position', [0.36, 0.45], 'string', 'I', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.48, 0.45], 'string', 'I', ...
        'FontSize', 15, 'FontWeight', 'bold');

    text('Units', 'Normalized', 'Position', [0.14, 0.11], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.27, 0.15], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.31, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.61, 0.45], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.84, 0.05], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');

    text('Units', 'Normalized', 'Position', [0.03, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.12, 0.35], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.19, 0.27], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.65, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');

    text('Units', 'Normalized', 'Position', [0.84, 0.45], 'string', 'E or I', ...
        'FontSize', 15, 'FontWeight', 'bold');

elseif (info.startDayOfYear == 83 & info.startYear == 2023)
    text('Units', 'Normalized', 'Position', [0.15, 0.45], 'string', 'I', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.275, 0.45], 'string', 'I', ...
        'FontSize', 15, 'FontWeight', 'bold');


    text('Units', 'Normalized', 'Position', [0.01, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.1, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.19, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.25, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.35, 0.1], 'string', 'W', ...
        'FontSize', 15, 'FontWeight', 'bold');

    text('Units', 'Normalized', 'Position', [0.06, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.75, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.81, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.91, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');
    text('Units', 'Normalized', 'Position', [0.945, 0.45], 'string', 'E', ...
        'FontSize', 15, 'FontWeight', 'bold');

    text('Units', 'Normalized', 'Position', [0.45, 0.45], 'string', 'W or I', ...
        'FontSize', 15, 'FontWeight', 'bold');

end

hold on

%Create a flag to determine if we will plot the local time on the x-axis.
ltAxis = 1;

%Set up the x-axis tick labels and limits.
xTickLabels = {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...
	16, 17, 18, 19, 20, 21, 22, 23, 0]};

xLimValues = [time(1), time(end)];

if ltAxis == 1
	additionalAxisTicks = {[18 19 20 21 22 23 0 1 2 3 4 5 6 7 8 9 10 ...
        11 12 13 14 15 16 17 18]};

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

	axisLabels = {'Hours(UTC)', 'Hours(LT)'}; % one for each x-axis
	set(ax2,'XTick',0.5,'XLim',[0,1],'XTickLabelRotation',0, 'XTickLabel', ...
        strjoin(axisLabels,'\\newline'))
	ax2.TickLength(1) = 0.2; % adjust as needed to align ticks between the two axes
end  %End of if statement - if ltAxis == 1




%Save the time series to a file.
saveas(fig1, SEEDFileName);


end  %End of the function makeAGU2023SEEDPlots.m
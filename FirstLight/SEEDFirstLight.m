%This program will be run as a driver program.  It will essentially
%generate Level 2 data and plot it.  

dbstop if error;

clearvars;
close all;
fclose('all');

%The overlapping GOES17 data and SEED data are for 9 Feb. 2023(doy = 40) -
%27 Feb 2023(doy = 58).
%The dates for figure 2 are given as StartDayOfYear = 15, StartYear =
%2022, endDayOfYear = 105, endYear = 2023
%Set the day of year and the year.
startDayOfYear = 40;
endDayOfYear = 58;
startYear = 2023;
endYear = 2023;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%the energy bin number at which to start the data analysis. 
startEnergyBinNumber = 120;  

%The number of energy bins to sum.
numEnergyBinsToSum = 10;

%The number of time bins to sum. This needs to remain set to 1.
numTimeBinsToSum = 1;  

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%Set the CDF version number.
CDFDataVersionNumber = 1;

%Generate a structure that holds all of the information needed to do the
%analysis.
instrument = 'SEED';
info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber);

%Combine all of the bad days into one single vector.
badDays = info.SEEDBadDays;

%For large sets of days to be analyzed, it is easier to not allow the plots
%to show on the screen.  We make a flag that tells Matlab to either plot to
%the screen or not.
visibleFlag = 0;

%Initiate a structure index.
i = 1;

%Loop through the day of interest.
for missionDayNum = info.startMissionDayNumber : info.endMissionDayNumber
    disp(['Mission Day Number : ', num2str(missionDayNum)])
    %Check to see if the mission day number is in the list of bad mission
    %day numbers.
    badDayIndex = find(missionDayNum == badDays);

    %If the mission day number is bad, skip it and move on to the next one.
    if length(badDayIndex) >= 1
        continue
    else
        %Read in the GOES Data files.  This set of commands will create an
        %array of structures.
        MPSHIData(i) = getGOESData(info, missionDayNum);
        [CDFInfo, CDFData(i)] = importSEEDCDF1(info, missionDayNum);
        
        %Increment the structure index.
        i = i + 1;
    end
end

%For large sets of days to be analyzed, it is easier to not allow the plots
%to show on the screen.  We make a flag that tells Matlab to either plot to
%the screen or not.
visibleFlag = 1;

%Create a flag that tell the plotting program whether or not to plot the
%sector boundaries.
plotSectorBoundaries = 0;

%For 12 Feb. 2023, the mission day number is 394.
missionDayNumber = 394;

%plotFirstLightSEEDSpectrogram(info, CDFInfo, CDFData(4), visibleFlag, ...
%    missionDayNumber, plotSectorBoundaries);

plotMPSHIData(info, MPSHIData, CDFData)
%makeFigure1(info, CDFData)
%makeFigure2(info, CDFData)
%JuanPlots(info, MPSHIData, CDFData)
%plotGOESData(info, MPSHIData, CDFData)

%plotSEEDFirstLightTimeSeries(info, CDFInfo, CDFData)


%Make plots of the energy spectra for binned local times.
%plotSEEDLocalTimeEnergySpectra(info, CDFInfo, CDFData)

%Make a plot of the SEED temperature.  This is designed to cover the entire
%dataset.
%plotSEEDTemperature(info, CDFInfo, CDFData)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotFirstLightSEEDSpectrogram(info, CDFInfo, CDFData, ...
    visibleFlag, missionDayNumber, plotSectorBoundaries)

%Now plot a spectrogram of the data.

%Convert mission day of year into year, month and day of month.
[year, month, dayOfMonth] = MDNToMonthDay(missionDayNumber);
[dayOfYear, year] = MDNToDN(missionDayNumber);

%Create a vector of x tick values.
xTickVals = datenum([year*ones(1, 25); month*ones(1, 25); ...
    dayOfMonth*ones(1, 25); [0:24]; zeros(1, 25); zeros(1, 25)]');

%Set up the y axis tick labels and values.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [CDFData.SEED_Energy_Channels(1), ...
    CDFData.SEED_Energy_Channels(end)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Sometimes we do not want to make a large number of plots appear onto the
%screen.  This can happen when lots of plots are being made.  If we have
%lots of plots to make, then we tell Matlab not to make plots to the
%screen.
if visibleFlag == 1
    fig1 = figure('DefaultAxesFontSize', 12);
else
    fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
end

%Set up a set of axes for the plot.  Also, set the positions for both the
%figure and the axes.
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.02, 0.995, 0.950];

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

%Set up the plot title as well as the plot file name.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [num2str(year), num2str(month, '%02d'), ...
    num2str(dayOfMonth, '%02d')];
doyStr = num2str(dayOfYear, '%03d');

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

%Generate the SEED file name.
SEEDFileName = strcat('/SS1/STPSat-6/Plots/Summary/SEED/', ...
    info.startYearStr, '/', saveName, '.png');

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
dawnLocalTimeIndex = find(dt.Hour == 9);
noonLocalTimeIndex = find(dt.Hour == 15);
duskLocalTimeIndex = find(dt.Hour == 21);
midnightLocalTimeIndex = find(dt.Hour == 3);

imagesc(interpTime, energyBins, log10(interpFlux)')
xticks(xTickVals)
datetick('x', dateFormat, 'keepticks')
ylabel('Energy (keV)');
%title(titStr);
caxis([3 8])
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;
 text('Units', 'Normalized', 'Position', [0.25, 0.6], ...
     'string', 'Injection', 'FontSize', 20, 'Fontweight', 'bold');
 text('Units', 'Normalized', 'Position', [0.64, 0.6], ...
     'string', 'D E', 'FontSize', 20, 'Fontweight', 'bold');

hold on

if plotSectorBoundaries
    hDusk = plot([time(duskLocalTimeIndex(1)), time(duskLocalTimeIndex(1))], ...
        [yLimValues(1), yLimValues(2)], 'black');
    set(hDusk(1),'linewidth', 2);
    text('Units', 'Normalized', 'Position', [0.012, 0.95], 'string', 'Dusk', ...
        'FontSize', 15);
    text('Units', 'Normalized', 'Position', [0.01, 0.9], 'string', 'Sector', ...
        'FontSize', 15);

    hMidnight = plot([time(midnightLocalTimeIndex(1)), time(midnightLocalTimeIndex(1))], ...
        [yLimValues(1), yLimValues(2)], 'black');
    set(hMidnight(1),'linewidth', 2);
    text('Units', 'Normalized', 'Position', [0.22, 0.95], 'string', 'Midnight', ...
        'FontSize', 15);
    text('Units', 'Normalized', 'Position', [0.24, 0.9], 'string', 'Sector', ...
        'FontSize', 15);

    hDawn = plot([time(dawnLocalTimeIndex(1)), time(dawnLocalTimeIndex(1))], ...
        [yLimValues(1), yLimValues(2)], 'black');
    set(hDawn(1),'linewidth', 2);
    text('Units', 'Normalized', 'Position', [0.46, 0.95], 'string', 'Dawn', ...
        'FontSize', 15);
    text('Units', 'Normalized', 'Position', [0.46, 0.9], 'string', 'Sector', ...
        'FontSize', 15);

    hNoon = plot([time(noonLocalTimeIndex(1)), time(noonLocalTimeIndex(1))], ...
        [yLimValues(1), yLimValues(2)], 'black');
    set(hNoon(1),'linewidth', 2);
    text('Units', 'Normalized', 'Position', [0.7, 0.95], 'string', 'Noon', ...
        'FontSize', 15);
    text('Units', 'Normalized', 'Position', [0.7, 0.9], 'string', 'Sector', ...
        'FontSize', 15);
end  %End of if statement - if plotSectorBoundaries


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

end  %end of function SEEDCDFPlotSEEDData












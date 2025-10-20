%This script will make summary plots
dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 15;
startDayOfYear = 1;
endDayOfYear = 5;
startYear = 2025;
endYear = 2025;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%The energy bin number at which to start the data analysis. This will give
%904 energy bins, which is the number of bins in the CDF file.
startEnergyBinNumber = 121;  

%The number of energy bins to sum.
numEnergyBinsToSum = 1;  

%The number of time bins to sum. This needs to remain set to 1.
numTimeBinsToSum = 1;  

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%We need to generate a variable that will contain the data version number
%for the CDF files.  This will be used for this program but not in others
%that use the info structure.  
CDFDataVersionNumber = 1;

%Create a flag that tell the plotting program whether or not to plot the
%sector boundaries.
plotSectorBoundaries = 0;

%Generate a structure that holds all of the information needed to do the
%analysis.
instrument = 'SEED';
info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber);

%Here is a list of the bad days of year for 2022 in mission day numbers.
badDays2022 = DNToMDN([23, 75, 76, 85, 135, 136, 137, 138, 200, 201, ...
    202, 272, 299, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, ...
    330, 347, 348], 2022);

%These are the bad days in 2023.
badDays2023 = DNToMDN([22, 27, 28, 101, 102, 129, 131 : 140, 144 : 151, ...
    161 : 167, 191, 191 : 210], 2023);

%These are the bad days in 2024.  Hopefully I will get some of these added.
badDays2024 = DNToMDN([37 : 43, 81, 82, 135 : 141, 154 : 189, ...
    193, 252 : 365], 2024);

%Combine all of the bad days into one single vector.
badDays = [badDays2022, badDays2023, badDays2024];

%For large sets of days to be analyzed, it is easier to not allow the plots
%to show on the screen.  We make a flag that tells Matlab to either plot to
%the screen or not.
visibleFlag = 1;

%We can combine the data from numerous days into one plot.  We create a
%flag that sets the plotting routine to combine the separate days.  If
%combineDays = 1 we combine the data.  If combineDays = 0 we do not combine
%the data.
combineDays = 1;

%Generate a file name for a data file that holds the percent of actual
%spectra over possible spectra.  We want to rewrite this file for every
%time this program is run, so we delete the file if it already exists. 
numSpectraFilename = [info.SEEDRootDir, 'SummaryNumSpectra.txt'];
if isfile(numSpectraFilename)
     delete(numSpectraFilename)
end

%Loop through the day of interest.
for missionDayNumber = info.startMissionDayNumber : info.endMissionDayNumber

    %Check to see if the mission day number is in the list of bad mission
    %day numbers.
    badDayIndex = find(missionDayNumber == info.SEEDBadDays);

    %If the mission day number is bad, skip it and move on to the next one.
    if length(badDayIndex) >= 1
        continue
    else
        %Make a plot of the data.
        makeSEEDCDFPlots(missionDayNumber, info, visibleFlag, ...
            numSpectraFilename, plotSectorBoundaries);
    end
%    close all;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  makeSEEDCDFPlots.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function makeSEEDCDFPlots(missionDayNumber, info, visibleFlag, ...
    numSpectraFilename, plotSectorBoundaries)

%Read a cdf file.  The times that are read in are converted to Matlab's
%datenum time automatically.
[CDFInfo, CDFData] = importSEEDCDF1(info, missionDayNumber);

%Now write out to a file the number of events and percentage events for a
%given day. 
outputPercentEvents(CDFData, info, missionDayNumber, numSpectraFilename);

%Make plots of the data.
SEEDCDFPlotSEEDData(info, CDFInfo, CDFData, visibleFlag, missionDayNumber, ...
    plotSectorBoundaries);
%SEEDCDFPlotDoseTempData(info, CDFInfo, CDFData, visibleFlag, ...
%    missionDayNumber)

%SEEDCDFPlotTimeEnergySpectra(info, CDFInfo, CDFData, visibleFlag, ...
%    missionDayNumber);

end  %End of the function makeSEEDCDFPlots.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% outputPercentEvents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outputPercentEvents(CDFData, info, missionDayNumber, ...
    numSpectraFilename)

%Save to a file the total number of energy spectra for a given day.
numEvents = length(CDFData.Epoch);
percentEvents = 100*numEvents/5760;

fid = fopen(numSpectraFilename, 'at');
if fid ~= -1
    fprintf(fid, '%d,%d,%4.2f\n', missionDayNumber, numEvents, ...
        percentEvents);
    fclose(fid);
else
    warningMessage = sprintf('Cannot open file %s', numSpectraFilename);
end

end  %End of the function outputPercentEvents.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% SEEDCDFPlotSEEDData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SEEDCDFPlotSEEDData(info, CDFInfo, CDFData, visibleFlag, ...
    missionDayNumber, plotSectorBoundaries)

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
%datetimeTime = datetime(time, 'ConvertFrom', 'datenum');
goodDayIndex = find(time.Day == dayOfMonth);
%datetimeTime = datetimeTime(goodDayIndex);
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
%ttDatetime = datetime(time,'ConvertFrom','datenum');
ttDatetime = time;

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



%Here we find the local time boundaries in terms of UTC time.
dawnLocalTimeIndex = find(time.Hour == 9);
noonLocalTimeIndex = find(time.Hour == 15);
duskLocalTimeIndex = find(time.Hour == 21);
midnightLocalTimeIndex = find(time.Hour == 3);

imagesc(interpTime, energyBins, log10(interpFlux)')
xticks(xTickVals)
%datetick('x', dateFormat, 'keepticks')
ylabel('Energy (keV)')
title(titStr)
caxis([3 8])
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% SEEDCDFPlotDoseTempData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SEEDCDFPlotDoseTempData(info, CDFInfo, CDFData, visibleFlag, ...
    missionDayNumber)

%Convert mission day of year into year, month and day of month.
[year, month, dayOfMonth] = MDNToMonthDay(missionDayNumber);
[dayOfYear, year] = MDNToDN(missionDayNumber);

if visibleFlag == 1
    fig2 = figure('DefaultAxesFontSize', 12);
else
    fig2 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
end

ax = axes();
fig2.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

left = 0.1;
width = 0.8;
height = 0.19;
bottom = [0.74, 0.5, 0.3, 0.1];

satellite = "Falcon";
instrument = "SEED";
plotType = "Dosimeter and Temperature";
dateStr = [num2str(year), num2str(month, '%02d'), num2str(dayOfMonth, '%02d')];
doyStr = num2str(dayOfYear, '%03d');

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + "_Dosimeter_Temp" + "_" + ...
    dateStr + "_" + doyStr;

DosimeterFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

%Make the plots.
sp1 = subplot(4, 1, 1); 
plot(CDFData.SEED_Dosimeter_Time(2:end), CDFData.SEED_Dosimeter_Dose(2:end, 1), 'b')
title(titStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 1)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 1))])
xlim([CDFData.SEED_Dosimeter_Time(2) CDFData.SEED_Dosimeter_Time(end)]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(4, 1, 2);
plot(CDFData.SEED_Dosimeter_Time(2:end), CDFData.SEED_Dosimeter_Dose(2:end, 2), 'g')
ylabel('Dose (Rads)','FontSize', 16);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 2)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 2))])
xlim([CDFData.SEED_Dosimeter_Time(2) CDFData.SEED_Dosimeter_Time(end)]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(4, 1, 3);
plot(CDFData.SEED_Dosimeter_Time(2:end), CDFData.SEED_Dosimeter_Dose(2:end, 3), 'r')
datetick('x', 'HH:MM')
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 3', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 3)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 3))])
set(gca, 'Xticklabel', []);
set(sp3, 'Position', [left, bottom(3), width, height]);
xlim([CDFData.SEED_Dosimeter_Time(1) CDFData.SEED_Dosimeter_Time(end)]);

sp4 = subplot(4, 1, 4);
plot(CDFData.SEED_Dosimeter_Time, CDFData.SEED_Temperature, 'black')
datetick('x', 'HH:MM')
ylabel('Temperature ^{\circ}C');
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Temperature', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Temperature), 100])
set(sp4, 'Position', [left, bottom(4), width, height]);
xlim([CDFData.SEED_Dosimeter_Time(1) CDFData.SEED_Dosimeter_Time(end)]);
xlabel('UTC Time (Hours)')
yticks([50, 60 70 80 90])
yticklabels({'50', '60', '70', '80', '90'})

%Save the time series to a file.
saveas(fig2, DosimeterFileName);

end  %End of the function SEEDCDFPlotDoseTempData.m


% function info = generateInformationStructure(instrument, varargin)
% 
% %We want to have the option to input the mission day of year.  
% %Start with declaring an input parser handle.
% p = inputParser;
% 
% addRequired(p, 'instrument');
% 
% 
% %Handle the instrument information.
% info.Instrument = instrument;
% generalFilesPath = '/SS1/Matlab/';
% info.generalFilesPath = generalFilesPath;
% 
% %Set up the color bar axis range for making spectrogram plots.
% cAxisLow = 6;
% cAxisHigh = 8;
% 
% info.cAxisLow = cAxisLow;
% info.cAxisHigh = cAxisHigh;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %Set up a test to see if the input value is a valid scalar(not array)
% %positive integer.
% validScalarPosInteger = @(x) isnumeric(x) && isscalar(x) ...
%     && (x >= 0) && (mod(x, 1) == 0);
% 
% %Set up a test to see if the input value is a valid scalar(not array)
% %positive number.
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
% 
% %Now handle the instrument specific information cases.
% if strcmp(instrument, 'SEED')
% 
%     addRequired(p, 'startDayOfYear', validScalarPosInteger);
%     addRequired(p, 'startYear', validScalarPosInteger);
%     addRequired(p, 'startHour', validScalarPosInteger);
%     addRequired(p, 'startMinute', validScalarPosInteger);
%     addRequired(p, 'startSecond', validScalarPosNum);
% 
%     addRequired(p, 'endDayOfYear', validScalarPosInteger);
%     addRequired(p, 'endYear', validScalarPosInteger);
%     addRequired(p, 'endHour', validScalarPosInteger);
%     addRequired(p, 'endMinute', validScalarPosInteger);
%     addRequired(p, 'endSecond', validScalarPosNum);
% 
%     addRequired(p, 'startEnergyBinNumber', validScalarPosInteger);
%     addRequired(p, 'startEnergy', validScalarPosNum);
%     addRequired(p, 'endEnergy', validScalarPosNum);
%     addRequired(p, 'numEnergyBinsToSum', validScalarPosInteger);
%     addRequired(p, 'numTimeBinsToSum', validScalarPosInteger);
%     addRequired(p, 'numTimeStepsToSkip', validScalarPosInteger);
%     addRequired(p, 'CDFDataVersionNumber', validScalarPosNum);
% 
%     %Now parse the input arguments.
%     parse(p, instrument, varargin{:});
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Get the start and end times.
%     startHour = p.Results.startHour;
%     startMinute = p.Results.startMinute;
%     startSecond = p.Results.startSecond;
%     endHour = p.Results.endHour;
%     endMinute = p.Results.endMinute;
%     endSecond = p.Results.endSecond;
% 
%     %Fill the start and end times and strings.
%     info.startSecond = startSecond;
%     info.startSecondStr = num2str(startSecond, '%02d');
%     info.endHour = endHour;
%     info.endHourStr = num2str(endHour, '%02d');
%     info.endMinute = endMinute;
%     info.endMinuteStr = num2str(endMinute, '%02d');
%     info.endSecond = endSecond;
%     info.endSecondStr = num2str(endSecond, '%02d');
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%  Date Information %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Take care of the year and day of year
% 
%     startYear = p.Results.startYear;
%     startDayOfYear = p.Results.startDayOfYear;
%     endYear = p.Results.endYear;
%     endDayOfYear = p.Results.endDayOfYear;
% 
%     info.startYear = startYear;
%     info.startYearStr = num2str(startYear);
%     info.startDayOfYear = startDayOfYear;
%     info.startDayOfYearStr = num2str(startDayOfYear, '%03d');
%     info.endYear = endYear;
%     info.endYearStr = num2str(endYear);
%     info.endDayOfYear = endDayOfYear;
%     info.endDayOfYearStr = num2str(endDayOfYear, '%03d');
% 
%     %Determine the month and day of month for each day of year.
%     startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
%     startMonth = startDateVector(2);
%     startDayOfMonth = startDateVector(3);
%     endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
%     endMonth = endDateVector(2);
%     endDayOfMonth = endDateVector(3);
% 
%     info.startMonth = startMonth;
%     info.startMonthStr = num2str(startMonth, '%02d');
%     info.startDayOfMonth = startDayOfMonth;
%     info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');
%     info.endMonth = endMonth;
%     info.endMonthStr = num2str(endMonth, '%02d');
%     info.endDayOfMonth = endDayOfMonth;
%     info.endDayOfMonthStr = num2str(endDayOfMonth, '%02d');
% 
%     %Lets write a month string.  Matlab has a way to do this
%     startMonthName = datestr(datetime(1, startMonth, 1), 'mmmm');
%     info.startMonthName = startMonthName;
%     endMonthName = datestr(datetime(1, endMonth, 1), 'mmmm');
%     info.endMonthName = endMonthName;
% 
%     %Generate a date string.
%     info.startDateStr = [info.startYearStr, info.startMonthStr, ...
%         info.startDayOfMonthStr];
%     info.endDateStr = [info.endYearStr, info.endMonthStr, ...
%         info.endDayOfMonthStr];
% 
%     startEnergyBinNumber = p.Results.startEnergyBinNumber;
%     startEnergy = p.Results.startEnergy;
%     endEnergy = p.Results.endEnergy;
%     numEnergyBinsToSum = p.Results.numEnergyBinsToSum;
%     numTimeBinsToSum = p.Results.numTimeBinsToSum;
%     numTimeStepsToSkip = p.Results.numTimeStepsToSkip;
%     CDFDataVersionNumber = p.Results.CDFDataVersionNumber;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%  Directory Information  %%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     info.dosimeterRootDir = '/SS1/STPSat-6/Dosimeter/';
%     info.dosimeterPlotDir = '/SS1/STPSat-6/Plots/Dosimeter/';
%     info.temperatureRootDir = '/SS1/STPSat-6/Temperature/';
%     info.temperaturePlotDir = '/SS1/STPSat-6/Plots/Temperature/';
%     info.SEEDRootDir = '/SS1/STPSat-6/SEED/';
%     info.SEEDPlotDir = '/SS1/STPSat-6/Plots/SEED/';
%     info.STPSat6RootDir = '/SS1/STPSat-6/';
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%  Instrument Information %%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Set out the starting day of year and year for the mission(that is, the
%     %time we started getting data).
%     firstLightYear = 2022;
%     firstLightDayOfYear = 15;
%     firstLightMonth = 1;
%     firstLightDayOfMonth = 15;
% 
%     info.firstLightYear = firstLightYear;
%     info.firstLightDayOfYear = firstLightDayOfYear;
%     info.firstLightMonth = firstLightMonth;
%     info.firstLightDayOfMonth = firstLightDayOfMonth;
% 
%     info.Host = 'STPSat-6';
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%  Dosimeter Information %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %We need to input the counts to rads conversion factors for each channel.
%     %The relevant values from the paper are :
%     %Channel 0(Our channel 1) : 1051.7 Counts/mRad = 1.0517e6 Counts/Rad.
%     %Channel 1(Our channel 2) : 4206.7 Counts/Rad.
%     %Channel 2(Our channel 3) : 16.1 Counts/Rad.
%     %Channel 3(Our channel 4) : 37.9 Counts/kRad = 3.79e-2 Counts/Rad.
%     %We believe that due to how the instrument was built that these values are
%     %not correct and have determined others.
% 
%     %Let's make some conversion factors.  These values convert the counts into
%     %Rads.  These are determined from the data itself.
%     DosimeterChannel1CountsToRads = 1.0/2.47919e6;
%     DosimeterChannel2CountsToRads = 1.0/9916.78;
%     DosimeterChannel3CountsToRads = 1.0/37.98;
%     DosimeterChannel4CountsToRads = 1.0/8.925e-2;  %We will not use.
% 
%     info.DosimeterChannel1CountsToRads = DosimeterChannel1CountsToRads;
%     info.DosimeterChannel2CountsToRads = DosimeterChannel2CountsToRads;
%     info.DosimeterChannel3CountsToRads = DosimeterChannel3CountsToRads;
%     info.DosimeterChannel4CountsToRads = DosimeterChannel4CountsToRads;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%  SEED Information %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     info.numEnergyBinsToSum = numEnergyBinsToSum;
%     info.startEnergyBinNumber = startEnergyBinNumber;
% 
%     %Let's generate the energy bins.
%     energyBins = generateSEEDEnergyBins(startEnergyBinNumber, ...
%         numEnergyBinsToSum);
% 
%     %Set the energy bins into the info structure.
%     info.energyBins = energyBins;
%     info.deltaE = 0.1465*numEnergyBinsToSum;
% 
%     %Get the starting and ending energies.
%     info.startEnergy = startEnergy;
%     info.endEnergy = endEnergy;
% 
%     %Determine the geometric factor.
%     g = getSEEDGeometricFactor(energyBins);
% 
%     %Set the geometric factor into the info structure.
%     info.g = g;
% 
%     %Determine the geometric factor width.
%     deltaG = 0.5e-6;  %Units are in cm^2 ster.
%     info.deltaG = deltaG;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Set the sample time.  This is correct for both the SEED data as well
%     %as the Dosimeter data.
%     timeBinWidth = 15.0;  %Units are in seconds.
%     info.timeBinWidth = timeBinWidth;
%     info.numTimeStepsToSkip = numTimeStepsToSkip;
% 
%     %Determine the time bin width.
%     deltaT = 0.5;  %Units are in seconds.
%     info.deltaT = deltaT;
% 
%     %Set up the Mission day of year information.
%     startMissionDayNumber = DNToMDN(startDayOfYear, startYear);
%     endMissionDayNumber = DNToMDN(endDayOfYear, endYear);
% 
%     info.startMissionDayNumber = startMissionDayNumber;
%     info.endMissionDayNumber = endMissionDayNumber;
% 
%     %Add in the epoch time data.
%     epochYear = 1980;
%     epochMonth = 1;
%     epochDayOfMonth = 6;
%     epochHour = 0;
%     epochMinute = 0;
%     epochSecond = 0.0;
% 
%     info.epochYear = epochYear;
%     info.epochMonth = epochMonth;
%     info.epochDayOfMonth = epochDayOfMonth;
%     info.epochHour = epochHour;
%     info.epochMinute = epochMinute;
%     info.epochSecond = epochSecond;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%  NASA CDF Information  %%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Handle the CDF version number field.
%     info.CDFDataVersionNumber = CDFDataVersionNumber;
% 
%     CDFMasterFilename = [info.STPSat6RootDir, 'CDF/', 'STPSat-6_SPDF.cdf'];
%     info.CDFMasterFilename = CDFMasterFilename;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%  Auxilliary Data Info  %%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     DstFilename = ['/SS1/STPSat-6/AncillaryData/Dst/', ...
%         'DstData20220101-20230301.txt'];
%     info.DstFilename = DstFilename;
% 
%     %Get the Dst index for a given set of days.  The inputs are start year,
%     %start day of year and start hour as well as the end year, end day of
%     %year and end hour.
%     DstIndex = getDstIndex(info, startYear, startDayOfYear, startHour, ...
%         endYear, endDayOfYear, endHour);
% 
%     info.DstIndex = DstIndex;
% 
% 
%     %Get the Kp and Ap indices.
%     KpApFilename = ['/SS1/STPSat-6/AncillaryData/KpAp/', ...
%         'KpApIndex20220101-20230404.txt'];
%     info.KpApFilename = KpApFilename;
% 
%     KpApIndex = getKpApIndex(info, startYear, startDayOfYear, startHour, ...
%         endYear, endDayOfYear, endHour);
%     info.KpApIndex = KpApIndex;
% 
%     %Get the ACE electron flux data.
%     %ACEElectronFlux = getACEElectronFlux(info, startYear, startDayOfYear, ...
%     %    startHour, endYear, endDayOfYear, endHour);
%     %info.ACEElectronFlux = ACEElectronFlux;
% 
%     %Get the ACE Magnetic field data.
%     %ACEB = getACEB(info, startYear, startDayOfYear, startHour, ...
%     %    endYear, endDayOfYear, endHour);
%     %info.ACEB = ACEB;
% 
%     % AEFilename = '/SS1/STPSat-6/AncillaryData/AE/AEData20220101-20230301.txt';
%     % info.AEFilename = AEFilename;
% 
%     % %Get the AE index for the given set of days.  The inputs are start year,
%     % %start day of year and start hour as well as the end year, end day of year
%     % %and end hour.
%     % AEIndex = getAEIndex(info, startYear, startDayOfYear, startHour, ...
%     %     endYear, endDayOfYear, endHour);
%     %
%     % info.AEIndex = AEIndex;
% 
% end  %End of if statement - if strcmp(instrument, 'SEED') :
% 
% if strcmp(instrument, 'EPEE') 
% 
%     addRequired(p, 'startDayOfYear', validScalarPosInteger);
%     addRequired(p, 'startYear', validScalarPosInteger);
%     addRequired(p, 'startHour', validScalarPosInteger);
%     addRequired(p, 'startMinute', validScalarPosInteger);
%     addRequired(p, 'startSecond', validScalarPosNum);
% 
%     addRequired(p, 'endDayOfYear', validScalarPosInteger);
%     addRequired(p, 'endYear', validScalarPosInteger);
%     addRequired(p, 'endHour', validScalarPosInteger);
%     addRequired(p, 'endMinute', validScalarPosInteger);
%     addRequired(p, 'endSecond', validScalarPosNum);
% 
%     addRequired(p, 'numTimeBinsToSum', validScalarPosInteger);
%     addRequired(p, 'numTimeStepsToSkip', validScalarPosInteger);
%     addRequired(p, 'CDFDataVersionNumber', validScalarPosNum);
% 
%     %Now parse the input arguments.
%     parse(p, instrument, varargin{:});
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Get the start and end times.
%     startHour = p.Results.startHour;
%     startMinute = p.Results.startMinute;
%     startSecond = p.Results.startSecond;
%     endHour = p.Results.endHour;
%     endMinute = p.Results.endMinute;
%     endSecond = p.Results.endSecond;
% 
%     %Fill the start and end times and strings.
%     info.startSecond = startSecond;
%     info.startSecondStr = num2str(startSecond, '%02d');
%     info.endHour = endHour;
%     info.endHourStr = num2str(endHour, '%02d');
%     info.endMinute = endMinute;
%     info.endMinuteStr = num2str(endMinute, '%02d');
%     info.endSecond = endSecond;
%     info.endSecondStr = num2str(endSecond, '%02d');
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%  Date Information %%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Take care of the year and day of year
% 
%     startYear = p.Results.startYear;
%     startDayOfYear = p.Results.startDayOfYear;
%     endYear = p.Results.endYear;
%     endDayOfYear = p.Results.endDayOfYear;
% 
%     info.startYear = startYear;
%     info.startYearStr = num2str(startYear);
%     info.startDayOfYear = startDayOfYear;
%     info.startDayOfYearStr = num2str(startDayOfYear, '%03d');
%     info.endYear = endYear;
%     info.endYearStr = num2str(endYear);
%     info.endDayOfYear = endDayOfYear;
%     info.endDayOfYearStr = num2str(endDayOfYear, '%03d');
% 
%     %Determine the month and day of month for each day of year.
%     startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
%     startMonth = startDateVector(2);
%     startDayOfMonth = startDateVector(3);
%     endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
%     endMonth = endDateVector(2);
%     endDayOfMonth = endDateVector(3);
% 
%     info.startMonth = startMonth;
%     info.startMonthStr = num2str(startMonth, '%02d');
%     info.startDayOfMonth = startDayOfMonth;
%     info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');
%     info.endMonth = endMonth;
%     info.endMonthStr = num2str(endMonth, '%02d');
%     info.endDayOfMonth = endDayOfMonth;
%     info.endDayOfMonthStr = num2str(endDayOfMonth, '%02d');
% 
%     %Lets write a month string.  Matlab has a way to do this
%     startMonthName = datestr(datetime(1, startMonth, 1), 'mmmm');
%     info.startMonthName = startMonthName;
%     endMonthName = datestr(datetime(1, endMonth, 1), 'mmmm');
%     info.endMonthName = endMonthName;
% 
%     %Generate a date string.
%     info.startDateStr = [info.startYearStr, info.startMonthStr, ...
%         info.startDayOfMonthStr];
%     info.endDateStr = [info.endYearStr, info.endMonthStr, ...
%         info.endDayOfMonthStr];
% 
%     numTimeBinsToSum = p.Results.numTimeBinsToSum;
%     numTimeStepsToSkip = p.Results.numTimeStepsToSkip;
%     CDFDataVersionNumber = p.Results.CDFDataVersionNumber;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%  Directory Information  %%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     info.EPEERootDir = '/SS1/STP-H9/';
%     info.EPEEPlotDir = '/SS1/STP-H9/Plots/';
%     info.EPEEDataDir = '/SS1/STP-H9/EPEE/';
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%  Instrument Information  %%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Add in the epoch time data.
%     epochYear = 1980;
%     epochMonth = 1;
%     epochDayOfMonth = 6;
%     epochHour = 0;
%     epochMinute = 0;
%     epochSecond = 0.0;
% 
%     info.epochYear = epochYear;
%     info.epochMonth = epochMonth;
%     info.epochDayOfMonth = epochDayOfMonth;
%     info.epochHour = epochHour;
%     info.epochMinute = epochMinute;
%     info.epochSecond = epochSecond;
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%% Species Information %%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %We are operating the instrument in low Earth orbit and we have assumed
%     %that we are observing singly ionized Oxygen atoms.  This is likely to
%     %be a fine assumption.  However, it is known that protons are also
%     %observed at this altitude and so it is possible that we have a mixture
%     %of the two species along with the stray He ion and others.  We will
%     %assume until necessary that we are looking at Oxygen.
%     atomicMassUnit = 1.66054e-27; %Units are in kilograms.
%     protonMass = 1.0080*atomicMassUnit;  
%     oxygenMass = 15.999*atomicMassUnit;
%     info.atomicMassUnit = atomicMassUnit;
%     info.protonMass = protonMass;
%     info.oxygenMass = oxygenMass;
% 
%     %Convert to sweep voltage to ion energy.  This may not be correct but I
%     %will start with this.
%     EPEEDataSize = 65535; %2^16 - 1;
%     info.EPEEDataSize = EPEEDataSize;
% 
%     %The instrument reference voltage.
%     referenceVoltage = 3.0;
%     info.referenceVoltage = referenceVoltage;
% 
%     %The instrument geometric factor as calculated by Gabe Wilson reported
%     %to me in an email.  Geometric Factor (single ESA channel) = 6.4 +/-
%     %0.3 x 10^-7 1/(sr * cm^2) 
%     geometricFactor = 6.4e-7;  %Units are 1/(sr cm^2);
%     info.geometricFactor = geometricFactor;
% 
%     %The instrument plate factor. Plate Factor = 6.54 +/- 0.04
%     plateFactor = 6.54;
%     info.plateFactor = plateFactor;
% 
%     %The instrument through put.  Through_put = 0.060 +/- 0.001
%     throughPut = 0.060;
%     info.throughPut = throughPut;
% 
%     %The instrument Azimuth angle of acceptance. Azimuth Angle Acceptance 
%     %= (-21.8 +/- 0.3, 21.8 +/- 0.2) degrees.
%     azimuthAngleOfAcceptance = 21.8;  %Units are in degrees.
%     info.azimuthAngleOfAcceptance = azimuthAngleOfAcceptance;
% 
%     %The instrument elevation angle of acceptance. = Elevation angle of 
%     %Acceptance = (-4.96 +/- 0.06, 4.6 +/- 0.2) degrees
%     elevationAngleOfAcceptance = 4.96; %Units are in degrees.
%     info.elevationAngleOfAcceptance = elevationAngleOfAcceptance;
% 
%     %The ratio of the energy width over the energy.  dE/E = 0.41 +/- 0.06
%     deltaEOverE = 0.41;  %No units
%     info.deltaEOverE = deltaEOverE;
% 
%     %Instrument information.
%     numEnergyBins = 100;
%     numDosimeterADCBins = 16384;
% 
%     info.numEnergyBins = numEnergyBins;
%     info.numDosimeterADCBins = numDosimeterADCBins;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%  Voltage Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %The voltage gain on the plate.
%     plateVoltageGain = 0.1;
%     info.plateVoltageGain = plateVoltageGain;
% 
%     %This is the value for converting plate voltage to energy of incoming ions.
%     % This may not be correct!  The units are eV/Volt.  The citation for the
%     %plate factor is : "A laminated energetic electrostatic analyzer for 0–5 keV
%     %charged particles".  The exact value is 6.21+- 0.39.  I have a
%     %different value from Gabe's work.  Lets use that instead of the paper
%     %since the citation is from a different instrument.
%     plateVoltageToIonEnergy = plateFactor;
% 
% 
%     %Finally we combine all of the above conversion factors.
%     ADCVoltageCountsToIonEnergy = referenceVoltage*plateVoltageToIonEnergy/...
%         (plateVoltageGain*EPEEDataSize);
% 
%     info.ADCVoltageCountsToIonEnergy = ADCVoltageCountsToIonEnergy;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%  Current Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Convert the adc values into a current.
%     TIAGain = 5.0e7;
%     info.TIAGain = TIAGain;
% 
%     %Lets convert to nanoAmperes.
%     conversionToNanoAmps = 1.0e-9;
% 
%     %Units are in nanoAmps.
%     ADCIonCountsToCurrent = referenceVoltage/(conversionToNanoAmps*EPEEDataSize*TIAGain);
%     info.ADCIonCountsToCurrent = ADCIonCountsToCurrent;
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%% Physical Constants %%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     BoltzmannConstant = 8.6173333e-5; %Units are eV/K
%     info.BoltzmannConstant = BoltzmannConstant;
% 
% 
% end  %End of if statement - if strcmp(instrument, 'EPEE') : 
% 
% end  %End of the function generateInformationStructure.m

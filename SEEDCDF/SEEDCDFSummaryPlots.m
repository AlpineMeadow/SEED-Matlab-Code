%This script will make summary plots
dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 346;
startDayOfYear = 64;
endDayOfYear = 64;
startYear = 2022;
endYear = 2022;

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

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateInformationStructure(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber);

%Here is a list of the bad days of year for 2022 in mission day numbers.
badDays2022 = DNToMDN([23, 75, 76, 85, 135, 136, 137, 138, 200, 201, ...
    202, 272, 299, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, ...
    330, 347, 348], 2022);

%There are no bad days so far in 2023.
badDays2023 = DNToMDN([22, 27, 28, 101, 102], 2023);

%Combine all of the bad days into one single vector.
badDays = [badDays2022, badDays2023];

%For large sets of days to be analyzed, it is easier to not allow the plots
%to show on the screen.  We make a flag that tells Matlab to either plot to
%the screen or not.
visibleFlag = 1;

%Loop through the day of interest.
for missionDayNumber = info.startMissionDayNumber : info.endMissionDayNumber
    
    %Check to see if the mission day number is in the list of bad mission
    %day numbers.
    badDayIndex = find(missionDayNumber == badDays);

    %If the mission day number is bad, skip it and move on to the next one.
    if length(badDayIndex) >= 1
        continue
    else
        %Make a plot of the data.
        makeSEEDCDFPlots(missionDayNumber, info, visibleFlag);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  makeSEEDCDFPlots.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function makeSEEDCDFPlots(missionDayNumber, info, visibleFlag)

%Read a cdf file.  The times that are read in are converted to Matlab's
%datenum time automatically.
[CDFInfo, CDFData] = importSEEDCDF1(info, missionDayNumber);

%Now write out to a file the number of events and percentage events for a
%given day. 
outputPercentEvents(CDFData, info, missionDayNumber);

%Make plots of the data.
SEEDCDFPlotSEEDData(info, CDFInfo, CDFData, visibleFlag, missionDayNumber)
SEEDCDFPlotDoseTempData(info, CDFInfo, CDFData, visibleFlag, ...
    missionDayNumber)

end  %End of the function makeSEEDCDFPlots.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% outputPercentEvents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outputPercentEvents(CDFData, info, missionDayNumber)

%Save to a file the total number of energy spectra for a given day.
numEvents = length(CDFData.Epoch);
percentEvents = 100*numEvents/5760;
numSpectraFilename = [info.SEEDRootDir, 'SummaryNumSpectra.txt'];


fid = fopen(numSpectraFilename, 'at');
if fid ~= -1
    fprintf(fid, '%d,%d,%4.2f\n', missionDayNumber, numEvents, percentEvents);
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
    missionDayNumber)

%Now plot a spectrogram of the data.

%Convert mission day of year into year, month and day of month.
[year, month, dayOfMonth] = MDNToMonthDay(info, missionDayNumber);
[dayOfYear, year] = MDNToDN(info, missionDayNumber);

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
ax.Position = [0.13, 0.11, 0.775, 0.8150];

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

SEEDFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

%Let us now interpolate and smooth the data.
%First make an interpolation vector. We will interpolate onto a time grid
%with a delta t of 15 seconds.
ttDatetime = datetime(time,'ConvertFrom','datenum');

%Convert from the datetime structure into seconds from start of the day.
timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
    ttDatetime.Second;

%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;

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

imagesc(time, energyBins, log10(interpFlux)')
caxis('auto')
%datetick('x', dateFormat, 'keepticks')
%datetick('x', dateFormat, 'keeplimits')
%datetick('x', dateFormat, 'keepticks', 'keeplimits')
xticks(xTickVals)
datetick('x', dateFormat, 'keepticks')
ylabel('Energy (keV)');
title(titStr);
caxis([3 8])
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;

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
[year, month, dayOfMonth] = MDNToMonthDay(info, missionDayNumber);
[dayOfYear, year] = MDNToDN(info, missionDayNumber);

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
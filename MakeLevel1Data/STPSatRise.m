%This script will take the STPSat-6 data from raw to Level 1.  This script
%has to be run for each individual day.  It calls functions written by
%Richard to convert the raw SEED data to level 1 SEED data.

%Once this script is run then we need to run JoinLevel1Data.m on the level
%1 data files in order to combine/join the various data files produced for
%each day. 

close all;
clearvars;

dbstop if error;

%Set the day to be analyzed.
startDayOfYear = 262;
endDayOfYear = 262;
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

%Create the root path.
rootPath = '/SS1/STPSat-6/';

%For large sets of days to be analyzed, it is easier to not allow the plots
%to show on the screen.  We make a flag that tells Matlab to either plot to
%the screen or not.
visibleFlag = 0;

%Now loop through the days of interest and raise the data from raw to level
%one. 
for mdn = info.startMissionDayNumber : info.endMissionDayNumber

    %Convert mission day number to year and day of year.
    [dayOfYear, year] = MDNToDN(mdn);

    %Lets print out what day we are analyzing.
    disp(['Analyzing day of year : ', num2str(dayOfYear, '%03d')])

    %Now call the function that brings the raw data to Level 0 data.
    SEEDRaw_L0(info, mdn);

    disp('Finished with SEEDRaw_L0.  Starting SEEDL0_L1')

    %Lets time how long this function takes. 
    timeValue = tic;

    %Now call the function that brings the Level 0 data to Level 1 data.
    SEEDL0_L1(info);
    disp(['Finished SEEDL0_L1.  Memory should drop down'])
    elapsedTime = toc(timeValue);

    disp(['Elapsed Time : ', num2str(elapsedTime)])
    joe = 1;
%    SEEDL0_L1_old(info)
end

%Now join the various level one files into a single data file.
%Loop through the mission day of years.
for mdn = info.startMissionDayNumber : info.endMissionDayNumber

    %Convert mission day number to year and day of year.
    [dayOfYear, year] = MDNToDN(mdn);
    disp(['Year : ', num2str(year), ' Day of Year : ', ...
        num2str(dayOfYear, '%03d'), ' Mission Day Number : ', ...
    num2str(mdn)])

    %Open the files and combine the data into one single file.
    combineData(info, mdn);
end

%Now make summary plots of the data.
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
            plotSectorBoundaries);
    end %End of if-else clause - if length(badDayIndex) >= 1

end  %End of for loop - for missionDayNumber = 
%              info.startMissionDayNumber : info.endMissionDayNumber


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%  makeSEEDCDFPlots.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function makeSEEDCDFPlots(missionDayNumber, info, visibleFlag, ...
    plotSectorBoundaries)

%Read a cdf file.  The times that are read in are converted to Matlab's
%datenum time automatically.
[~, CDFData] = importSEEDCDF1(info, missionDayNumber);

%Make summary plots of the SEED data.
plotSEEDData(info, CDFData, visibleFlag, ...
    missionDayNumber, plotSectorBoundaries);

%Plot the temperature and dose data.
plotDoseTempData(CDFData, visibleFlag, missionDayNumber)

end  %End of the function makeSEEDCDFPlots.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% plotSEEDData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSEEDData(info, CDFData, visibleFlag, ...
    missionDayNumber, plotSectorBoundariesFlag)

%Now plot a spectrogram of the data.

%Convert mission day of year into year, month and day of month.
[~, month, dayOfMonth] = MDNToMonthDay(missionDayNumber);
[dayOfYear, year] = MDNToDN(missionDayNumber);

xTickLabels = {[0 : 23, 0]};

%Set up the y axis tick labels and values.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [CDFData.SEED_Energy_Channels(1), ...
    CDFData.SEED_Energy_Channels(end)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Sometimes we do not want to make a large number of plots appear onto the
%screen.  This can happen when lots of plots are being made.  If we have
%lots of plots to make, then we tell Matlab not to make plots to the
%screen.

%Get the variables out of the CDFData structure.
time = CDFData.Epoch;
energyBins = CDFData.SEED_Energy_Channels;
data = double(CDFData.SEED_Electron_Flux_Total);
numEnergyBins = length(energyBins);

%Due to the difference between UTC and GPS time systems the data may have
%been taken during the previous day.  Let us remove any data that
%corresponds to the day before. This should only be a couple of data
%points.
goodDayIndex = find(time.Day == dayOfMonth);
time = time(goodDayIndex);

%Set the figure handle.
if visibleFlag == 1
    fig2 = figure('DefaultAxesFontSize', info.fontSize);
else
    fig2 = figure('DefaultAxesFontSize', info.fontSize, 'visible', 'off');
end

%Set the axes values.
ax = axes();
fig2.Position = [info.positionLeft, info.positionBottom, ...
                info.positionWidth, info.positionHeight];
ax.Position = [info.axesLeft, info.axesBottom, info.axesWidth, ...
                info.axesHeight];
ax.FontWeight = info.fontWeight;


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
timeSeconds = time.Hour*3600 + time.Minute*60 + time.Second;

%Convert from the datetime structure into seconds from start of the day.
%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;
interpTime = datetime(year, month, dayOfMonth) + seconds(tt);

%Create a vector of x tick values.
xTickVals = NaT(1, 25);

for ii = 0 : 23
    hIndex = find(interpTime.Hour == ii);
    xTickVals(ii + 1) = interpTime(hIndex(1)');
    if ii == 23
        xTickVals(25) = interpTime(hIndex(end));
    end 
end

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
interpFlux(interpFlux <= 0) = 0.001;

%The array interpFlux can potentially have NaN values.  Lets get rid of
%them.
NaNIndex = isnan(interpFlux);
interpFlux(NaNIndex) = 1.0;

interpFlux10 = log10(interpFlux);

%Now plot the data in the form of a spectrogram.
imagesc(interpTime, energyBins, interpFlux10')
xticks(xTickVals)
ylabel('Energy (keV)')
title(titStr)
caxis([3 8])
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
ax.YDir = 'normal';
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;


hold on

if plotSectorBoundariesFlag
    plotSectorBoundaries(ax, yLimValues, time)
end  %End of if statement - if plotSectorBoundaries


%Create a flag to determine if we will plot the local time on the x-axis.
ltAxis = 1;

if ltAxis == 1
    plotLocalTimeAxes(ax, xTickLabels)
end  %End of if statement - if ltAxis == 1


%Save the time series to a file.
saveas(fig2, SEEDFileName);

end  %end of function plotSEEDData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% plotDoseTempData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotDoseTempData(CDFData, visibleFlag, ...
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
%ax.Position = [0.13, 0.11, 0.775, 0.8150];

left = 0.1;
width = 0.8;
height = 0.19;
bottom = [0.74, 0.5, 0.3, 0.1];

satellite = "Falcon";
instrument = "SEED";
plotType = "Dosimeter and Temperature";
dateStr = [num2str(year), num2str(month, '%02d'), ...
    num2str(dayOfMonth, '%02d')];
doyStr = num2str(dayOfYear, '%03d');

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + "_Dosimeter_Temp" + "_" + ...
    dateStr + "_" + doyStr;

DosimeterFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

%Make the plots.
sp1 = subplot(4, 1, 1); 
plot(CDFData.SEED_Dosimeter_Time(2:end), ...
    CDFData.SEED_Dosimeter_Dose(2:end, 1), 'b')
title(titStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', ...
    'Channel 1', 'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 1)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 1))])
xlim([CDFData.SEED_Dosimeter_Time(2) CDFData.SEED_Dosimeter_Time(end)]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(4, 1, 2);
plot(CDFData.SEED_Dosimeter_Time(2:end), ...
    CDFData.SEED_Dosimeter_Dose(2:end, 2), 'g')
ylabel('Dose (Rads)','FontSize', 16);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', ...
    'Channel 2', 'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 2)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 2))])
xlim([CDFData.SEED_Dosimeter_Time(2) CDFData.SEED_Dosimeter_Time(end)]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(4, 1, 3);
plot(CDFData.SEED_Dosimeter_Time(2:end), ...
    CDFData.SEED_Dosimeter_Dose(2:end, 3), 'r')
datetick('x', 'HH:MM')
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', ...
    'Channel 3', 'FontSize', 15);
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

end  %End of the function plotDoseTempData.m

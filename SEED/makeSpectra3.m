function makeSpectra3(info, flux, energyBins, UTCTime, numEnergyBinsToSum, ...
    uniqueDateNum)


%This function is called by FalconSEEDSummary.m
%The function makes a spectrogram of the SEED electron data.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  Setting Up the Plotting Titles and Etc.  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Determine the number of events.
[numGoodEvents, numEnergyBins] = size(flux.fluxActual);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;
ratioOfGoodSpectraToTotalSpectra = [num2str(numGoodEvents), '/', num2str(5760)];

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr + " " + ratioOfGoodSpectraToTotalSpectra;
saveName = satellite + instrument + plotType + dateStr + "_" + doyStr + ...
    "_" + num2str(numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;

savefname = satellite + instrument + plotType + dateStr + "_" + doyStr + ...
    "_" + num2str(numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;

%Generate the output file name for the spectra.
fig1FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');

%Generate the save file name for the data.
saveFileName = strcat(info.SEEDPlotDir, savefname, '.mat');

%Set the figure handle and figure position.
fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  Setting Up the energy and time indices.  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This time index in this section will be used to set up the date number
%time index later.  It will not be used in the plotting.

%Get the index of the energy bins to be plotted.
energyIndex = find(energyBins(:, 2) > info.startEnergy & ...
    energyBins(:, 2) < info.endEnergy);

%Now we find the times of interest.
timeInSecondsStart = info.startHour*3600 + info.startMinute*60 + info.startSecond;
timeInSecondsEnd = info.endHour*3600 + info.endMinute*60 + info.endSecond;

%Get the index of the times to be plotted.
timeIndex = find(UTCTime > timeInSecondsStart & UTCTime < timeInSecondsEnd);
numEvents = length(timeIndex);

%Set the formatting for the datetick function call.  Here we are asking for
%the format to be "HH:MM".   
if timeInSecondsEnd - timeInSecondsStart > 7200
    dateFormat = 'HH';
else
    dateFormat = 'HH:MM';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  Set Up the x and y axis limits and labels %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set up the y-axis labels and limits.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [energyBins(energyIndex(1), 1), energyBins(energyIndex(end), 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set up the x-axis limits.
dayNumStart = datenum([info.startYear, info.startMonth, info.startDayOfMonth, ...
    info.startHour, info.startMinute, info.startSecond]);
dayNumEnd = datenum([info.endYear, info.endMonth, info.endDayOfMonth, ...
    info.endHour, info.endMinute, info.endSecond]);

xLimValues = [dayNumStart, dayNumEnd];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  Set up the data Time Indices       %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Find the day number index that fits the time range we are interested in.
sdateIndex = find(sdate >= dayNumStart & sdate <= dayNumEnd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Set Up the data array from the Energy and Time Indices %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set up the data array for plotting.
data = log10(flux.fluxActual(sdateIndex, energyIndex));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  Plot the Energy-Time Spectrogram         %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Now make the image.
%imagesc([timeStart, timeEnd],[info.startEnergy, info.endEnergy], data)
%imagesc(UTCTime, [info.startEnergy, info.endEnergy], data)
imagesc(sdate(sdateIndex), energyBins(energyIndex, 2), data')
%imagesc(sdate, energyBins(energyIndex, 2), data')
caxis('auto')
datetick('x', dateFormat)
ylabel('Energy (keV)');
title(titStr);
cb = colorbar;
ylabel(cb,'Log10(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;
ax.XLim = xLimValues; 


%Save the spectra to a file.
saveas(fig1, fig1FileName);

%Let's save the plotting variables that made the spectrogram.
time = sdate(sdateIndex);
energy = energyBins(energyIndex, 2);
save(saveFileName, 'time', 'energy', 'data');

end  %End of function makeSpectra3.m
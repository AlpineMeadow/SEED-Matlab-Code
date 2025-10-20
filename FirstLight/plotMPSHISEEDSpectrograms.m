function plotMPSHISEEDSpectrograms(info, plotStructure, dt, MPSHIElectronFlux, ...
    detectorNumber, savePDF, newSEEDFlux, MPSHIData)

%This function is called by plotGOESData.m.  It will make spectrograms of
%the SEED and MPS-HI data.

%Choose the detector.  There are 5 of them.  I have used the 2nd detector
%for this analysis.
MPSHIDetector = detectorNumber;

%Choose which day to look at.  The days go from 02/09 - 02/28.  I am going
%to look at day 02/12.  This is the 4th day in the MPS HI array of
%structures.
MPSHIDay = 4;
dayOfMonth = 12;

%Handle the figure and its axes.
fig1 = figure();
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];
fontsize(fig1, 10, "points")

%Set up the SEED energy channels and strings.
SEEDYTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
SEEDYLimValues = [info.energyBins(1, 2), info.energyBins(end, 2)];
SEEDYTickValues = [20, 40, 60, 80, 100, 120, 140];
[SEEDNumEnergyBins, ~] = size(info.energyBins);

%Set the plot time format.
dateFormat = 'HH';

%Get the variables out of the MPSHI data structure.
MPSHIEnergyBins = MPSHIData(MPSHIDay).ElectronEnergy(:, MPSHIDetector);

%Lets prepend zero to this energy bin vector.
MPSHIEnergyBins = [0.0; fix(MPSHIEnergyBins)];
MPSHIData = squeeze(MPSHIData(MPSHIDay).ElectronFlux(:, MPSHIDay, :));
MPSHIYTickLabels = {MPSHIEnergyBins};
MPSHIYLimValues = [MPSHIEnergyBins(1), MPSHIEnergyBins(end)];
MPSHIYTickValues = MPSHIEnergyBins;


%Due to the difference between UTC and GPS time systems the data may have
%been taken during the previous day.  Let us remove any data that
%corresponds to the day before. This should only be a couple of data
%points.
datetimeTime = datetime(dt, 'ConvertFrom', 'datenum');
goodDayIndex = find(datetimeTime.Day == dayOfMonth);
SEEDTime = dt(goodDayIndex);

satellite = "GOES";
instrument = "MPS-HI";
plotType = "Spectrogram";
monthDay = info.startDayOfMonth + MPSHIDay - 1;
dateStr = [info.startYearStr, info.startMonthStr, ...
    num2str(monthDay, '%02d')];
doyStr = num2str(info.startDayOfYear + MPSHIDay, '%03d');

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

MPSHIFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

dVec = [info.startYear*ones(1, 25); info.startMonth*ones(1, 25); ...
    (info.startDayOfMonth + MPSHIDay - 1)*ones(1, 25); ...
    [0:24]; zeros(1, 25); zeros(1, 25)]';

xTickVals = datenum(dVec);

%Convert from the datetime structure into seconds from start of the day.
%Set up a vector of times to be interpolated onto.
tt = 0:60:86399;

%Create a vector of interpolated times in the form of datenums.  Imagesc
%does not seem to take datetimes as an input.  Matlab sucks.
interpTime = datenum(datetime(info.startYear, info.startMonth, ...
    info.startDayOfMonth + MPSHIDay - 1) + seconds(tt));

%We need to get rid of negative values in the MPSHIData array.
negativeIndex = find(MPSHIData < 0);
MPSHIData(negativeIndex) = 0.1;

%MPSHIEnergyBins = 1:10;
%MPSHIYTickValues = 1:10;
%MPSHIYLimValues  = [1, 10];

imagesc(interpTime, MPSHIEnergyBins, log10(MPSHIData))
xticks(xTickVals)
datetick('x', dateFormat, 'keepticks')
%set(gca, 'YScale','log');
ylabel('Energy (keV)')
xlabel('Hours (UTC)')
xlim([interpTime(1) interpTime(end)])
title(titStr)
caxis([3 5.5])
cb = colorbar;
ylabel(cb,'Log_{10}(Counts cm^{-2} s^{-1} keV^{-1} sr^{-1} )') 
set(gca,'YDir','normal');
ax.YTick = MPSHIYTickValues;
ax.YLim = MPSHIYLimValues;
ax.YTickLabel = MPSHIYTickLabels{1};
ax.FontSize = 8;

%hold on 
%for i = 2 : 10
%    plot([interpTime(1), interpTime(end)], ...
%        [log10(MPSHIEnergyBins(i)), log10(MPSHIEnergyBins(i))], 'r', 'LineWidth', 1.25)
%end

%Save the time series to a file.
saveas(fig1, MPSHIFileName);


end  %End of the function plotGOESSEEDSpectrogram.m
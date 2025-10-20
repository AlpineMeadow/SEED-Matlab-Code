function plotGOESData(info, MPS_HIData, CDFData)

%Now plot a spectrogram of the data.
%This functino is called by SEEDGOESSpaceWeatherMeeting.m and
%SEEDFirstLight.m

%First calculate the number of days in the MPS-HI data set.
numDaysGOES = length(MPS_HIData);

%Set up a variable that picks out the correct detector number.  As of right
%now this should be 4.  In talking with Juan it appears that the more
%correct detector should be detector #2 during quiet times and detector #5
%during disturbed times.
detectorNumber = 4;

%Set up a vector that holds the number of events per day for the SEED data.
numEventsPerDaySEED = zeros(2, numDaysGOES);

SEEDInterpolateCounts = zeros(904, 5760);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Concatinate the data for SEED and MPS-HI %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[numEnergyBins, ~] = size(info.energyBins);

%Set up a vector of times that are 15 seconds apart.
tt = 0.0:15.0:86399.0;
smoothConstant = 50;

%Let us concatinate the various variables.
for i = 1 : numDaysGOES

    if (i == 1)
        year = MPS_HIData(i).year;
        month = MPS_HIData(i).month;
        dayOfMonth = MPS_HIData(i).dayOfMonth;
        dayOfYear = MPS_HIData(i).dayOfYear;
        GOESTime = MPS_HIData(i).time;
        GOESElectronFlux = squeeze(MPS_HIData(i).ElectronFlux(:, detectorNumber, :));
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;
        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
        SEEDElectronCounts = CDFData(i).SEED_Electron_Counts_Dt15_Good;

        ttDatetime = datetime(SEEDTime,'ConvertFrom', 'datenum');

        %Convert from the datetime structure into seconds from start of the
        %day. 
        timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
            ttDatetime.Second;

        %Now we loop through the energy channels.
        for e = 1 : numEnergyBins
            y = double(SEEDElectronCounts(:, e));
            SEEDInterpolateCounts(e, :) = smoothdata(interp1(timeSeconds, ...
                y, tt, 'linear'), 'gaussian', smoothConstant);
        end

        % y = SEEDElectronCounts(startIndex : endIndex, e);
        % interpFlux(d*86400, e) = interp1(ts, y, tt, 'linear');


        numEventsPerDaySEED(1, 1) = 1;
        numEventsPerDaySEED(2, 1) = length(SEEDTime);

    else
        %Append the data onto the arrays.
        year = cat(1, year, MPS_HIData(i).year);
        month = cat(1, month, MPS_HIData(i).month);
        dayOfMonth = cat(1, dayOfMonth, MPS_HIData(i).dayOfMonth);
        dayOfYear = cat(1, dayOfYear, MPS_HIData(i).dayOfYear);
        GOESTime = cat(1, GOESTime, MPS_HIData(i).time);
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);
        numEventsPerDaySEED(1, i) = numEventsPerDaySEED(2, i - 1) + 1;
        numEventsPerDaySEED(2, i) = length(CDFData(i).SEED_Time_Dt15_Good);

        %For the MPS-HI electron flux we want to concatinate along the columns.
        GOESElectronFlux = cat(2, GOESElectronFlux, ...
            squeeze(MPS_HIData(i).ElectronFlux(:, detectorNumber, :)));

        %For the SEED electron flux we concatinate along the rows.
        SEEDElectronFlux = cat(1, SEEDElectronFlux, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good);

        %For the SEED electron counts we concatinate along the rows.
        SEEDElectronCounts = cat(1, SEEDElectronCounts, ...
            CDFData(i).SEED_Electron_Counts_Dt15_Good);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDaysGOES


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Let us handle the bad data values for the SEED data found between 2/21/23
%15:37:46 and 2/21/23 22:21:04
for e = 1 : 904
    for i = 13810 : 14302
        if SEEDElectronCounts(i, e) > 100
            SEEDElectronCounts(i, e) = 100;
        end
    end
end

%Interpolate the SEEDCount data into 5760 data points.
ttDatetime = datetime(SEEDTime,'ConvertFrom','datenum');

%Convert from the datetime structure into seconds from start of the day.
timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
    ttDatetime.Second;

%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;

%Set up an interpolated flux array of size [5760,904]
interpCounts = zeros(numDaysGOES*length(tt), 904);

%Now we loop through the energy channels.
% for e = 1 : 904
%     for d = 1 : length(numDaysGOES)
%         startIndex = numEventsPerDaySEED(1, d);
%         endIndex = numEventsPerDaySEED(2, d);
%         ts = timeSeconds(startIndex : endIndex);
%         y = double(SEEDElectronCounts(startIndex : endIndex, e));
%         interpFlux(d*86400, e) = smoothdata(interp1(ts, y, tt, 'linear'), ...
%             'gaussian', smoothConstant);
%     end
% end

%SEEDElectronCounts(SEEDElectronCounts > 100) = 100;

%Let us handle the data values that are missing.  MPS-HI writes missing data
%values as -9.9999+30.  I will convert these values to minimum flux values.
GOESElectronFlux(GOESElectronFlux <= 0) = 0.001;

%I do not know what system the time values are given in.  I will set all of
%the values to start from the starting day and then convert to date
%numbers.
GOESTime = GOESTime - GOESTime(1);

dt = datetime(year(1), month(1), dayOfMonth(1)) + seconds(GOESTime);

%Now convert to datenum values.
dt = datenum(dt);

%Set up the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 700];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Get the SEED energy bin values.
SEEDEnergyBins = info.energyBins(:, 2);

%The raw SEED data has 904 energy bins but we have added the energy bins
%together.  
newSEEDCounts = getSEEDEnergy(info, SEEDElectronCounts);
newSEEDFlux = getSEEDFlux4(info, SEEDTime, newSEEDCounts);

%Get the MPS-HI energy bins values.  There are 5 detectors and the energy
%bins are slightly different.  For this effort the differences will not
%matter but we are told that the 90 degree pitch angle detector is number
%4 so we will use that one.
GOESEnergyBins = log10(MPS_HIData(1).ElectronEnergy(:, 4));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  MPS-HI x and y tick labels and values  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yTickLabelsGOES = {num2str(MPS_HIData(1).ElectronEnergy(:, 1), '%5.1f')};
%Set the y limit values such that the first and last tickmarks are not
%exactly at the vertical edges.  Since we are doing log plotting we are not
%symmetrical.
yLimValuesGOES = [0.95*GOESEnergyBins(1), 1.01*GOESEnergyBins(end)];

yTickValuesGOES = GOESEnergyBins;

%Now set the time axis labels for the MPS-HI data.
xTGOES = {[40:1:58]};
xTickValuesGOES = zeros(1, numDaysGOES);
xTickLabelsGOES = cell(1, numDaysGOES);

for i = 1 : numDaysGOES
    xTickValuesGOES(i) = datenum(datetime(year(i), month(i), dayOfMonth(i), ...
        0, 0, 0));
    xTickLabelsGOES(i) = cellstr(char(datetime(xTickValuesGOES(i), ...
        'ConvertFrom', 'datenum')));
end

xLimValuesGOES = [dt(1), dt(end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  SEED x and y tick labels and values  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yTickLabelsSEED = {[20, 40, 60, 80, 100, 120, 140]};
yLimValuesSEED = [CDFData(1).SEED_Energy_Channels(info.startEnergyBinNumber), ...
    CDFData(1).SEED_Energy_Channels(end)];
yTickValuesSEED = [20, 40, 60, 80, 100, 120, 140];

%Now set the time axis labels for the SEED data.
xTickValuesSEED = zeros(1, numDaysGOES);
xTickLabelsSEED = cell(1, numDaysGOES);

for i = 1 : numDaysGOES
    xTickValuesSEED(i) = datenum(datetime(year(i), month(i), dayOfMonth(i), ...
        0, 0, 0));
    xTickLabelsSEED(i) = cellstr(char(datetime(xTickValuesSEED(i), ...
        'ConvertFrom', 'datenum')));
end

xLimValuesSEED = [SEEDTime(1), SEEDTime(end)];


dateFormat = 2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  Plot title and plot file name %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
satellite1 = "GOES";
instrument1 = "SEISS";

satellite2 = "STPSat-6";
instrument2 = "SEED";

plotType = "Spectrogram";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];

titStr1 = satellite1 + " " + instrument1 + " " + plotType + " " + dateStr + ...
    " " + doyStr;

titStr2 = satellite2 + " " + instrument2 + " " + plotType + " " + dateStr + ...
    " " + doyStr;


saveName = satellite1 + instrument1 + plotType + "_" + ...
    dateStr + "_" + doyStr;

GOESFileName = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Set up the figure size and location.
left = 0.1;
bottom = [0.56, 0.15];
width = 0.8;
height = 0.34;


sp1 = subplot(2, 1, 1);
imagesc(dt, GOESEnergyBins, log10(GOESElectronFlux))
xticklabels([]);
xticks(xTickValuesGOES);
%xlim(xLimValues);
%datetick('x', dateFormat)
ylabel('Energy (keV)');
caxis('auto')
caxis([-1 8])
title(titStr1);
cb1 = colorbar;
ylabel(cb1,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
yticks(yTickValuesGOES)
ylim(yLimValuesGOES)
yticklabels(yTickLabelsGOES)
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(2, 1, 2);
imagesc(SEEDTime, SEEDEnergyBins, log10(newSEEDFlux.deltat15FluxActual'))
%imagesc(SEEDTime, SEEDEnergyBins, newSEEDCounts')
xticklabels(xTickLabelsSEED);
xticks(xTickValuesSEED);
xlim(xLimValuesSEED);
ylabel('Energy (keV)');
%caxis('auto')
caxis([-1 8])
title(titStr2);
xlabel('Date');
cb2 = colorbar;
ylabel(cb2,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
yticks(yTickValuesSEED);
ylim(yLimValuesSEED);
yticklabels(yTickLabelsSEED);
set(sp2, 'Position', [left, bottom(2), width, height]);

%Save the time series to a file.
saveas(fig1, GOESFileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig2.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "GOES";
instrument = "MPS-HI";
plotType = "Flux";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), ...
    '%03d')];

titStr = satellite + " " + instrument + " " + "Flux Versus Time" + ...
    " " + dateStr + " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    "GOESSEEDComparison" + dateStr + "_" + doyStr;

GOESFileName1 = strcat('/SS1/STPSat-6/Plots/SpaceWeatherMeeting/', ...
    saveName, '.png');

%Energy1Str = ['MPS-HI Energy : ', num2str(energyBins(1), '%3.1f'), ' keV'];
%Energy2Str = ['MPS-HI Energy : ', num2str(energyBins(2), '%3.1f'), ' keV'];
Energy3Str = ['SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(407), '%3.1f'), ' keV'];
Energy4Str = ['SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(782), '%3.1f'), ' keV'];

dateFormat = 'DD';


%Let us add together a number of energy channels for the SEED data.
firstEnergyBin = 407;
secondEnergyBin = 782;
numChannelsToSum = 10;
halfRange = round(numChannelsToSum/2.0);
lowerBinNumber1 = firstEnergyBin - halfRange;
higherBinNumber1 = firstEnergyBin + halfRange;
lowerBinNumber2 = secondEnergyBin - halfRange;
higherBinNumber2 = secondEnergyBin + halfRange;

AverageSEEDElectronEnergy1 = sum(SEEDElectronFlux(:, lowerBinNumber1 : higherBinNumber1), ...
    2)/numChannelsToSum;
AverageSEEDElectronEnergy2 = sum(SEEDElectronFlux(:, lowerBinNumber2 : higherBinNumber2), ...
    2)/numChannelsToSum;


%Now lets try some smoothing.
smoothConstant = 10;

AverageSEEDElectronEnergy1 = smoothdata(AverageSEEDElectronEnergy1, ...
        'gaussian', smoothConstant);

% h = plot(dt, log10(GOESElectronFlux(1, :)), 'b', ...
%     dt, log10(GOESElectronFlux(2, :)), 'g', ...
%     SEEDTime, log10(AverageSEEDElectronEnergy1), 'r', ...
%     SEEDTime, log10(AverageSEEDElectronEnergy2), 'black');
h = plot(dt, log10(GOESElectronFlux(1, :)), 'b', ...
    SEEDTime, log10(AverageSEEDElectronEnergy1), 'g');
datetick('x', dateFormat)
set(h(1),'linewidth', 2);
set(h(2),'linewidth', 2);
%legend(Energy1Str, Energy2Str, Energy3Str, Energy4Str)
%legend(Energy1Str, Energy3Str)
%set(h(3),'linewidth', 1.4);
%set(h(4),'linewidth', 1.4);
ylabel('log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
title(titStr);
ylim([0 7])
xlabel('Day Of Year for 2023');
%ax.XTickLabel = xTickLabels;
%ax.XTick = xTickValues;
%ax.XLim = xLimValues;


%Save the time series to a file.
saveas(fig2, GOESFileName1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig3 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig3.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "GOES";
instrument = "SEISS";
plotType = "FluxRatio";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];

titStr = satellite + " " + instrument + " " + "Ratio of Flux Versus Time" + " " + dateStr + ...
    " " + doyStr;
titStr = "Ratio of " + satellite + " " + instrument + ...
    " Over SEED Flux Versus Time" + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + "GOESSEEDFluxRatio" + ...
    dateStr + "_" + doyStr;

GOESFileName3 = strcat('/SS1/STPSat-6/Plots/SpaceWeatherMeeting/', saveName, '.png');

%Energy1Str = ['Energy : ', num2str(energyBins(1), '%3.1f'), ' keV'];
%Energy2Str = ['Energy : ', num2str(energyBins(2), '%3.1f'), ' keV'];


dateFormat = 'DD';


%Let us add together a number of energy channels for the SEED data.
firstEnergyBin = 407;
secondEnergyBin = 782;
numChannelsToSum = 10;
halfRange = round(numChannelsToSum/2.0);
lowerBinNumber1 = firstEnergyBin - halfRange;
higherBinNumber1 = firstEnergyBin + halfRange;
lowerBinNumber2 = secondEnergyBin - halfRange;
higherBinNumber2 = secondEnergyBin + halfRange;

AverageSEEDElectronEnergy1 = sum(SEEDElectronFlux(:, lowerBinNumber1 : higherBinNumber1), ...
    2)/numChannelsToSum;
AverageSEEDElectronEnergy2 = sum(SEEDElectronFlux(:, lowerBinNumber2 : higherBinNumber2), ...
    2)/numChannelsToSum;


%In order to take the ratio of the two data sets I will have to interpolate
%the SEED data so as to have the same number of data points.

%Set up the vector of times that the SEED data will be interpolated into.
tt = 0:60:5*86399;

smoothConstant = 50;
SEEDTime = 86400*(SEEDTime - SEEDTime(1));

%Now we loop through the energy channels.
y1 = AverageSEEDElectronEnergy1;
y2 = AverageSEEDElectronEnergy2;

interpSEEDFlux1 = smoothdata(interp1(SEEDTime - SEEDTime(1), y1, tt, 'linear'), ...
    'gaussian', smoothConstant);
interpSEEDFlux2 = smoothdata(interp1(SEEDTime - SEEDTime(1), y2, tt, 'linear'), ...
    'gaussian', smoothConstant);

%Now let us find the ratio of the two data sets.
FluxRatio1 = squeeze(GOESElectronFlux(1, :))./interpSEEDFlux1;
FluxRatio2 = squeeze(GOESElectronFlux(2, :))./interpSEEDFlux2;


h = plot(dt, FluxRatio1, 'b', dt, FluxRatio2, 'g');
datetick('x', dateFormat)
set(h(1),'linewidth', 2);
%legend(Energy1Str, Energy2Str)
ylabel('Ratio of MPS-HI Flux Over SEED Flux');
title(titStr);
ylim([0 7])
xlabel('Day Of Year for 2023');
ax.XTickLabel = xTickLabels;
ax.XTick = xTickValues;
ax.XLim = xLimValues;


%Save the time series to a file.
saveas(fig3, GOESFileName3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fig4 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig4.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "GOES";
instrument = "SEISS";
plotType = "FluxRatioScatter";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
doyStr = [num2str(dayOfYear(1), '%03d'), '-', ...
    num2str(dayOfYear(end), '%03d')];

titStr = satellite + " " + instrument + " " + ...
    "Ratio of Flux Versus SEED Flux" + " " + dateStr + " " + doyStr;
titStr = "Ratio of " + satellite + " " + instrument + ...
    " Over SEED Flux Versus SEED Flux" + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    "GOESSEEDFluxRatioScatter" + dateStr + "_" + doyStr;

GOESFileName4 = strcat('/SS1/STPSat-6/Plots/SpaceWeatherMeeting/', ...
    saveName, '.png');

Energy1Str = ['Energy : ', num2str(energyBins(1), '%3.1f'), ' keV'];
Energy2Str = ['Energy : ', num2str(energyBins(2), '%3.1f'), ' keV'];

%Let us add together a number of energy channels for the SEED data.
firstEnergyBin = 407;
secondEnergyBin = 782;
numChannelsToSum = 10;
halfRange = round(numChannelsToSum/2.0);
lowerBinNumber1 = firstEnergyBin - halfRange;
higherBinNumber1 = firstEnergyBin + halfRange;
lowerBinNumber2 = secondEnergyBin - halfRange;
higherBinNumber2 = secondEnergyBin + halfRange;

AverageSEEDElectronEnergy1 = sum(SEEDElectronFlux(:, ...
    lowerBinNumber1 : higherBinNumber1), 2)/numChannelsToSum;
AverageSEEDElectronEnergy2 = sum(SEEDElectronFlux(:, ...
    lowerBinNumber2 : higherBinNumber2), 2)/numChannelsToSum;

%Set the figure width and height and x position.  
numSubplots = 2;
[left, width, height, bottom] = getSubplotPositions(numSubplots);

%In order to take the ratio of the two data sets I will have to interpolate
%the SEED data so as to have the same number of data points.

%Set up the vector of times that the SEED data will be interpolated into.
tt = 0:60:5*86399;

smoothConstant = 50;
SEEDTime = 86400*(SEEDTime - SEEDTime(1));

%Now we loop through the energy channels.
y1 = AverageSEEDElectronEnergy1;
y2 = AverageSEEDElectronEnergy2;

interpSEEDFlux1 = smoothdata(interp1(SEEDTime - SEEDTime(1), y1, tt, ...
    'linear'), 'gaussian', smoothConstant);
interpSEEDFlux2 = smoothdata(interp1(SEEDTime - SEEDTime(1), y2, tt, ...
    'linear'), 'gaussian', smoothConstant);

%Now let us find the ratio of the two data sets.
FluxRatio1 = squeeze(GOESElectronFlux(1, :))./interpSEEDFlux1;
FluxRatio2 = squeeze(GOESElectronFlux(2, :))./interpSEEDFlux2;

bottom = [0.55, 0.1];
height = 0.35;

sp1 = subplot(numSubplots, 1, 1);
scatter(interpSEEDFlux1, FluxRatio1, 'b');
%ylabel('Ratio of MPS-HI Flux Over SEED Flux');
title(titStr);
xlabel('SEED Flux');
set(sp1, 'Position', [left, bottom(1), width, height]);
text('Units', 'Normalized', 'Position', [0.7, 0.8], 'string', Energy1Str, ...
      'FontSize', 15);


sp2 = subplot(numSubplots, 1, 2);
scatter(interpSEEDFlux2, FluxRatio2, 'bo');
ylabel('                                            Ratio of MPS-HI Flux Over SEED Flux');
xlabel('SEED Flux');
set(sp2, 'Position', [left, bottom(2), width, height]);
text('Units', 'Normalized', 'Position', [0.7, 0.8], 'string', Energy2Str, ...
      'FontSize', 15);


%Save the time series to a file.
saveas(fig4, GOESFileName3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




end  %End of the function plotGOESData.m
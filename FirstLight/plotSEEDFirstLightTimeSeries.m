function plotSEEDFirstLightTimeSeries(info, CDFInfo, CDFData)


%Now plot a time series of the data.
%This function is called by SEEDFirstLight.m

%Convert mission day of year into year, month and day of month.
%[year, month, dayOfMonth] = MDNToMonthDay(info, missionDayOfYear);
%[dayOfYear, year] = MDNToDN(info, missionDayOfYear);

%First calculate the number of days in the GOES data set.
numDays = length(CDFData);


%Let us concatinate the various variables.
for i = 1 : numDays

    if (i == 1)
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;
        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
    else
        %Append the data onto the arrays.
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);
        SEEDElectronFlux = cat(1, SEEDElectronFlux, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDays

%Separate out the various parts of the datetime vector.
dt = datetime(SEEDTime, 'ConvertFrom', 'datenum');  
year = dt.Year;
month = dt.Month;
dayOfMonth = dt.Day;
missionDayNumber = MonthDayToMDN(info, month, dayOfMonth, year);
dayOfYear = MDNToDN(info, missionDayNumber);

%Set up the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];


%yTickLabels = {num2str(energyBins, '%5.1f')};
%yLimValues = [energyBins(1), energyBins(end)];
%yTickValues = energyBins;

%xTickLabels = {[54, 55, 56, 57, 58]};
%xTickValues = [datenum(datetime(year(1), month(1), dayOfMonth(1))), ...
%     datenum(datetime(year(2), month(2), dayOfMonth(2))), ...
%     datenum(datetime(year(3), month(3), dayOfMonth(3))), ...
%     datenum(datetime(year(4), month(4), dayOfMonth(4))), ...
%     datenum(datetime(year(5), month(5), dayOfMonth(5)))];
% 
% xLimValues = [dt(1), dt(end)];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "STPSat-6";
instrument = "SEED";
plotType = "TimeSeries";

if numDays == 1 
    dateStr = [num2str(year), num2str(month, '%02d'), ...
        num2str(dayOfMonth, '%02d')];
    doyStr = num2str(dayOfYear, '%03d');
else
    dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
        num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
    doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];
end


titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

SEEDFileName = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');


dateFormat = 'HH';


% %Let us add together a number of energy channels for the SEED data.
% firstEnergyBin = 407;
% secondEnergyBin = 782;
% numChannelsToSum = 10;
% halfRange = round(numChannelsToSum/2.0);
% lowerBinNumber1 = firstEnergyBin - halfRange;
% higherBinNumber1 = firstEnergyBin + halfRange;
% lowerBinNumber2 = secondEnergyBin - halfRange;
% higherBinNumber2 = secondEnergyBin + halfRange;
% 
% AverageSEEDElectronEnergy1 = sum(SEEDElectronFlux(:, lowerBinNumber1 : higherBinNumber1), ...
%     2)/numChannelsToSum;
% AverageSEEDElectronEnergy2 = sum(SEEDElectronFlux(:, lowerBinNumber2 : higherBinNumber2), ...
%     2)/numChannelsToSum;
% 
% 
% %Now lets try some smoothing.
% smoothConstant = 10;
% 
% AverageSEEDElectronEnergy1 = smoothdata(AverageSEEDElectronEnergy1, ...
%         'gaussian', smoothConstant);

%Choose some energy bins for the injection analysis.
energyBin1 = 10;
energyBin2 = 50;

Energy1Str = ['SEED Energy : ', num2str(CDFData(1).SEED_Energy_Channels(energyBin1), ...
    '%3.1f'), ' keV'];
Energy2Str = ['SEED Energy : ', num2str(CDFData(1).SEED_Energy_Channels(energyBin2), ...
    '%3.1f'), ' keV'];

%Let us use a sliding average technique to find the points in time when an
%injection occurs.

%Choose a sigma value. This value will set the number of standard
%deviations beyond the mean at which we assert that an injection occured.
sigmaValue = 3.0;

%Next we choose the number of intervals to look forward in order to find an
%injection.
stepsToSkip = 5;

%Next choose the size of the sliding window over which to run the data.
slidingAverageLength = 25;

[saBoundaries, slidingInjectionIndex1] = getSlidingInjectionIndex(SEEDElectronFlux, ...
    energyBin1, sigmaValue, stepsToSkip, slidingAverageLength, dt);


%Now try to use a moving average instead of a sliding average.  Seems like
%these should return the same result but this may be more sensitive to the
%data.
stepsToSkip = 15;
movingInjectionIndex1 = getMovingInjectionIndex(SEEDElectronFlux, ...
    energyBin1, sigmaValue, stepsToSkip, slidingAverageLength, dt);

hold on;

% h = plot(dt, SEEDElectronFlux(:, energyBin1), 'b', ...
%     dt, SEEDElectronFlux(:, energyBin2), 'black', ...
%     dt(raBoundaries(1, injectionIndex) + fix(runningAverageLength/2)), ...
%     SEEDElectronFlux(raBoundaries(1, injectionIndex), energyBin1), 'b*', ...
%     dt(raBoundaries(1, injectionIndex) + fix(runningAverageLength/2)), ...
%     SEEDElectronFlux(raBoundaries(1, injectionIndex), energyBin2), 'black*');

h1 = plot(dt, SEEDElectronFlux(:, energyBin1), 'b', ...
    dt, SEEDElectronFlux(:, energyBin2), 'black');

%    dt(raBoundaries(1, injectionIndex2)), raFlux2(injectionIndex2), 'r*', ...
%h2 = plot(dt(raBoundaries(1, injectionIndex1)), raFlux1(injectionIndex1), 'r*', ...
h2 = plot(dt(slidingInjectionIndex1), ...
    SEEDElectronFlux(slidingInjectionIndex1, energyBin1), 'y*');

%Set a flag for whether to plot the intervals and the standard deviation of
%the mean flux value for each interval.
plotIntervalsError = 0;

if plotIntervalsError == 1
    for i = 1 : numDataChunks
        yyy = plot(ax, [dt(saBoundaries(1, i)), dt(saBoundaries(1, i))], ...
            [raFlux1(i) + stdFlux1(i), raFlux1(i) - stdFlux1(i)], 'g', ...
            [dt(saBoundaries(1, i)), dt(saBoundaries(2, i))], ...
            [raFlux1(i), raFlux1(i)], 'g', ...
            [dt(saBoundaries(2, i)), dt(saBoundaries(2, i))], ...
            [raFlux1(i) + stdFlux1(i), raFlux1(i) - stdFlux1(i)], 'g');
        zzz = plot(ax, [dt(saBoundaries(1, i)), dt(saBoundaries(1, i))], ...
            [raFlux2(i) + stdFlux2(i), raFlux2(i) - stdFlux2(i)], 'r', ...
            [dt(saBoundaries(1, i)), dt(saBoundaries(2, i))], ...
            [raFlux2(i), raFlux2(i)], 'r', ...
            [dt(saBoundaries(2, i)), dt(saBoundaries(2, i))], ...
            [raFlux2(i) + stdFlux2(i), raFlux2(i) - stdFlux2(i)], 'r');
    end
end  %End of if statement - if plotIntervalsError

datetick('x', dateFormat)
set(h1(1),'linewidth', 1.3);
set(h1(2),'linewidth', 1.3);
% set(yyy(1), 'linewidth', 1.3);
% set(yyy(2), 'linewidth', 1.3);
% set(yyy(3), 'linewidth', 1.3);
% set(zzz(1), 'linewidth', 1.3);
% set(zzz(2), 'linewidth', 1.3);
% set(zzz(3), 'linewidth', 1.3);
%set(h(2),'linewidth', 1.3);
legend(h1, Energy1Str, Energy2Str)
ylabel('log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
title(titStr);
xlabel('Hours (UTC)');

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

Energy1Str = ['Energy : ', num2str(energyBins(1), '%3.1f'), ' keV'];
Energy2Str = ['Energy : ', num2str(energyBins(2), '%3.1f'), ' keV'];


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
legend(Energy1Str, Energy2Str)
ylabel('Ratio of GOES Flux Over SEED Flux');
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
doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];

titStr = satellite + " " + instrument + " " + "Ratio of Flux Versus SEED Flux" + " " + dateStr + ...
    " " + doyStr;
titStr = "Ratio of " + satellite + " " + instrument + ...
    " Over SEED Flux Versus SEED Flux" + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + "GOESSEEDFluxRatioScatter" + ...
    dateStr + "_" + doyStr;

GOESFileName4 = strcat('/SS1/STPSat-6/Plots/SpaceWeatherMeeting/', saveName, '.png');

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

AverageSEEDElectronEnergy1 = sum(SEEDElectronFlux(:, lowerBinNumber1 : higherBinNumber1), ...
    2)/numChannelsToSum;
AverageSEEDElectronEnergy2 = sum(SEEDElectronFlux(:, lowerBinNumber2 : higherBinNumber2), ...
    2)/numChannelsToSum;

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

interpSEEDFlux1 = smoothdata(interp1(SEEDTime - SEEDTime(1), y1, tt, 'linear'), ...
    'gaussian', smoothConstant);
interpSEEDFlux2 = smoothdata(interp1(SEEDTime - SEEDTime(1), y2, tt, 'linear'), ...
    'gaussian', smoothConstant);

%Now let us find the ratio of the two data sets.
FluxRatio1 = squeeze(GOESElectronFlux(1, :))./interpSEEDFlux1;
FluxRatio2 = squeeze(GOESElectronFlux(2, :))./interpSEEDFlux2;

bottom = [0.55, 0.1];
height = 0.35;

sp1 = subplot(numSubplots, 1, 1);
scatter(interpSEEDFlux1, FluxRatio1, 'b');
%ylabel('Ratio of GOES Flux Over SEED Flux');
title(titStr);
xlabel('SEED Flux');
set(sp1, 'Position', [left, bottom(1), width, height]);
text('Units', 'Normalized', 'Position', [0.7, 0.8], 'string', Energy1Str, ...
      'FontSize', 15);


sp2 = subplot(numSubplots, 1, 2);
scatter(interpSEEDFlux2, FluxRatio2, 'bo');
ylabel('                                            Ratio of GOES Flux Over SEED Flux');
xlabel('SEED Flux');
set(sp2, 'Position', [left, bottom(2), width, height]);
text('Units', 'Normalized', 'Position', [0.7, 0.8], 'string', Energy2Str, ...
      'FontSize', 15);


%Save the time series to a file.
saveas(fig4, GOESFileName3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end  %End of the function plotSEEDFirstLightTimeSeries.m
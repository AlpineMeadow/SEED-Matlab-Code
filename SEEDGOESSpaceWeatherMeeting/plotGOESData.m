function plotGOESData(info, GOESData, CDFData)

%Now plot a spectrogram of the data.
%This functino is called by SEEDGOESSpaceWeatherMeeting.m

%Convert mission day of year into year, month and day of month.
%[year, month, dayOfMonth] = MDNToMonthDay(info, missionDayOfYear);
%[dayOfYear, year] = MDNToDN(info, missionDayOfYear);

%First calculate the number of days in the GOES data set.
numDays = length(GOESData);

%Set up a variable that picks out the correct detector number.  As of right
%now this should be 4.
detectorNumber = 4;

%Let us concatinate the various variables.
for i = 1 : numDays

    if (i == 1)
        year = GOESData(i).year;
        month = GOESData(i).month;
        dayOfMonth = GOESData(i).dayOfMonth;
        dayOfYear = GOESData(i).dayOfYear;
        GOESTime = GOESData(i).time;
        GOESElectronFlux = squeeze(GOESData(i).ElectronFlux(:, detectorNumber, :));
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;
        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
    else
        %Append the data onto the arrays.
        year = cat(1, year, GOESData(i).year);
        month = cat(1, month, GOESData(i).month);
        dayOfMonth = cat(1, dayOfMonth, GOESData(i).dayOfMonth);
        dayOfYear = cat(1, dayOfYear, GOESData(i).dayOfYear);
        GOESTime = cat(1, GOESTime, GOESData(i).time);
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);

        %For the GOES electron flux we want to concatinate along the columns.
        GOESElectronFlux = cat(2, GOESElectronFlux, ...
            squeeze(GOESData(i).ElectronFlux(:, detectorNumber, :)));

        %For the SEED electron flux we concatinate along the rows.
        SEEDElectronFlux = cat(1, SEEDElectronFlux, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDays

%Let us handle the data values that are missing.  GOES writes missing data
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
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Get the GOES energy bins values.  There are 5 detectors and the energy
%bins are slightly different.  For this effort the differences will not
%matter, especially since we do not know which of the 5 detectors
%corresponds to the SEED detector.
energyBins = GOESData(1).ElectronEnergy(:, 1);

yTickLabels = {num2str(energyBins, '%5.1f')};
yLimValues = [energyBins(1), energyBins(end)];
yTickValues = energyBins;

xTickLabels = {[54, 55, 56, 57, 58]};
xTickValues = [datenum(datetime(year(1), month(1), dayOfMonth(1))), ...
    datenum(datetime(year(2), month(2), dayOfMonth(2))), ...
    datenum(datetime(year(3), month(3), dayOfMonth(3))), ...
    datenum(datetime(year(4), month(4), dayOfMonth(4))), ...
    datenum(datetime(year(5), month(5), dayOfMonth(5)))];

xLimValues = [dt(1), dt(end)];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "GOES";
instrument = "SEISS";
plotType = "Spectrogram";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

GOESFileName = strcat('/SS1/STPSat-6/Plots/SpaceWeatherMeeting/', saveName, '.png');


imagesc(dt, energyBins, log10(GOESElectronFlux))
caxis('auto')
datetick('x', dateFormat)
ylabel('Energy (keV)');
title(titStr);
xlabel('Day Of Year for 2023');
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;
ax.XTickLabel = xTickLabels;
ax.XTick = xTickValues;
ax.XLim = xLimValues;

%Create a flag to determine if we will plot the local time on the x-axis.
ltAxis = 2;

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
saveas(fig1, GOESFileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig2.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "GOES";
instrument = "SEISS";
plotType = "Flux";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];

titStr = satellite + " " + instrument + " " + "Flux Versus Time" + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + "GOESSEEDComparison" + ...
    dateStr + "_" + doyStr;

GOESFileName1 = strcat('/SS1/STPSat-6/Plots/SpaceWeatherMeeting/', saveName, '.png');

Energy1Str = ['GOES Energy : ', num2str(energyBins(1), '%3.1f'), ' keV'];
Energy2Str = ['GOES Energy : ', num2str(energyBins(2), '%3.1f'), ' keV'];
Energy3Str = ['SEED Energy : ', num2str(CDFData(1).SEED_Energy_Channels(407), '%3.1f'), ' keV'];
Energy4Str = ['SEED Energy : ', num2str(CDFData(1).SEED_Energy_Channels(782), '%3.1f'), ' keV'];

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
legend(Energy1Str, Energy3Str)
%set(h(3),'linewidth', 1.4);
%set(h(4),'linewidth', 1.4);
ylabel('log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
title(titStr);
ylim([0 7])
xlabel('Day Of Year for 2023');
ax.XTickLabel = xTickLabels;
ax.XTick = xTickValues;
ax.XLim = xLimValues;


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




end  %End of the function plotGOESData.m
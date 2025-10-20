function compareSEEDToGOES(info, CDFData, GOESData)

%This function will compare the SEED data set to the GOES data set.  We can
%only do this for a few different energy channels.

GOESTime = GOESData.time;
GOESElectronFlux = GOESData.ElectronFlux;
GOESElectronFluxSigma = GOESData.ElectronFluxUncertainty;
GOESEnergyBins = GOESData.ElectronEnergy;
GOESIntegratedElectronFlux = GOESData.AvgIntElectronFlux;
GOESIntegratedElectronFluxSigma = GOESData.AvgIntElectronFluxUncertainty;


%Make a title for the plot as well as the file.
satellite = "STPSat6-SEED";
instrument = "GOES-MPS-HI";
plotType = "Flux Comparison";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName1 = satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + "Energy_1";
saveName2 = satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + "Energy_2";

fig1FileName1 = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName1, '.png');
fig2FileName2 = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName2, '.png');



fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Lets convert the GOES time to matlab datetime values.
GOEStime = GOESTime - GOESTime(1);
GOESDateTime = datetime(info.startYear, info.startMonth, info.startDayOfMonth) + ...
    seconds(GOEStime);

%Lets convert the CDF datenum times to datetime values.
SEEDDateTime = datetime(CDFData.SEED_Time_Dt15_Good, 'ConvertFrom', 'datenum');

%Lets find the energy channels that match up between the GOES and SEED
%data.  We will use only the first three energy channels from the GOES
%data.  The GOES energy bins are slightly different for the 5 different
%detectors but I am just going to assume that they are the same no matter
%what detector I look at.  Eventually I will only be looking at one
%detector anyway.
GOESEnergyBin1 = GOESEnergyBins(1,1);
GOESEnergyBin2 = GOESEnergyBins(2,1);

%Set out the SEED energy bins.
SEEDEnergyChannels = CDFData.SEED_Energy_Channels;

%Find the closest SEED energy bin to the GOES energy bin.  Just use the
%first index in the array.
SEEDEnergyBin1Index = find(SEEDEnergyChannels >= GOESEnergyBin1);
SEEDEnergyBin1Index = SEEDEnergyBin1Index(1);

SEEDEnergyBin2Index = find(SEEDEnergyChannels >= GOESEnergyBin2);
SEEDEnergyBin2Index = SEEDEnergyBin2Index(1);

%Set the figure width and height and x position.
left = 0.1;
width = 0.8;
height = 0.15;
bottom = [0.78, 0.62, 0.46, 0.30, 0.14];

%Make some legend strings.
GOESEnergy1Str = ['GOES Energy : ', num2str(GOESEnergyBin1, '%5.2f'), ' keV'];
GOESEnergy2Str = ['GOES Energy : ', num2str(GOESEnergyBin2, '%5.2f'), ' keV'];
SEEDEnergy1Str = ['SEED Energy : ', ...
    num2str(SEEDEnergyChannels(SEEDEnergyBin1Index), '%5.2f'), ' keV'];
SEEDEnergy2Str = ['SEED Energy : ', ...
    num2str(SEEDEnergyChannels(SEEDEnergyBin2Index), '%5.2f'), ' keV'];

%Set up the GOES data to be plotted.
GOESEnergy1Detector4 = squeeze(GOESElectronFlux(1, 4, :));
GOESEnergy2Detector4 = squeeze(GOESElectronFlux(2, 4, :));

%It is possible that there are missing data.  When the data are missing
%they are filled with -9.999999e+30.  Lets get rid of these data.
GOESEnergy1Detector4 = GOESRemoveMissingData(GOESEnergy1Detector4);
GOESEnergy2Detector4 = GOESRemoveMissingData(GOESEnergy2Detector4);
 

dateFormat = 'HH';

%Set up the x-axis tick values.
xT = 3600*[3,6,9,12,15,18,21,24];
xT = [1, xT];
xTicks = datetime(info.startYear, info.startMonth, info.startDayOfMonth) + ...
    seconds(xT);

plot(GOESDateTime, log10(GOESEnergy1Detector4), 'b', ...
    SEEDDateTime, ...
    log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin1Index)), 'g')
legend(GOESEnergy1Str, SEEDEnergy1Str)
xticks(xTicks)
title(titStr)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 4', ...
    'FontSize', 15);
xlabel('Time (UTC)')
xlim([xTicks(1) xTicks(end)])


% %Now make a plot comparing the two instruments.
% sp1 = subplot(5, 1, 1);
% plot(GOESDateTime, log10(GOESEnergy1Detector1), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin1Index)+1), 'g')
% legend(GOESEnergy1Str, SEEDEnergy1Str)
% title(titStr)
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 1', ...
%     'FontSize', 15);
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% set(gca, 'Xticklabel', []);
% set(sp1, 'Position', [left, bottom(1), width, height]);
% 
% sp2 = subplot(5, 1, 2);
% plot(GOESDateTime, log10(GOESEnergy1Detector2), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin1Index)), 'g')
% legend(GOESEnergy1Str, SEEDEnergy1Str)
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 2', ...
%     'FontSize', 15);
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% set(gca, 'Xticklabel', []);
% set(sp2, 'Position', [left, bottom(2), width, height]);
% 
% sp3 = subplot(5, 1, 3);
% plot(GOESDateTime, log10(GOESEnergy1Detector3), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin1Index)), 'g')
% legend(GOESEnergy1Str, SEEDEnergy1Str)
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 3', ...
%     'FontSize', 15);
% ylabel('Flux (Counts cm^{-2} s^{-1} ster^{-1} keV^{-1})')
% set(sp3, 'Position', [left, bottom(3), width, height]);
% set(gca, 'Xticklabel', []);
% 
% sp4 = subplot(5, 1, 4);
% plot(GOESDateTime, log10(GOESEnergy1Detector4), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin1Index)), 'g')
% legend(GOESEnergy1Str, SEEDEnergy1Str)
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 4', ...
%     'FontSize', 15);
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% set(sp4, 'Position', [left, bottom(4), width, height]);
% set(gca, 'Xticklabel', []);
% 
% sp5 = subplot(5, 1, 5);
% plot(GOESDateTime, log10(GOESEnergy1Detector5), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin1Index)), 'g')
% legend(GOESEnergy1Str, SEEDEnergy1Str)
% xticks(xTicks)
% datetick('x', dateFormat, 'keeplimits', 'keepticks')
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 5', ...
%     'FontSize', 15);
% xlabel('Time')
% xlim([xTicks(1) xTicks(end)])
% set(sp5, 'Position', [left, bottom(5), width, height]);

%Save the spectra to a file.
saveas(fig1, fig1FileName1);

fig2 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig2.Position = [750 25 1200 500];

%Now make a plot comparing the two instruments.
plot(GOESDateTime, log10(GOESEnergy2Detector4), 'b', SEEDDateTime, ...
    log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin2Index)), 'g')
legend(GOESEnergy2Str, SEEDEnergy2Str)
xticks(xTicks)
title(titStr)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 4', ...
    'FontSize', 15);
xlabel('Time (UTC)')
xlim([xTicks(1) xTicks(end)])


% sp2 = subplot(5, 1, 2);
% plot(GOESDateTime, log10(GOESEnergy2Detector2), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin2Index)), 'g')
% legend(GOESEnergy2Str, SEEDEnergy2Str)
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 2', ...
%     'FontSize', 15);
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% set(gca, 'Xticklabel', []);
% set(sp2, 'Position', [left, bottom(2), width, height]);
% 
% sp3 = subplot(5, 1, 3);
% plot(GOESDateTime, log10(GOESEnergy2Detector3), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin2Index)), 'g')
% legend(GOESEnergy2Str, SEEDEnergy2Str)
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 3', ...
%     'FontSize', 15);
% ylabel('Flux (Counts cm^{-2} s^{-1} ster^{-1} keV^{-1})')
% set(sp3, 'Position', [left, bottom(3), width, height]);
% set(gca, 'Xticklabel', []);
% 
% sp4 = subplot(5, 1, 4);
% plot(GOESDateTime, log10(GOESEnergy2Detector4), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin2Index)), 'g')
% legend(GOESEnergy2Str, SEEDEnergy2Str)
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 4', ...
%     'FontSize', 15);
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% set(sp4, 'Position', [left, bottom(4), width, height]);
% set(gca, 'Xticklabel', []);
% 
% sp5 = subplot(5, 1, 5);
% plot(GOESDateTime, log10(GOESEnergy2Detector5), 'b', ...
%     SEEDDateTime, log10(CDFData.SEED_Electron_Flux_Dt15_Good(:, SEEDEnergyBin2Index)), 'g')
% legend(GOESEnergy2Str, SEEDEnergy2Str)
% xticks(xTicks)
% datetick('x', dateFormat, 'keeplimits', 'keepticks')
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Detector 5', ...
%     'FontSize', 15);
% xlabel('Time')
% xlim([SEEDDateTime(1) SEEDDateTime(end)])
% set(sp5, 'Position', [left, bottom(5), width, height]);

%Save the spectra to a file.
saveas(fig2, fig2FileName2);


end  %End of the function compareSEEDToGOESData.m
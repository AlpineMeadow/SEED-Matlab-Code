function makeGOESSpectra(info, GOESData)

time = GOESData.time;
electronFlux = GOESData.ElectronFlux;
electronFluxSigma = GOESData.ElectronFluxUncertainty;
GOESEnergyBins = GOESData.ElectronEnergy;
GOESIntegratedElectronFlux = GOESData.AvgIntElectronFlux;
GOESIntegratedElectronFluxSigma = GOESData.AvgIntElectronFluxUncertainty;


%Make a title for the plot as well as the file.
satellite = "GOES";
instrument = "MPS-HI";
plotType = "Energy Spectra";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + info.startHourStr + "_" + info.endHourStr;

fig1FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Lets convert the time to matlab datenum values.
time = time - time(1);
d = datetime(info.startYear, info.startMonth, info.startDayOfMonth) + ...
    seconds(time);


%Save the spectra to a file.
%saveas(fig1, fig1FileName);


end  %End of the function makeGoesSpectra.m
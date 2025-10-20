function plotMPSHISEEDTimeSeries(plotStructure, dt, MPSHIElectronFlux, ...
    detectorNumber, savePDF, averageSEEDEnergy1, averageSEEDEnergy2, ...
    weightedSEEDEnergy1, weightedSEEDEnergy2)

%This function is called by plotGOESData.m  It will make a plot for the
%first light paper. It will plot the GOES and SEED time series.

satellite = plotStructure.satellite;
instrument = plotStructure.instrument;
dateStr = plotStructure.dateStr;
doyStr = plotStructure.doyStr;
plotType = 'TimeSeries';

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

titStr = satellite + " " + instrument + " " + ...
    "and STP Sat-6 SEED Flux Versus Time" + " " + dateStr + " " + doyStr;

saveName = "Weighted" + satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr + "_" + num2str(detectorNumber);

%Let us find the day ends.  First convert the datenum values into datetime
%values.
dates = datetime(dt, 'ConvertFrom', 'datenum');

sp1 = subplot(2, 1, 1);
h1 = plot(dt, log10(MPSHIElectronFlux(1, :)), 'b', ...
    dt, log10(weightedSEEDEnergy1), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h1(1),'linewidth', 1);
legend('MPS-HI - 73.1 keV', 'Weighted SEED - 73.1 keV', ...
'Location', 'southwest')
ylabel('log_{10}(Counts/s keV sr cm^{2})', 'FontSize', 11);
%title(titStr);
ylim([3 6.5])

sp2 = subplot(2, 1, 2);
h2 = plot(dt, log10(MPSHIElectronFlux(2, :)), 'b', ...
    dt, log10(weightedSEEDEnergy2), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h2(1),'linewidth', 1);
legend('MPS-HI - 129.2 keV', 'Weighted SEED - 129.2 keV', ...
    'Location', 'southwest')
ylabel('log_{10}(Counts/s keV sr cm^{2})', 'FontSize', 11);
ylim([2.5 5.5])

if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end %End of if-else clause - if savePDF

end  %End of the function plotMPSHISEEDTimeSeries.m
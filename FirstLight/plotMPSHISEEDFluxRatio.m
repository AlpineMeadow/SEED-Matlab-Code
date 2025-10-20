function plotMPSHISEEDFluxRatio(plotStructure, dt, MPSHIElectronFlux, ...
     averageSEEDEnergy1, averageSEEDEnergy2, ...
     weightedSEEDEnergy1, weightedSEEDEnergy2, detectorNumber, savePDF)

%This function is called by plotGOESData.m. It will make a plot for the
%first light paper. It will plot the ratio of the GOES and SEED time series.

satellite = plotStructure.satellite;
instrument = plotStructure.instrument;
dateStr = plotStructure.dateStr;
doyStr = plotStructure.doyStr;
plotType = 'FluxRatio';

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

titStr = "Ratio of " + satellite + " " + instrument + ...
    " Over SEED Flux Versus Time" + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr + "_" + num2str(detectorNumber);

%Now let us find the ratio of the two data sets.
averageFluxRatio1 = squeeze(MPSHIElectronFlux(1, :))./averageSEEDEnergy1';
averageFluxRatio2 = squeeze(MPSHIElectronFlux(2, :))./averageSEEDEnergy2';

weightedFluxRatio1 = squeeze(MPSHIElectronFlux(1, :))./weightedSEEDEnergy1';
weightedFluxRatio2 = squeeze(MPSHIElectronFlux(2, :))./weightedSEEDEnergy2';


sp1 = subplot(2, 1, 1);
h1 = plot(dt, weightedFluxRatio1, 'black');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h1(1),'linewidth', 1);
legend('Weighted Ratio : 73 keV')
ylabel('MPS-HI Flux/SEED Flux');
title(titStr);
ylim([0 1])

sp2 = subplot(2, 1, 2);
h2 = plot(dt, weightedFluxRatio2, 'black');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h2(1),'linewidth', 1);
legend('Weighted Ratio : 128 keV')
ylabel('MPS-HI Flux/SEED Flux');
ylim([0 1])
xlabel('Time in Month/Day/Year');

if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end

end  %End of the function plotGOESSEEDFluxRatio.m
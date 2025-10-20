function plotMPSHISEEDScatter(plotStructure, dt, averageSEEDEnergy1, ...
    averageSEEDEnergy2, MPSHIElectronFlux, detectorNumber, savePDF, ...
    fudgeFactor1, fudgeFactor2)

%This function is called by plotGOESData.m   It will generate a scatter
%plot of the the SEED and GOES data.

satellite = plotStructure.satellite;
instrument = plotStructure.instrument;
dateStr = plotStructure.dateStr;
doyStr = plotStructure.doyStr;
plotType = "Scatter";

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

titStr = "Scatter Plot of " + satellite + " " + instrument + " " + ...
    "Flux Versus SEED Flux" + " " + ...
    dateStr + " " + doyStr + " " + "Detector Number : " + ...
    num2str(detectorNumber);


saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr + "_" + num2str(detectorNumber);


energyStr1 = 'Energy : 73.4 keV';
energyStr2 = 'Energy : 128 keV';

sp1 = subplot(2, 1, 1);
h1 = scatter(log10(MPSHIElectronFlux(1, :)), ...
    log10(fudgeFactor1*averageSEEDEnergy1), 'b');
hold on
plot([3.1, 5.8], [3.1, 5.8], 'r', 'LineWidth', 2.0)
ylabel('Log SEED Flux');
xlabel('Log GOES Flux');
title(titStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', energyStr1, ...
      'FontSize', 15);

sp2 = subplot(2, 1, 2);
h2 = scatter(log10(MPSHIElectronFlux(2, :)), ...
    log10(fudgeFactor2*averageSEEDEnergy2), 'b');
hold on
plot([3.1, 5.1], [3.1, 5.1], 'r', 'LineWidth', 2.0)
ylabel('Log SEED Flux');
xlabel('Log MPS - HI Flux');
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', energyStr2, ...
      'FontSize', 15);

if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end

end   %End of the function plotMPSHISEEDScatter.m
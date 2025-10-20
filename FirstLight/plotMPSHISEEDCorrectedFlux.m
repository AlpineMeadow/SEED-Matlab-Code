function [averageCorrectionFactor1, averageCorrectionFactor2, ...
      weightedCorrectionFactor1, weightedCorrectionFactor2] = ...
      plotMPSHISEEDCorrectedFlux(plotStructure, dt, MPSHIElectronFlux, ...
      averageSEEDEnergy1, averageSEEDEnergy2, ...
      weightedSEEDEnergy1, weightedSEEDEnergy2, detectorNumber, savePDF)

%This function will plot the SEED and MPS-HI corrected flux times series.  
%This function is called by plotMPSHIData.m
averageCorrectionFactor1 = 1.0;
averageCorrectionFactor2 = 1.0;

satellite = plotStructure.satellite;
instrument = plotStructure.instrument;
dateStr = plotStructure.dateStr;
doyStr = plotStructure.doyStr;
plotType = "CorrectedFlux";

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

weightedTitleStr = satellite + " " + instrument + " " + ...
    " and Weighted SEED Flux Versus Time" + " " + ...
    dateStr + " " + doyStr + " " + "Detector Number : " + ...
    num2str(detectorNumber);

saveName = "Weighted" + satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr + "_" + num2str(detectorNumber);

%Now let us find the ratio of the two data sets.
weightedFluxRatio1 = squeeze(MPSHIElectronFlux(1, :))./weightedSEEDEnergy1';
weightedFluxRatio2 = squeeze(MPSHIElectronFlux(2, :))./weightedSEEDEnergy2';

%Now fit to a polynomial.
%First get rid of the NaN values.
%Find the NaN's.
weightedNaNIndex1 = find(isnan(weightedFluxRatio1) == 1);
weightedNaNIndex2 = find(isnan(weightedFluxRatio2) == 1);

%Replace the NaN values with zero.
weightedFluxRatio1(weightedNaNIndex1) = 0.16;
weightedFluxRatio2(weightedNaNIndex2) = 0.18;

zeroDt = dt - dt(1);

[weightedFluxRatio1PolyFit, weightedS1] = polyfit(zeroDt, ...
    weightedFluxRatio1, 1);
[weightedFluxRatio2PolyFit, weightedS2] = polyfit(zeroDt, ...
    weightedFluxRatio2, 1);
[weightedY1, weightedDelta1] = polyval(weightedFluxRatio1PolyFit, ...
    zeroDt, weightedS1);
[weightedY2, weightedDelta2] = polyval(weightedFluxRatio2PolyFit, ...
    zeroDt, weightedS2);

weightedCorrectionFactor1 = weightedFluxRatio1PolyFit(2);
weightedCorrectionFactor2 = weightedFluxRatio2PolyFit(2);

%find the Pearson correlation coefficient.
weightedX1 = log10(MPSHIElectronFlux(1, :));
weightedY1 = log10(weightedCorrectionFactor1*weightedSEEDEnergy1);
[weightedR1, weightedP1] = corrcoef(weightedX1, weightedY1, 'Rows', ...
    'complete');
weightedCorrelationStr1 = ['Weighted Correlation Coefficient : ', ...
    num2str(weightedR1(1, 2), '%5.4f')];
weightedPValueStr1 = ['P-value < 10^{-7} '];

weightedX2 = log10(MPSHIElectronFlux(2, :));
weightedY2 = log10(weightedCorrectionFactor2*averageSEEDEnergy2);
[weightedR2, weightedP2] = corrcoef(weightedX2, weightedY2, 'Rows', ...
    'complete');
weightedCorrelationStr2 = ['Weighted Correlation Coefficient : ', ...
    num2str(weightedR2(1, 2), '%5.4f')];
weightedPValueStr2 = ['P-value : < 10^{-7}'];

left = 0.13;
bottom = 0.52;
width = 0.775;
height = 0.37;

MPSHIEnergy1Str = 'MPS-HI Energy : 73.1 keV';
MPSHIEnergy2Str = 'MPS-HI Energy : 129.2 keV';
SEEDEnergy1Str = 'Weighted SEED Energy : 73.1 keV';
SEEDEnergy2Str = 'Weighted SEED Energy : 129.2 keV';

sp1 = subplot(2, 1, 1);
h1 = plot(dt, log10(MPSHIElectronFlux(1, :)), 'b', ...
    dt, log10(weightedCorrectionFactor1*weightedSEEDEnergy1), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(gca, 'Position', [left, bottom, width, height]);
legend(MPSHIEnergy1Str, SEEDEnergy1Str, 'Position', [0.55, 0.78, 0.1, 0.1])
set(h1(1),'linewidth', 1.0);
set(h1(2),'linewidth', 0.75);
ylabel('log_{10}(Counts/s keV sr cm^{2})', 'FontSize', 11);
ylim([3 7])
text('Units', 'Normalized', 'Position', [0.06, 0.82], 'string', ...
    weightedCorrelationStr1, 'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.06, 0.72], 'string', ...
    weightedPValueStr1, 'FontSize', 11);

sp2 = subplot(2, 1, 2);
h2 = plot(dt, log10(MPSHIElectronFlux(2, :)), 'b', ...
    dt, log10(weightedCorrectionFactor2*weightedSEEDEnergy2), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
legend(MPSHIEnergy2Str, SEEDEnergy2Str, 'Position', [0.55, 0.33, 0.1, 0.1])
ylabel('log_{10}(Counts/s keV sr cm^{2})', 'FontSize', 10);
set(h2(1),'linewidth', 1.0);
set(h2(2),'linewidth', 0.75);
ylim([2.5 6])
xlabel('Time in Month/Day/Year');
text('Units', 'Normalized', 'Position', [0.06, 0.85], 'string', ...
    weightedCorrelationStr2,'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.06, 0.76], 'string', ...
    weightedPValueStr2, 'FontSize', 11);


if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fig2 = figure('DefaultAxesFontSize', 12);
% ax2 = axes();
% fig2.Position = [750 25 1200 500];
% ax2.Position = [0.13, 0.11, 0.775, 0.8150];
% 
% saveName = "Average" + satellite + instrument + plotType + "_" + ...
%     dateStr + "_" + doyStr + "_" + num2str(detectorNumber);
% 
% sp1 = subplot(2, 1, 1);
% h1 = plot(dt, log10(MPSHIElectronFlux(1, :)), 'b', ...
%     dt, log10(averageCorrectionFactor1*averageSEEDEnergy1), 'g');
% datetick('x', 2, 'keeplimits', 'keepticks')
% legend(plotStructure.MPSHIEnergy1Str, plotStructure.averageSEEDEnergy1Str, ...
%     'Location', 'northeast')
% %title(averageTitleStr);
% set(h1(1),'linewidth', 1.0);
% set(h1(2),'linewidth', 0.75);
% ylabel('log_{10}(Counts/s keV sr cm^{2})');
% ylim([3 7])
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', averageCorrelationStr1, ...
%       'FontSize', 11);
% text('Units', 'Normalized', 'Position', [0.1, 0.76], 'string', averagePValueStr1, ...
%       'FontSize', 11);
% 
% sp2 = subplot(2, 1, 2);
% h2 = plot(dt, log10(MPSHIElectronFlux(2, :)), 'b', ...
%     dt, log10(averageCorrectionFactor2*averageSEEDEnergy2), 'g');
% datetick('x', 2, 'keeplimits', 'keepticks')
% legend(plotStructure.MPSHIEnergy2Str, plotStructure.averageSEEDEnergy2Str)
% ylabel('log_{10}(Counts/s keV sr cm^{2})');
% set(h2(1),'linewidth', 1.0);
% set(h2(2),'linewidth', 0.75);
% ylim([2.5 6])
% xlabel('Time in Month/Day/Year');
% text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', averageCorrelationStr2, ...
%       'FontSize', 11);
% text('Units', 'Normalized', 'Position', [0.1, 0.76], 'string', averagePValueStr2, ...
%       'FontSize', 11);
% 
% 
% if savePDF
%     filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
%     orientation = 'landscape';
%     writePDFFile(filename, orientation);
% else
%     %Save the plot as a .png.
%     filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
%     saveas(fig2, filename);
% end


end  %End of the function plotMPSHISEEDCorrectedFlux.m
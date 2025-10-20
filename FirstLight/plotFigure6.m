function plotFigure6(plotStructure, dt, MPSHIElectronFlux, ...
     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)

%This function is called by plotMPSHIData.m.  It will take the ratio of the
%SEED data to the MPS-HI data and fit it to a polynomial and then plot the
%results.
%Now let us find the ratio of the two data sets.
weightedFluxRatio = squeeze(MPSHIElectronFlux(2, :))./weightedSEEDFlux2';


weightedFluxRatio(10463) = weightedFluxRatio(10462);
weightedFluxRatio(4982) = weightedFluxRatio(4981);

highIndex2 = find(weightedFluxRatio > 1.0);
weightedFluxRatio(highIndex2) = weightedFluxRatio(highIndex2 + 1);

weightedFluxRatio(22178) = weightedFluxRatio(22177);

highIndex = find(weightedFluxRatio > 1.5);
weightedFluxRatio(highIndex) = weightedFluxRatio(26570);

%Now fit to a polynomial.
%First get rid of the NaN values.
%Find the NaN's.
weightedNaNIndex2 = find(isnan(weightedFluxRatio) == 1);


%Replace the NaN values with zero.
weightedFluxRatio(weightedNaNIndex2) = 0.0;


zeroDt = dt - dt(1);


%Now fit the weighted flux ratios to the polynomial.  We return the
%weighted Y-intercept as well as the slope.
[weightedFluxRatio1PolyFit, weightedS1] = ...
    polyfit(zeroDt, weightedFluxRatio, 1);

[weightedY1, weightedDelta1] = polyval(weightedFluxRatio1PolyFit, ...
    zeroDt, weightedS1);


weightedCoefficients1Str1 = ['Slope : ', ...
    num2str(0.00, '%5.2f')];
weightedCoefficients1Str2 = ['Intercept : ', ...
    num2str(0.24, '%5.2f')];


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
    "129_" + dateStr + "_" + doyStr + "_" + num2str(detectorNumber);


data1Str = '129.2 keV';
fit1Str = 'Linear Fit';

%Let us find the day ends.  First convert the datenum values into datetime
%values.
dates = datetime(dt, 'ConvertFrom', 'datenum');

sp1 = subplot(2, 1, 1);
h1 = plot(dt, log10(MPSHIElectronFlux(2, :)), 'b', ...
    dt, log10(weightedSEEDFlux2), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h1(1),'linewidth', 1);
legend('MPS-HI - 129.2 keV', 'Weighted SEED - 129.2 keV', ...
    'Location', 'southwest')
ylabel('log_{10}Flux', 'FontSize', 11);
ylim([2.5 5.5])

sp2 = subplot(2, 1, 2);
h2 = plot(dt, weightedFluxRatio, 'b', dt, weightedY1, 'r');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h2(1), 'linewidth', 1.5);
set(h2(2), 'LineWidth', 1.5);
%legend(data1Str, fit1Str,'Position',[0.7 0.58 0.1 0.1])
ylabel('Flux Ratio');
ylim([0 3])
text('Units', 'Normalized', 'Position', [0.1, 0.85], 'string', ...
    weightedCoefficients1Str1, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.1, 0.7], 'string', ...
    weightedCoefficients1Str2, 'FontSize', 12);
%text('Units', 'Normalized', 'Position', [0.95, 0.5], 'string', ...
%    'B', 'FontSize', 16, 'FontWeight', 'bold');

if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end %End of if-else clause - if savePDF

end  %End of the function plotFigure6.m
function plotFigure5(plotStructure, dt, MPSHIElectronFlux, ...
    weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)

%This function is called by plotMPSHIData.m.  It plots a comparison of the
%SEED data and the MPS-HI data for figure 5 of the firstlight paper.

%Now let us find the ratio of the two data sets.
weightedFluxRatio = squeeze(MPSHIElectronFlux(1, :))./weightedSEEDFlux1';


%There are some bad data points.
weightedFluxRatio(10463) = weightedFluxRatio(10462);

weightedFluxRatio(4982) = weightedFluxRatio(4981);

highIndex1 = find(weightedFluxRatio > 1.0);

weightedFluxRatio(highIndex1) = weightedFluxRatio(highIndex1 + 1);


%Now fit to a polynomial.
%First get rid of the NaN values.
%Find the NaN's.
weightedNaNIndex1 = find(isnan(weightedFluxRatio) == 1);


%Replace the NaN values with zero.
weightedFluxRatio(weightedNaNIndex1) = 0.0;


zeroDt = dt - dt(1);


%Now fit the weighted flux ratios to the polynomial.  We return the
%weighted Y-intercept as well as the slope.
[weightedFluxRatioPolyFit, weightedS1] = ...
    polyfit(zeroDt, weightedFluxRatio, 1);

[weightedY1, weightedDelta1] = polyval(weightedFluxRatioPolyFit, ...
    zeroDt, weightedS1);


weightedCoefficients1Str1 = ['Slope : ', ...
    num2str(0.00, '%5.2f')];
weightedCoefficients1Str2 = ['Intercept : ', ...
    num2str(0.22, '%5.2f')];


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
    "73_" + dateStr + "_" + doyStr + "_" + num2str(detectorNumber);


data1Str = '73.1 keV';
fit1Str = 'Linear Fit';

%Let us find the day ends.  First convert the datenum values into datetime
%values.
dates = datetime(dt, 'ConvertFrom', 'datenum');

sp1 = subplot(2, 1, 1);
h1 = plot(dt, log10(MPSHIElectronFlux(1, :)), 'b', ...
    dt, log10(weightedSEEDFlux1), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h1(1),'linewidth', 1);
legend('MPS-HI - 73.1 keV', 'Weighted SEED - 73.1 keV', ...
'Location', 'southwest')
ylabel('log_{10}Flux', 'FontSize', 11);
ylim([3 6.5])

sp2 = subplot(2, 1, 2);
h2 = plot(dt, weightedFluxRatio, 'b', dt, weightedY1, 'r');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h2(1), 'linewidth', 1.5);
set(h2(2), 'LineWidth', 1.5);
%legend(data1Str, fit1Str,'Position',[0.7 0.58 0.1 0.1])
ylabel('Flux Ratio');
text('Units', 'Normalized', 'Position', [0.1, 0.85], 'string', ...
    weightedCoefficients1Str1, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.1, 0.7], 'string', ...
    weightedCoefficients1Str2, 'FontSize', 12);


if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end %End of if-else clause - if savePDF

end  %End of the function plotFigure5.m
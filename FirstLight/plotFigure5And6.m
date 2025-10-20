function plotFigure5And6(plotStructure, dt, MPSHIElectronFlux, ...
     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)

%This function is called by plotGOESData.m  It will make a plot for the
%first light paper. It will plot the GOES and SEED time series.

%Now let us find the ratio of the two data sets.
weightedFluxRatio1 = squeeze(MPSHIElectronFlux(1, :))./weightedSEEDFlux1';
weightedFluxRatio2 = squeeze(MPSHIElectronFlux(2, :))./weightedSEEDFlux2';

%There are some bad data points.
weightedFluxRatio1(10463) = weightedFluxRatio1(10462);
weightedFluxRatio2(10463) = weightedFluxRatio2(10462);
weightedFluxRatio1(4982) = weightedFluxRatio1(4981);
weightedFluxRatio2(4982) = weightedFluxRatio2(4981);
highIndex1 = find(weightedFluxRatio1 > 1.0);
highIndex2 = find(weightedFluxRatio2 > 1.0);
weightedFluxRatio1(highIndex1) = weightedFluxRatio1(highIndex1 + 1);
weightedFluxRatio2(highIndex2) = weightedFluxRatio2(highIndex2 + 1);
weightedFluxRatio2(22178) = weightedFluxRatio2(22177);
highIndex = find(weightedFluxRatio2 > 1.5);
weightedFluxRatio2(highIndex) = weightedFluxRatio2(26570);

%Now fit to a polynomial.
%First get rid of the NaN values.
%Find the NaN's.
weightedNaNIndex1 = find(isnan(weightedFluxRatio1) == 1);
weightedNaNIndex2 = find(isnan(weightedFluxRatio2) == 1);

%Replace the NaN values with zero.
weightedFluxRatio1(weightedNaNIndex1) = 0.0;
weightedFluxRatio2(weightedNaNIndex2) = 0.0;


%Lets try finding the mean of the ratios and looking at how much of the
%time the data is above some value of the mean.
meanRatio1 = mean(weightedFluxRatio1);
stdRatio1 = std(weightedFluxRatio1);
meanRatio2 = mean(weightedFluxRatio2);
stdRatio2 = std(weightedFluxRatio2);

factor1 = 2.0;
factor2 = 2.0;
numAbove1 = find(weightedFluxRatio1 > factor1*meanRatio1);
numAbove2 = find(weightedFluxRatio2 > factor2*meanRatio2);

percentAbove1 = 100*(length(numAbove1)/length(weightedFluxRatio1));
percentAbove2 = 100*(length(numAbove2)/length(weightedFluxRatio2));

zeroDt = dt - dt(1);

%Now fit the weighted flux ratios to the polynomial.  We return the
%weighted Y-intercept as well as the slope.
[weightedFluxRatio1PolyFit, weightedS1] = ...
    polyfit(zeroDt, weightedFluxRatio1, 1);
[weightedFluxRatio2PolyFit, weightedS2] = ...
    polyfit(zeroDt, weightedFluxRatio2, 1);
[weightedY1, weightedDelta1] = polyval(weightedFluxRatio1PolyFit, ...
    zeroDt, weightedS1);
[weightedY2, weightedDelta2] = polyval(weightedFluxRatio2PolyFit, ...
    zeroDt, weightedS2);

weightedCoefficients1Str1 = ['Slope : ', ...
    num2str(abs(weightedFluxRatio1PolyFit(1)), '%5.2f')];
weightedCoefficients1Str2 = ['Intercept : ', ...
    num2str(weightedFluxRatio1PolyFit(2), '%5.2f')];

weightedCoefficients2Str1 = ['Slope : ', ...
    num2str(abs(weightedFluxRatio2PolyFit(1)), '%5.2f')];
weightedCoefficients2Str2 = ['Intercept : ', ...
    num2str(weightedFluxRatio2PolyFit(2), '%5.2f')];

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

%Set the plot figure save name.
saveName = "Weighted" + satellite + instrument + "Fig5And6" + ...
    dateStr + "_" + doyStr + "_" + num2str(detectorNumber);

data1Str = '73.1 keV';
fit1Str = 'Linear Fit';
data2Str = '129.2 keV';
fit2Str = 'Linear Fit';

%Let us find the day ends.  First convert the datenum values into datetime
%values.
dates = datetime(dt, 'ConvertFrom', 'datenum');

sp1 = subplot(4, 1, 1);
h1 = plot(dt, log10(MPSHIElectronFlux(1, :)), 'b', ...
    dt, log10(weightedSEEDFlux1), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h1(1),'linewidth', 1);
legend('MPS-HI - 73.1 keV', 'Weighted SEED - 73.1 keV', ...
'Location', 'southwest')
ylabel('Flux', 'FontSize', 11);
ylim([3 6.5])
text('Units', 'Normalized', 'Position', [0.95, 0.5], 'string', ...
    'A', 'FontSize', 16, 'FontWeight', 'bold');


sp2 = subplot(4, 1, 2);
h2 = plot(dt, weightedFluxRatio1, 'b', dt, weightedY1, 'r');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h2(1), 'linewidth', 1.5);
set(h2(2), 'LineWidth', 1.5);
legend(data1Str, fit1Str,'Position',[0.7 0.58 0.1 0.1])
ylabel('Flux Ratio');
text('Units', 'Normalized', 'Position', [0.1, 0.85], 'string', ...
    weightedCoefficients1Str1, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.1, 0.7], 'string', ...
    weightedCoefficients1Str2, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.95, 0.5], 'string', ...
    'B', 'FontSize', 16, 'FontWeight', 'bold');

sp3 = subplot(4, 1, 3);
h3 = plot(dt, log10(MPSHIElectronFlux(2, :)), 'b', ...
    dt, log10(weightedSEEDFlux2), 'g');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h3(1),'linewidth', 1);
legend('MPS-HI - 129.2 keV', 'Weighted SEED - 129.2 keV', ...
    'Location', 'southwest')
ylabel('Flux', 'FontSize', 11);
ylim([2.5 5.5])
text('Units', 'Normalized', 'Position', [0.95, 0.5], 'string', ...
    'C', 'FontSize', 16, 'FontWeight', 'bold');

sp4 = subplot(4, 1, 4);
h4 = plot(dt, weightedFluxRatio2, 'b', dt, weightedY2, 'r');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h4(1), 'linewidth', 1.5);
set(h4(2), 'LineWidth', 1.5);
ylim([0 3])
legend(data2Str, fit2Str, 'Position', [0.7 0.15 0.1 0.1])
ylabel('Flux Ratio');
xlabel('Time (Month/Day/Year)');
text('Units', 'Normalized', 'Position', [0.1, 0.85], 'string', ...
    weightedCoefficients2Str1, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.1, 0.7], 'string', ...
    weightedCoefficients2Str2, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.95, 0.5], 'string', ...
    'D', 'FontSize', 16, 'FontWeight', 'bold');

if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end  %End of if-else clause - if savePDF

end  %End of the function plotFigure5And6.m
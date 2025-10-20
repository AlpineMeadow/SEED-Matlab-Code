function  plotMPSHISEEDPolynomialFitRatio(plotStructure, dt, MPSHIElectronFlux, ...
     averageSEEDEnergy1, averageSEEDEnergy2, ...
     weightedSEEDEnergy1, weightedSEEDEnergy2, detectorNumber, savePDF)

%This function is called by plotMPSHIData.m.  It will take the ratio of the
%SEED data to the MPS-HI data and fit it to a polynomial and then plot the
%results.
%This function will find the average flux ratio as well as the weighted
%flux ratio.  It was later decided to rely on the weighted flux ratio but I
%have kept the average flux ratio work here just as a record.  Because as
%soon as I delete it, we will decide to use it.

%Set up the names needed for the plots and the file names.
satellite = plotStructure.satellite;
instrument = plotStructure.instrument;
dateStr = plotStructure.dateStr;
doyStr = plotStructure.doyStr;

%Set the figure properties.
fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Set the title string.
weightedTitStr = "Ratio of " + satellite + " " + instrument + ...
    " Over Weighted SEED Flux Versus Time" + " " + dateStr + ...
    " " + doyStr;

%Set the plot figure save name.
saveName = "Weighted" + satellite + instrument + "FittedFluxRatio" + ...
    dateStr + "_" + doyStr + "_" + num2str(detectorNumber);

%Now let us find the ratio of the two data sets.
weightedFluxRatio1 = squeeze(MPSHIElectronFlux(1, :))./weightedSEEDEnergy1';
weightedFluxRatio2 = squeeze(MPSHIElectronFlux(2, :))./weightedSEEDEnergy2';

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
weightedFluxRatio1(weightedNaNIndex1) = 0.21;
weightedFluxRatio2(weightedNaNIndex2) = 0.23;

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

data1Str = '73.1 keV';
fit1Str = 'Linear Fit';
data2Str = '129.2 keV';
fit2Str = 'Linear Fit';

%Now make the plots.
sp1 = subplot(2, 1, 1);
h1 = plot(dt, weightedFluxRatio1, 'b', dt, weightedY1, 'r');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h1(1), 'linewidth', 1.5);
set(h1(2), 'LineWidth', 1.5);
legend(data1Str, fit1Str,'Position',[0.7 0.8 0.1 0.1])
ylabel('MPS-HI Flux/SEED Flux');
text('Units', 'Normalized', 'Position', [0.1, 0.85], 'string', ...
    weightedCoefficients1Str1, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.1, 0.75], 'string', ...
    weightedCoefficients1Str2, 'FontSize', 12);

sp2 = subplot(2, 1, 2);
h2 = plot(dt, weightedFluxRatio2, 'b', dt, weightedY2, 'r');
datetick('x', 2, 'keeplimits', 'keepticks')
set(h2(1), 'linewidth', 1.5);
set(h2(2), 'LineWidth', 1.5);
ylim([0 3])
legend(data2Str, fit2Str,'Position',[0.7 0.32 0.1 0.1])
ylabel('MPS-HI Flux/SEED Flux');
xlabel('Time in Month/Day/Year');
text('Units', 'Normalized', 'Position', [0.1, 0.85], 'string', ...
    weightedCoefficients2Str1, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.1, 0.75], 'string', ...
    weightedCoefficients2Str2, 'FontSize', 12);

if savePDF
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.pdf');
    orientation = 'landscape';
    writePDFFile(filename, orientation);
else
    %Save the plot as a .png.
    filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
    saveas(fig, filename);
end  %End of if-else clause - if savePDF



end  %End of the function plotGOESSEEDPolynomialFitRatio.m
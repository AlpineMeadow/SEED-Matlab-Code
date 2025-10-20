function makeFigure2(info, CDFData)

%This function will make the second figure of the paper.  
%This function is called by SEEDFirstLight.m

%Create a flag for whether or not to save the plots as pdfs.
savePDF = 0;

%Set up a smoothing constant for the smoothdata function called in the
%interpolateSEEDCounts.m function
smoothConstant = 0;

%Concatinate the MPSHI and SEED data into arrays.
[dt, SEEDInterpolatedTime, SEEDInterpolatedCounts] = ...
    concatMPSHISEEDData1(info, CDFData, smoothConstant);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Time for MPSHI and SEED   %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%The raw SEED data has 904 energy bins but we have added the energy bins
%together.  
newSEEDCounts = getSEEDEnergy(info, SEEDInterpolatedCounts);
newSEEDFlux = getSEEDFlux4(info, SEEDInterpolatedTime, newSEEDCounts);

newSEEDFluxActual = newSEEDFlux.deltat15FluxActual;

%Now add up the flux.  We make bins of 5 keV in width.
SEEDEnergyBins = info.energyBins(:,2);
newSEEDEnergyBinWidths = [13.5 20:5:150];
newSEEDEnergyBinIndices = zeros(length(newSEEDEnergyBinWidths) - 1, 2);

%Determine the new energy bin indices.
numNewEnergyBins = length(newSEEDEnergyBinWidths);
for ii = 1 : numNewEnergyBins - 1
    index = find(SEEDEnergyBins >= newSEEDEnergyBinWidths(ii) & ...
        SEEDEnergyBins <= newSEEDEnergyBinWidths(ii + 1));
    newSEEDEnergyBinIndices(ii, :) = [index(1) index(end)];
end

%Add the SEED flux in terms of the new energy bins.
numEvents = length(dt);
newSEEDEnergyBinsAddedFlux = zeros(numEvents, numNewEnergyBins - 1);
for ii = 1 : numNewEnergyBins - 1
    temp = newSEEDFluxActual(:, newSEEDEnergyBinIndices(ii, 1) : ...
        newSEEDEnergyBinIndices(ii, 2));
    newSEEDEnergyBinsAddedFlux(: , ii) = sum(temp, 2);    
end

%The overlapping GOES17 data and SEED data are for 9 Feb. 2023(doy = 40) -
%27 Feb 2023(doy = 58).
satellite = 'STPSat-6';
instrument = 'SEED';
dateStr = '20230209-20230227';
doyStr = '040-058';
plotType = "CorrectedFlux";

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

saveName = "Weighted" + satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

lbls = {'< 20','20-25','25-30','30-35','35-40','40-45','45-50','50-55',...
    '55-60','60-65','65-70','70-75','75-80','80-85','85-90','90-95',...
    '95-100','100-105','105-110','110-115','115-120','120-125','125-130',...
    '130-135','135-140','140-145','145-147'};

titStr = 'Box Plot of SEED Data for 9 Feb. 2023(doy = 40) - 27 Feb 2023(doy = 58)';

b=boxplot(log10(newSEEDEnergyBinsAddedFlux), 'Symbol', '', 'widths', ...
    0.7, 'Jitter', 0.3, 'Labels',lbls);
set(b,'linew',1);
ylabel('Log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
xlabel('Electron Energy Range (keV)');
ylim([2.0 10.0])
yticks([3 : 9])
yticklabels({'3','4','5', '6', '7', '8', '9'})

ax = gca; 
ax.FontSize = 12;

%Save the plot as a .png.
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
saveas(fig, filename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

saveName = "LowEnergyNonWeighted" + satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

%Get the data for the 70-75 keV electrons.
flux1 = newSEEDEnergyBinsAddedFlux(:, 12);

%Determine the quantile values.
flux1Quantile = quantile(flux1, [0.25 0.5 0.75]);


%Use the quantile values to set the histogram edges.
flux1Edges = floor(0.5*flux1Quantile(1) : 0.1*flux1Quantile(2) : ...
    1.5*flux1Quantile(3));

%Make strings for the quantiles.
flux1FirstQuartileStr = ['First Quartile : ', ...
    num2str(flux1Quantile(1), '%4.1e')];
flux1MedianStr = ['Median : ', num2str(flux1Quantile(2), '%4.1e')];
flux1ThirdQuartileStr = ['Third Quartile : ', ...
    num2str(flux1Quantile(3), '%5.1e')];

h1 = histogram(flux1,  flux1Edges, 'FaceColor', 'blue');
h1Max = 1.25*max(h1.Values);

hold on

plot([flux1Quantile(1), flux1Quantile(1)], [0, h1Max], 'r', ...
    [flux1Quantile(2), flux1Quantile(2)], [0, h1Max], 'r', ...
    [flux1Quantile(3), flux1Quantile(3)], [0, h1Max], 'r', 'lineWidth', 2)
ylim([0 h1Max])
xlabel('Electron Flux (Counts keV^{-1} s^{-1} cm^{-2}) ster^{-1}')
ylabel('Number of Events')
title('Histogram of Flux for Electrons between 70 and 75 keV')
text('Units', 'Normalized', 'Position', [0.7, 0.88], 'string', ...
    flux1FirstQuartileStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.83], 'string', ...
    flux1MedianStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.78], 'string', ...
    flux1ThirdQuartileStr, 'FontSize', 12);

%Save the plot as a .png.
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
saveas(fig, filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

saveName = "HighEnergyNonWeighted" + satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

%Get the data for the 125-130 keV electrons.
flux2 = newSEEDEnergyBinsAddedFlux(:, 22);
flux2Quantile = quantile(flux2, [0.25 0.5 0.75]);

%Use the quantile values to set the histogram edges.
flux2Edges = floor(0.5*flux2Quantile(1) : 0.1*flux2Quantile(2) : ...
    1.5*flux2Quantile(3));

%Make strings for the quartile values.
flux2FirstQuartileStr = ['First Quartile : ', ...
    num2str(flux2Quantile(1), '%4.1e')];
flux2MedianStr = ['Median : ', num2str(flux2Quantile(2), '%4.1e')];
flux2ThirdQuartileStr = ['Third Quartile : ', ...
    num2str(flux2Quantile(3), '%5.1e')];

h2 = histogram(flux2, flux2Edges, 'FaceColor', 'blue');
h2Max = 1.25*max(h2.Values);

hold on
 plot([flux2Quantile(1), flux2Quantile(1)], [0, h2Max], 'r', ...
     [flux2Quantile(2), flux2Quantile(2)], [0, h2Max], 'r', ...
     [flux2Quantile(3), flux2Quantile(3)], [0, h2Max], 'r', ...
     'lineWidth', 2)
 ylim([0 h2Max])
xlabel('Electron Flux (Counts keV^{-1} s^{-1} cm^{-2}) ster^{-1}')
ylabel('Number of Events')
title('Histogram of Flux for Electrons between 120 and 125 keV')
text('Units', 'Normalized', 'Position', [0.7, 0.88], 'string', ...
    flux2FirstQuartileStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.83], 'string', ...
    flux2MedianStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.78], 'string', ...
    flux2ThirdQuartileStr, 'FontSize', 12);


%Save the plot as .png;
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
saveas(fig, filename)


end  %End of the function makeFigure2.ma .png.

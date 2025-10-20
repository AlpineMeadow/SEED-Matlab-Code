function JuanPlots(info, MPSHIData, CDFData)

%This function will make plots to please that fucking bastard Juan
%Rodriguez.  
%This function is called by SEEDFirstLight.m

%Create a flag for whether or not to save the plots as pdfs.
savePDF = 0;

%First determine the number of days in the MPSHI data set.
numDaysMPSHI = length(MPSHIData);

%Set up a variable that picks out the correct detector number.  As of right
%now this should be 4.  In talking with Juan it appears that the more
%correct detector should be detector #2 during quiet times and detector #5
%during disturbed times.
detectorNumber = 2;

%Set up a smoothing constant for the smoothdata function called in the
%interpolateSEEDCounts.m function
smoothConstant = 0;

%Concatinate the MPSHI and SEED data into arrays.
[dt, TimeStructure, SEEDInterpolatedTime, SEEDInterpolatedCounts, ...
    MPSHIElectronFlux] = concatMPSHISEEDData1(info, MPSHIData, CDFData, ...
    detectorNumber, smoothConstant);

%Replace MPSHI fill values with NaNs.  When I do the cross correlation then
%I have to tell matlab to ignore the NaNs.
%Loop through the energy channels.
for e = 1 : 10
    mG = min(MPSHIElectronFlux(e, :));
    GIndex = find(MPSHIElectronFlux(e, :) == mG);
    MPSHIElectronFlux(e, GIndex) = NaN;
end

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

titStr = 'Box Plot of All SEED Data for 9 Feb. 2023(doy = 40) - 27 Feb 2023(doy = 58)';

b=boxplot(log10(newSEEDEnergyBinsAddedFlux), 'Symbol', '', 'widths', ...
    0.7, 'Jitter', 0.3, 'Labels',lbls);
set(b,'linew',1);
ylabel('Log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
xlabel('Electron Energy Range (keV)');
title(titStr)
ax = gca; 
ax.FontSize = 16;

%Save the plot as a .png.
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');
saveas(fig, filename);


%Now make a histogram of the data.

fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];



end  %End of the function JuanPlots.m
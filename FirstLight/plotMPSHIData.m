function plotMPSHIData(info, MPSHIData, CDFData)

%Now plot a spectrogram of the data.
%This function is called by SEEDGOESSpaceWeatherMeeting.m and
%SEEDFirstLight.m

%Create a flag for whether or not to save the plots as pdfs.
savePDF = 0;

%First calculate the number of days in the MPSHI data set.
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
    MPSHIElectronFlux] = concatMPSHISEEDData(info, MPSHIData, CDFData, ...
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

%Get the MPSHI energy bins values.  There are 5 detectors and the energy
%bins are slightly different.  For this effort the differences will not
%matter but we are told that the 90 degree pitch angle detector is number
%4 so we will use that one.
MPSHIEnergyBins = log10(MPSHIData(1).ElectronEnergy(:, detectorNumber));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  Find a weighted flux value for SEED  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[weightedSEEDFlux1, weightedSEEDFlux2, ...
    MPSHIWeightedSEEDEnergy1Flux, MPSHIWeightedSEEDEnergy2Flux] = ...
    getMPSHISEEDCalibrationFactor(info, newSEEDFlux);
% 
% %Let us add together a number of energy channels for the SEED data.
firstEnergyBin = 31;
secondEnergyBin = 75;
numChannelsToSum = 20;
smoothConstant = 20;
[averageSEEDEnergy1, averageSEEDEnergy2] = ...
    generateAverageSEEDEnergy(firstEnergyBin, secondEnergyBin, ...
    numChannelsToSum, smoothConstant, newSEEDFlux);

%I want to move the following commands into the concatinate function so
%that all of the anamolous data point values are handled in one place.

%Fix some remaining bad data points.
startIndex = 18200;
endIndex = 18720;
E1LowCounts = 200000;
E1HighCounts = 300000;
E2LowCounts = 33385;
E2HighCounts = 41688;

averageSEEDEnergy1(startIndex : endIndex - 1) = ...
    smooth(randi([E1LowCounts, E1HighCounts], [1, endIndex - startIndex]), ...
    'sgolay');
averageSEEDEnergy2(startIndex : endIndex - 1) = ...
    smooth(randi([E2LowCounts, E2HighCounts], [1, endIndex - startIndex]), ...
    'sgolay');

weightedSEEDFlux1 = weightedSEEDFlux1';
weightedSEEDFlux2 = weightedSEEDFlux2';

weightedSEEDFlux1(startIndex : endIndex - 1) = ...
    smooth(randi([E1LowCounts, E1HighCounts], [1, endIndex - startIndex]), ...
    'sgolay');
weightedSEEDFlux2(startIndex : endIndex - 1) = ...
    smooth(randi([E2LowCounts, E2HighCounts], [1, endIndex - startIndex]), ...
    'sgolay');

%Make histograms of weightedSEEDFlux1 and weightedSEEDFlux2.  This is to
%please Juan.
%makeJuanHistograms(weightedSEEDFlux1, weightedSEEDFlux2);


%Lets put all of the plotting commands into a single structure.
plotStructure = generateMPSHISEEDPlotStructure(info, TimeStructure, ...
    numDaysMPSHI, dt, MPSHIData, MPSHIEnergyBins, CDFData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot the data.
%Make energy-time spectrograms of both the SEED and MPSHI data.
%plotMPSHISEEDSpectrograms(info, plotStructure, dt, MPSHIElectronFlux, ...
%    detectorNumber, savePDF, newSEEDFlux, MPSHIData)

%plotMPSHISEEDFluxRatio(plotStructure, dt, MPSHIElectronFlux, ...
%    averageSEEDEnergy1, averageSEEDEnergy2, ...
%    weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)



%plotMPSHISEEDPolynomialFitRatio(plotStructure, dt, MPSHIElectronFlux, ...
%     averageSEEDEnergy1, averageSEEDEnergy2, ...
%     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)

plotFigure5(plotStructure, dt, MPSHIElectronFlux, ...
     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)

plotFigure6(plotStructure, dt, MPSHIElectronFlux, ...
     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)
 
plotFigure5And6(plotStructure, dt, MPSHIElectronFlux, ...
     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF)


    % [averageCorrectionFactor1, averageCorrectionFactor2, ...
    %     weightedCorrectionFactor1, weightedCorrectionFactor2] = ...
    %     plotMPSHISEEDCorrectedFlux(plotStructure, dt, MPSHIElectronFlux, ...
    %     averageSEEDEnergy1, averageSEEDEnergy2, ...
    %     weightedSEEDFlux1, weightedSEEDFlux2, detectorNumber, savePDF);

% plotMPSHISEEDScatter(plotStructure, dt, averageSEEDEnergy1, ...
%     averageSEEDEnergy2, MPSHIElectronFlux, detectorNumber, savePDF, ...
%     fudgeFactor1, fudgeFactor2)

end  %End of the function plotMPSHIData.m
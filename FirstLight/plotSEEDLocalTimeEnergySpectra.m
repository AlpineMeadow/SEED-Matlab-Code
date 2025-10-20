function plotSEEDLocalTimeEnergySpectra(info, CDFInfo, CDFData)

%This function is called by SEEDFirstLight.m.  It will take a set of days
%and bin them into local time bins and make energy spectra plots for those
%local time bins. 

%Create a flag for whether or not to save the plots as pdfs.
savePDF = 1;

%Set up a smoothing constant for the smoothdata function called in the
%interpolateSEEDCounts.m function
smoothConstant = 0;

%Determine the number of days being analyzed.
numMissionDays = length(CDFData);

%Concatinate the SEED data into arrays.
[dt, timeStructure, SEEDInterpolatedTime, ...
    SEEDInterpolatedCounts] = concatSEEDData(info, CDFData, smoothConstant);

%Let us find the size of the counts array.
[numEvents, numEnergyBins] = size(SEEDInterpolatedCounts);

%Generate a cell array(because the different columns are different sizes so
%we cannot use a matrix) of indices that correspond to the 24 hours in a
%day.  We want these so that we can separate out the spectra as a function
%of local time.
hourIndices = getSEEDHourIndices(info, timeStructure, numMissionDays);

%Now we sum the counts into an array of [numDays, numEnergyBins].
summedCounts = zeros(24, numEnergyBins);

%Now combine the temporal information for each hour.
for hourIndex = 1 : 24
    normalizationFactor = (1.0/length(hourIndices{hourIndex}));
    for energy = 1 : numEnergyBins
        temp = sum(SEEDInterpolatedCounts(hourIndices{hourIndex}, energy), ...
            'omitnan');
        summedCounts(hourIndex, energy) = normalizationFactor*temp;
    end  %End of for loop - for energy = 1 : numEnergyBins
end  %End of for loop - for hours = 1 : 24

%Convert the SEED counts to flux.
newSEEDFlux = getSEEDFlux5(info, summedCounts);


SEEDFlux = newSEEDFlux.deltat15FluxActual;
%Make energy spectra plots of each local time bin.
plotMultipleSEEDEnergySpectra(info, numEnergyBins, newSEEDFlux)

%plotSingleSEEDEnergySpectra(info, numEnergyBins, newSEEDFlux)


end  %End of the function plotSEEDLocalTimeEnergySpectra.m
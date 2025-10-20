function [counts, flux] = fixHighDataPoints(counts, flux, sigmaMultiple)

%This function is called by concatGOESSEEDData.m
%Let us replace the huge count values in the SEEDElectronCounts with
%smaller values.

%Determine the number of energy channels.
[numEvents, numEnergyChannels] = size(counts);

%Loop through the energy channels.
for e = 1 : numEnergyChannels
    meanCounts = mean(counts(:, e));
    stdCounts = std(double(counts(:, e)));
    highCounts = meanCounts + sigmaMultiple*stdCounts;

    meanFlux = mean(flux(:, e));
    stdFlux = std(flux(:, e));
    highFlux = meanFlux + sigmaMultiple*stdFlux;

    highCountIndex = find(counts(:, e) > highCounts);
    highFluxIndex = find(flux(:, e) > highFlux);

    if length(highCountIndex) > 0
        counts(highCountIndex, e) = meanCounts;
    else
        continue
    end  %End of if-else clause - if length(highCountsIndex) > 0

    if length(highFluxIndex) > 0
        flux(highFluxIndex, e) = meanFlux;
    else
        continue
    end %End of if-else clause - if length(highFluxIndex > 0

end  %End of for loop - for e = 1 : numEnergyChannels

end  %End of the function fixHighDataPoints.m
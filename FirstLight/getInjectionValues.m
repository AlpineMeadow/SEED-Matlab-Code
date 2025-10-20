function [maFlux, maStd, injectionValues] = ...
    getInjectionValues(info, SEEDElectronFlux, stepsToSkip, movingAverageLength, ...
    sigmaValue, d)



%Determine the number of data points and energy bins.
[numDataPoints, numEnergyBins] = size(SEEDElectronFlux);

maFlux = zeros(numDataPoints, numEnergyBins);
maStd = zeros(numDataPoints, numEnergyBins);
maFluxPlus = zeros(numDataPoints, numEnergyBins);

injectionValues = cell(numEnergyBins, 1);

%Generate a vector that will hold locations for which the flux is greater
%than earlier flux values.  These locations will indicate the injection
%times.
injectionFlag = zeros(numDataPoints, numEnergyBins);

%Loop through the energy bins.
for energyBin = 1 : numEnergyBins

    %Calculate the moving mean and moving standard deviation for the electron
    %flux.
    maFlux(:, energyBin) = movmean(SEEDElectronFlux(:, energyBin), movingAverageLength);
    maStd(:, energyBin) = movstd(SEEDElectronFlux(:, energyBin), movingAverageLength);

    %Generate a vector of fluxes plus standard deviations.
    maFluxPlus(:, energyBin) = maFlux(:, energyBin) + sigmaValue*maStd(:, energyBin);

    %Loop through the data points checking to see if the flux at point
    %t_{i+stepsToSkip} is larger than the flux at t_{i}.  If the flux is larger
    %then set that point to one in the injectionFlag vector.
    for i = 1 : numDataPoints - stepsToSkip

        if energyBin == 10
            j = 1;
        end

        testValue = maFluxPlus(i, energyBin);
        forwardIndex = i + stepsToSkip;

        if  testValue < maFlux(forwardIndex, energyBin)
            injectionFlag(forwardIndex, energyBin) = 1;
        else
            continue
        end %End of if-else clause - if testValue < maFlux(forwardIndex)
    end  %End of for loop - for i = 1 : numDataPoints - stepsToSkip


    %Find the injectionFlag values that are equal to one.
    injectionsIndex = find(injectionFlag(:, energyBin) == 1);

    if length(injectionsIndex) == 0
%        disp(['No injections found at energy : ', num2str(energyBin), ' keV'])
    else

        %Now we pick the first injection value.
        firstInjectionValueIndex = injectionsIndex(1);

        %Now diff the injection index values.
        injectionDiff = diff(injectionsIndex);

        %Now get the other values.
        otherInjectionValuesIndex = find(injectionDiff > 10);

        if length(otherInjectionValuesIndex >= 1)
            injectionValues{energyBin} = cat(1, firstInjectionValueIndex, ...
                injectionsIndex(otherInjectionValuesIndex));
        else
            injectionValues{energyBin} = firstInjectionValueIndex;
        end  %End of if-else clause - if length(otherInjectionValues >= 1)

    end %End of if-else clause -  if length(injections) == 0  
        
        
end % End of for loop - for energyBin = 1 : numEnergyBins

ii = zeros(1, numEnergyBins);
for i = 1 : numEnergyBins


    if length(injectionValues{i}) ~= 0
%        disp(['Injection Value (first entry) : ', ...
%            num2str(injectionValues{i}(1))])
        ii(i) = injectionValues{i}(1);
    else
        ii(i) = 0;
    end
end

injection10 = find(injectionFlag(:,10) == 1);
plot(d(injection10), maFlux(injection10, 10), 'r*', d, maFlux(:, 10), 'b')


end  %End of the function getInjectionValues.m
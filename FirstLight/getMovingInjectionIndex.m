function movingInjectionIndex = getMovingInjectionIndex(SEEDElectronFlux, ...
    energyBin, sigmaValue, stepsToSkip, movingAverageLength, dt)

%This function is called by plotSEEDFirstLightTimeSeries.m.  This function
%will return an index that will be used to plot the location of electron
%injections.  

%Determine the number of data points and energy bins.
[numDataPoints, numEnergyBins] = size(SEEDElectronFlux);



injectionValues = cell(numEnergyBins, 1);

%Loop through the energy bins.
for energyBin = 1 : numEnergyBins

    %Generate a vector that will hold locations for which the flux is greater
    %than earlier flux values.  These locations will indicate the injection
    %times.
    InjectionFlag = zeros(numDataPoints);

    %Calculate the moving mean and moving standard deviation for the electron
    %flux.
    maFlux = movmean(SEEDElectronFlux(:, energyBin), movingAverageLength);
    maStd = movstd(SEEDElectronFlux(:, energyBin), movingAverageLength);

    %Generate a vector of fluxes plus standard deviations.
    maFluxPlus = maFlux + sigmaValue*maStd;

    %Loop through the data points checking to see if the flux at point
    %t_{i+stepsToSkip} is larger than the flux at t_{i}.  If the flux is larger
    %then set that point to one in the InjectionFlag vector.
    for i = 1 : numDataPoints - stepsToSkip

        testValue = maFluxPlus(i);
        forwardIndex = i + stepsToSkip;

        if  testValue < maFlux(forwardIndex)
            InjectionFlag(forwardIndex) = 1;
        else
            continue
        end %End of if-else clause - if testValue < maFlux(forwardIndex)
    end  %End of for loop - for i = 1 : numDataPoints - stepsToSkip


    %Find the InjectionFlag values that are equal to one.
    injectionsIndex = find(InjectionFlag == 1);

    if length(injectionsIndex) == 0
        disp(['No injections found at energy : ', num2str(energyBin), ' keV'])
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
        disp(['Injection Value (first entry) : ', num2str(injectionValues{i}(1))])
        ii(i) = injectionValues{i}(1);
    else
        ii(i) = 0;
    end
end

plot(ii)
grid on
xlabel('Energy Bin')
ylabel('Arrival Time')

d = datenum(dt);

%plot(1:1163, maFlux, 'b', 1:1163, SEEDElectronFlux(:, energyBin), 'g', 1:1163, maFluxPlus, 'r')
plot(d, maFlux, 'b', d, SEEDElectronFlux(:, energyBin), 'g', d, maFluxPlus, 'r')
hold on
plot(d(InjectionFlag == 1), maFlux(InjectionFlag == 1), 'b*')


end  %End of the function getMovingInjectionIndex.m
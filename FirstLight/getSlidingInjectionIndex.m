function [saBoundaries, slidingInjectionIndex1] = getSlidingInjectionIndex(SEEDElectronFlux, ...
    energyBin1, sigmaValue, stepsToSkip, slidingAverageLength, dt)

%This function is called by plotSEEDFirstLightTimeSeries.m.  This function
%will return an index that will be used to plot the location of electron
%injections.  

%Set up a vector of values that will contain the start of the sliding average
%bins.
slidingAverageBins = 1 : slidingAverageLength : length(dt);

%Determine the length of the vector of values.
numDataChunks = length(slidingAverageBins);


%Preallocate some arrays and vectors.
saBoundaries = zeros(2, numDataChunks);
saFlux = zeros(1, numDataChunks);
stdFlux = zeros(1, numDataChunks);

%Loop through the data bins.
for i = 1 : numDataChunks

    %Set up the starting and ending values of the bins.
    startBin = slidingAverageBins(i);
    endBin = slidingAverageBins(i) + slidingAverageLength - 1;

    %Check to ensure that the last bin does not go beyond the length of the
    %vector.  If it does reset the last bin value to the length of the
    %vector.
    if endBin > length(dt)
        endBin = length(dt);
    end

    %Fill the sliding average boundary values.
    saBoundaries(1, i) = startBin;
    saBoundaries(2, i) = endBin;

    %Calculate the mean and standard deviation of the flux in the bins.
    saFlux(i) = mean(SEEDElectronFlux(startBin : endBin, ...
        energyBin1));
    stdFlux(i) = std(SEEDElectronFlux(startBin : endBin, ...
        energyBin1));
end

%Generate a vector of values that will hold the index of bins to be
%compared.
compareIndex = 1 : numDataChunks - stepsToSkip;

%Check to see that the last value of compareIndex does not overflow the
%array.
if compareIndex(end) + stepsToSkip - 1 > numDataChunks
    compareIndex(end) = numDataChunks;
end

%Now compare the values of the sliding average flux.
%Set up a flag to indicate a large change in flux.
injectionFlag = zeros(1, length(compareIndex));

%Loop through the fluxes using the compareIndex values.
for i = 1 : length(compareIndex) - 1
    testValue1 = sigmaValue*stdFlux(compareIndex(i)) + saFlux(compareIndex(i));
    forwardIndex = compareIndex(i) + stepsToSkip - 1;

    if  testValue1 < saFlux(forwardIndex)
        injectionFlag(i) = 1;
    else
        continue
    end
end

%Set the locations of the injection.  We do this by choosing only
%compareIndex values set to one in the previous loop and then we add the
%number of steps we skipped.
injectionIndex = compareIndex(injectionFlag > 0) + stepsToSkip;

%Finally convert the injectionIndex values to the actual sliding average
%boundaries.
slidingInjectionIndex1 = saBoundaries(1, injectionIndex);

end  %End of the function getSlidingInjectionIndex.m
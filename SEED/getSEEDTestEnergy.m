function [energyBins, newSEEDCounts] = getSEEDTestEnergy(info, SEEDCounts)

%This function is called by FalconSEEDTestSpectrogram.m
%This function is written to look at how we pick out the data points we
%will be using.  One possibility is that we look at all of the data.  The
%second is that we only look at data that has a delta t = 15 seconds.

%Find the number of energy bins.
energyBins = info.energyBins;
[newNumEnergyBins, ~] = size(energyBins);

%Set the energy bins variable.
energyBins = info.energyBins;

%Find the number of temporal events in the data.
[numRawEvents, ~] = size(SEEDCounts.rawData);
[num15Events, ~] = size(SEEDCounts.deltat15Data);

%Allocate arrays for the new counts of each type of data.
newSEEDRawCounts = zeros(numRawEvents, newNumEnergyBins);
newSEED15Counts = zeros(num15Events, newNumEnergyBins);

%Determine the final energy bin number.
endEnergyBinNumber = newNumEnergyBins;

%Now add the counts in the summed energy bins.
%Loop through the energies, combining according to user input.
for t = 1 : numRawEvents

    %Create a energy bin counter variable.
    j = 1;

    %Loop through the energies, combining according to user input.
    for i = info.startEnergyBinNumber : info.numEnergyBinsToSum : endEnergyBinNumber - info.numEnergyBinsToSum
        tempRaw = SEEDCounts.rawData;
        newSEEDRawCounts(t, j) = sum(tempRaw(t, i : i + info.numEnergyBinsToSum - 1));

        %Increment the counter.
        j = j + 1;

    end  %End of for loop - for i = startEnergyBinNumber : numEnergyBinsToSum : endEnergyBinNumber
end  %End of for loop - for t - 1 : numEvents


%Now add the counts in the summed energy bins.
%Loop through the energies, combining according to user input.
for t = 1 : num15Events

    %Create a energy bin counter variable.
    j = 1;

    %Loop through the energies, combining according to user input.
    for i = info.startEnergyBinNumber : info.numEnergyBinsToSum : endEnergyBinNumber - info.numEnergyBinsToSum
        temp15 = SEEDCounts.deltat15Data;
        newSEED15Counts(t, j) = sum(temp15(t, i : i + info.numEnergyBinsToSum - 1));

        %Increment the counter.
        j = j + 1;

    end  %End of for loop - for i = startEnergyBinNumber : numEnergyBinsToSum : endEnergyBinNumber
end  %End of for loop - for t - 1 : numEvents

%Fill the counts structure.
newSEEDCounts.rawData = newSEEDRawCounts;
newSEEDCounts.deltat15Data = newSEED15Counts;

end  %End of the function getSEEDEnergyBins.m
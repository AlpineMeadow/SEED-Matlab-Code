function newSEEDCounts = getSEEDEnergy(info, SEEDCounts)

%This function is called by FalconSEEDGeneralSpectrogram.m and
%FalconSEEDSummarySpectrogram.m.
%This function will sum the counts in the energy channels over which the
%user wants to combine energies.

%Set the energy bins variable.
energyBins = info.energyBins;
[newNumEnergyBins, ~] = size(energyBins);

%Find the number of energy bins.
[numEvents, oldNumEnergyBins] = size(SEEDCounts);

%Allocate memory for a new SEED Counts array.
newSEEDCounts = zeros(numEvents, newNumEnergyBins);

%Determine the final energy bin number.
endEnergyBinNumber = newNumEnergyBins;


start = 1;
step = info.numEnergyBinsToSum;
stop = oldNumEnergyBins - step;

%Now add the counts in the summed energy bins.
%Loop through the energies, combining according to user input.
for t = 1 : numEvents

    %Loop through the energies, combining according to user input.
    for i = 1 : newNumEnergyBins
        lowIndex = start + step*(i - 1);
        highIndex = start + step*i - 1;

        if highIndex > oldNumEnergyBins
            highIndex = oldNumEnergyBins;
        end

        newSEEDCounts(t, i) = sum(SEEDCounts(t, lowIndex : highIndex));

    end  %End of for loop - for i = 1 : newNumEnergyBins
end  %End of for loop - for t - 1 : numEvents

end  %End of the function getSEEDEnergy.m
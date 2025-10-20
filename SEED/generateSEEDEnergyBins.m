function energyBins = generateSEEDEnergyBins(startEnergyBinNumber, ...
    numEnergyBinsToSum)

%This function is called by generateSEEDInformation.m

%Generate the energy bins.  The values are in keV.  The delta E, number of 
%energy bins and offset are determined from the paper.
deltaEnergy = 0.1465;  %In units of keV.
energyBinOffset = -3.837;  %In units of keV.
numEnergyBins = 1024;

%Set up energy bins.
energyBinValues = startEnergyBinNumber : numEnergyBinsToSum : numEnergyBins;
newNumberEnergyBins = length(energyBinValues);

%Allocate memory for the new energy bins.
energyBins = zeros(newNumberEnergyBins, 4);

%Create a counter variable.
j = 1;

%Loop through the energies, combining according to user input.
for i = startEnergyBinNumber : numEnergyBinsToSum : numEnergyBins
    %Determine the center energy.
    ECenter = deltaEnergy*i + energyBinOffset;

    %Determine the low energy boundary.
    ELow = ECenter - numEnergyBinsToSum*deltaEnergy/2.0;

    %Determine the high energy boundary.
    EHigh = ECenter + numEnergyBinsToSum*deltaEnergy/2.0;

    %Determine the energy bin width.
    energyBinWidth = numEnergyBinsToSum*deltaEnergy;

    %Fill the energy bin array.
    energyBins(j, 1) = ELow;
    energyBins(j, 2) = ECenter;
    energyBins(j, 3) = EHigh;
    energyBins(j, 4) = energyBinWidth;

    %Increment the counter.
    j = j + 1;

end  %End of for loop - for i = startEnergyBinNumber : numEnergyBinsToSum : endEnergyBinNumber

end %End of function getnerateSEEDEnergyBins.m
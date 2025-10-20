function [AverageSEEDEnergy1, AverageSEEDEnergy2] = ...
    generateAverageSEEDEnergy(firstEnergyBin, secondEnergyBin, ...
    numChannelsToSum, smoothConstant, newSEEDFlux)


halfRange = round(numChannelsToSum/2.0);
lowerBinNumber1 = firstEnergyBin - halfRange;
higherBinNumber1 = firstEnergyBin + halfRange;
lowerBinNumber2 = secondEnergyBin - halfRange;
higherBinNumber2 = secondEnergyBin + halfRange;

AverageSEEDElectronEnergy1 = sum(newSEEDFlux.deltat15FluxActual(:, ...
    lowerBinNumber1 : higherBinNumber1), 2)/numChannelsToSum;
AverageSEEDElectronEnergy2 = sum(newSEEDFlux.deltat15FluxActual(:, ...
    lowerBinNumber2 : higherBinNumber2), 2)/numChannelsToSum;

%Now lets try some smoothing.
if smoothConstant > 0
    AverageSEEDEnergy1 = smoothdata(AverageSEEDElectronEnergy1, ...
        'gaussian', smoothConstant);
    AverageSEEDEnergy2 = smoothdata(AverageSEEDElectronEnergy2, ...
        'gaussian', smoothConstant);
else
    AverageSEEDEnergy1 = smoothdata(AverageSEEDElectronEnergy1);
    AverageSEEDEnergy2 = smoothdata(AverageSEEDElectronEnergy2);

end

end  %End of the function generateAverageSEEDEnergy.m
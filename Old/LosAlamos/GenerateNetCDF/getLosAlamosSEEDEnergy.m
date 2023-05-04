function energyBins = getLosAlamosSEEDEnergy()

%  This function is called by LosAlamosNetCDFFiles.m.  It generates the
%  energy bins for the SEED instrument.


%Generate the energy bins.  The values are in keV.  The delta E, number of 
%energy bins and offset are determined from the paper.
deltaEnergy = 0.1465;  %In units of keV.
energyBinOffset = -3.837;  %In units of keV.
numEnergyBins = 1024;

%Allocate memory for the new energy bins and the new counts array.
energyBins = [1:numEnergyBins]*deltaEnergy + energyBinOffset;

end  %End of function getSEEDEnergyLosAlamos.m
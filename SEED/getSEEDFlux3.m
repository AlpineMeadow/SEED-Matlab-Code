function [flux] = getSEEDFlux3(info, energyBins, SEEDCounts)

%This function is called by FalconSEEDFlux.m

%Determine the size of the counts array.
[numEvents, numEnergyBins] = size(SEEDCounts);

%Determine the energy bin width.
deltaE = energyBins(1, 4);  %Units are in keV.

%The quantity of (delta t)/t is a constant so we will calculate it here.
%We are interested in the square of this quantity so I will actually
%calculate just that value.
deltaTOverTSq = (info.deltaT/info.timeBinWidth)^2;

%The quantity of (delta g)/g is a constant so we will calculate it here.
%We are interested in the square of this quantity so I will actually
%calculate just that value.
deltaGOverGSq = (info.deltaG/info.g)^2;

%Allocate an array for the fluxes.  I will make an array for the lower
%estimate of the flux uncertainty, an array for the actual flux and an
%array for the upper estimate of the flux uncertainty.  I will then combine
%these array into a structure I will call flux.
fluxLow = zeros(numEvents, numEnergyBins);
fluxHigh = zeros(numEvents, numEnergyBins);

%The flux is detemined from the counts by dividing the counts by the
%energy, time and geometric factor.  Since none of these are time or energy
%dependent I do not need to loop over any of the quantities.
fluxActual = SEEDCounts./(deltaE*info.deltaT*info.g);

%Now calculate the uncertainties.
for t = 1 : numEvents
    for e = 1 : numEnergyBins

        %Calculate the energy uncertainty squared.
        deltaEOverESq = (deltaE/energyBins(e, 2))^2; 

        %Calculate the flux uncertainty.
        sigmaF = fluxActual(t, e)/4.0*sqrt(deltaGOverGSq + deltaTOverTSq + ...
            deltaEOverESq + 4.0/SEEDCounts(t, e));

        %Now estimate the uncertainties.
        fluxLow(t, e) = fluxActual(t, e) - sigmaF;
        fluxHigh(t, e) = fluxActual(t, e) + sigmaF;

    end  %End of for loop - for e = 1 : numEnergyBins
end  %End of for loop - for t = 1 : numEvents

%Fill the flux structure.
flux.fluxLow = fluxLow;
flux.fluxActual = fluxActual;
flux.fluxHigh = fluxHigh;

end  %End of the function getSEEDFlux.m
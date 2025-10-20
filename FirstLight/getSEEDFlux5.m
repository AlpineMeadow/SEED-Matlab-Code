function flux = getSEEDFlux5(info, Counts)
%This function is called by plotSEEDLocalTimeEnergySpectra.m.  It will
%calculate the SEED flux from the SEED counts.

energyBins = info.energyBins;
delta15Counts = Counts;

%In order to calculate the error estimate we need to divide by the counts.
%This will cause a NaN result if the counts are ever zero.  Lets set all
%zero level counts to one.
delta15Counts(delta15Counts <= 0) = 1;

%Get the geometric factor.
geometricFactor = info.g;

%Determine the size of the counts array.
[delta15NumEvents, numEnergyBins] = size(delta15Counts);

%Determine the energy bin width.
deltaE = info.energyBins(1, 4);  %Units are in keV.

%Now find the difference between the rows.  Since we are using the delta t
%= 15 data we know that the time difference is 15 seconds.
timeDifference15 = 15.0*ones(1, delta15NumEvents);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%I do not know what the timeBinWidth is anymore.  The instrument is
%integrating.  
%deltaTOverTSq = (timeDifference./info.timeBinWidth).^2;
deltaTOverTSq = 1.0;

%The quantity of (delta g)/g is not a constant so we will calculate it here.
%We are interested in the square of this quantity so I will actually
%calculate just that value.
%deltaG is equal to 1/2 of the precision of the value from the paper. I 
%place the delta G value at 0.5e-6 cm^2 st.
deltaGOverGSq = (info.deltaG./info.g).^2;

%Allocate an array for the fluxes.  I will make an array for the lower
%estimate of the flux uncertainty, an array for the actual flux and an
%array for the upper estimate of the flux uncertainty.  I will then combine
%these array into a structure I will call flux.
deltat15FluxLow = zeros(delta15NumEvents, numEnergyBins);
deltat15FluxActual = zeros(delta15NumEvents, numEnergyBins);
deltat15FluxHigh = zeros(delta15NumEvents, numEnergyBins);

%Now calculate the uncertainties.
for e = 1 : numEnergyBins

    %Calculate the energy uncertainty squared.
    deltaEOverESq = (deltaE/energyBins(e, 2))^2;

    %Loop over the delta t = 15 seconds events.
    for t = 1 : delta15NumEvents

        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  
        delta15CountsToFlux = 1.0/(deltaE*geometricFactor(e)*timeDifference15(t));
        deltat15FluxActual(t, e) = delta15CountsToFlux*delta15Counts(t, e);

        %Calculate the flux uncertainty.
        deltat15SigmaF = (deltat15FluxActual(t, e)/4.0)*sqrt(deltaGOverGSq(e) + deltaTOverTSq + ...
            deltaEOverESq + 4.0/delta15Counts(t, e));

        %Now calculate the flux uncertainties.
        deltat15FluxLow(t, e) = deltat15FluxActual(t, e) - deltat15SigmaF;
        deltat15FluxHigh(t, e) = deltat15FluxActual(t, e) + deltat15SigmaF;
    end  %End of for loop - for t = 1 : delta15NumEvents.

end  %End of for loop - for e = 1 : numEnergyBins

%Fill the flux structure.
flux.deltat15FluxLow = deltat15FluxLow;
flux.deltat15FluxActual = deltat15FluxActual;
flux.deltat15FluxHigh = deltat15FluxHigh;

end  %End of the function getSEEDFlux5.m
function flux = getSEEDFlux2(info, time, Counts) 

%This function is called by FalconSEEDGeneralSpectrogram.m


energyBins = info.energyBins;

%In order to calculate the error estimate we need to divide by the counts.
%This will cause a NaN result if the counts are ever zero.  Lets set all
%zero level counts to one.
Counts(Counts <= 0) = 1;

%Get the geometric factor.
geometricFactor = info.g;

%Determine the size of the counts array.
[numEvents, numEnergyBins] = size(Counts);

%Determine the energy bin width.
deltaE = info.deltaE;  %Units are in keV.

%Now find the difference between the rows.
orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.
timeDifference = diff(time.eventSeconds);
timeDifference = [timeDifference(1); timeDifference];

%The quantity of (delta t)/t is not a constant so we will calculate it here.
%We are interested in the square of this quantity so I will actually
%calculate just that value.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%I do not know what the timeBindWidth is anymore.  The instrument is
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
fluxLow = zeros(numEvents, numEnergyBins);
fluxActual = zeros(numEvents, numEnergyBins);
fluxHigh = zeros(numEvents, numEnergyBins);

cToF = zeros(numEvents, numEnergyBins);

%Now calculate the uncertainties.
for e = 1 : numEnergyBins

    %Calculate the energy uncertainty squared.
    deltaEOverESq = (deltaE./energyBins(e, 2)).^2;


    %Loop over the events.
    for t = 1 : numEvents

        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  
        countsToFlux = 1.0/(deltaE*geometricFactor(e)*timeDifference(t));
        cToF(t, e) = countsToFlux;

%        disp(['size of CountsToFlux : ', num2str(size(countsToFlux))])
        
        fluxActual(t, e) = countsToFlux*Counts(t, e);

        %Calculate the flux uncertainty.
        sigmaF = (fluxActual(t, e)/4.0)*sqrt(deltaGOverGSq(e) + deltaTOverTSq + ...
            deltaEOverESq + 4.0/Counts(t, e));
        
        %Now estimate the uncertainties.
        fluxLow(t, e) = fluxActual(t, e) - sigmaF;
        fluxHigh(t, e) = fluxActual(t, e) + sigmaF;

    end  %End of for loop - for t = 1 : rawNumEvents.       
end  %End of for loop - for e = 1 : numEnergyBins

%Fill the flux structure.
flux.fluxLow = fluxLow;
flux.fluxActual = fluxActual;
flux.fluxHigh = fluxHigh;

% 
% plot(1500:2000, 2.0e-5*fluxActual(1500:2000, 20), 'b', 1500:2000, timeDifference(1500:2000), 'g', 1500:2000, 0.022*Counts(1500:2000, 20), 'r')
% plot(1500:2000, 2.0e-5*fluxActual(1500:2000, 20), 'b', 1500:2000, timeDifference(1500:2000), 'g', 1500:2000, 0.122*Counts(1500:2000, 20), 'r')
% plot(1500:2000, 2.0e-5*fluxActual(1500:2000, 20), 'b', 1500:2000, timeDifference(1500:2000), 'g', 1500:2000, 0.222*Counts(1500:2000, 20), 'r')
% ylim([0, 400])
% plot(1500:2000, 2.0e-5*fluxActual(1500:2000, 20), 'b-*', 1500:2000, timeDifference(1500:2000), 'g-*', 1500:2000, 0.222*Counts(1500:2000, 20), 'r-*')
% ylim([0, 600])
% timeDifference(1624)

end  %End of the function getSEEDFlux2.m
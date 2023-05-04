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
fluxActual = zeros(numEvents, numEnergyBins);


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

     
        
        fluxActual(t, e) = countsToFlux*Counts(t, e);

    end  %End of for loop - for t = 1 : rawNumEvents.       
end  %End of for loop - for e = 1 : numEnergyBins

%Fill the flux structure.
flux.fluxActual = fluxActual;


end  %End of the function getSEEDFlux1.m
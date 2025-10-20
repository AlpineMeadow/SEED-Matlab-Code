function flux = getCDFSEEDFlux1(info, time, rawCounts, dataTypeFlag) 

%This function is called by makeSEEDLineSpectraMovie.m


energyBins = info.energyBins;

%In order to calculate the error estimate we need to divide by the counts.
%This will cause a NaN result if the counts are ever zero.  Lets set all
%zero level counts to one.
rawCounts(rawCounts <= 0) = 1;

%Get the geometric factor.
geometricFactor = info.g;

%Determine the size of the counts array.
[rawNumEvents, numEnergyBins] = size(rawCounts);

%Determine the energy bin width.
deltaE = info.deltaE;  %Units are in keV.

%Now check to see if we are looking at dt=15 data.

if strcmp(dataTypeFlag, 'dt15Data')
    timeDifference = 15*ones(1, length(time));
else
    %Now find the difference between the rows.
    orderOfDifference = 1;  %This will always be what we want.
    arrayDimension = 1;  %This will always be what we want.
    timeDifferenceRaw = diff(time);
    timeDifference = [timeDifferenceRaw; timeDifferenceRaw(end)];
end

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
fluxLow = zeros(rawNumEvents, numEnergyBins);
fluxActual = zeros(rawNumEvents, numEnergyBins);
fluxHigh = zeros(rawNumEvents, numEnergyBins);
% 
% 
% %Set the figure position information.
% left = 750;
% bottom = 25;
% width = 1200;
% height = 500;
% 
% %Set up the figure handle.
% fig2 = figure();
% fig2.Position = [left bottom width height];
% ax = gca();
% 
% 
% energyBin = 10;
% timeStart = 700;
% timeEnd = 800;
% y = rawCounts(timeStart : timeEnd, energyBin)./timeDifference(timeStart : timeEnd);
% t = 1 : timeEnd - timeStart + 1;
% plot(t, y, 'g-*', t, timeDifference(timeStart : timeEnd), 'b-*', ...
%     t, rawCounts(timeStart : timeEnd, energyBin), 'r-*')
% ylim([0 1500])
% xlim([1 timeEnd-timeStart])
% ylabel('Counts per Second')
% xlabel('Time')
% legend('Counts Per Second', 'Time Difference', 'Counts')
% 

%Now calculate the uncertainties.
for e = 1 : numEnergyBins

    %Calculate the energy uncertainty squared.
    deltaEOverESq = (deltaE/energyBins(e, 2))^2;

    %Loop over the raw events.
    for t = 1 : rawNumEvents

        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  
        rawCountsToFlux = 1.0/(deltaE*geometricFactor(e)*timeDifference(t));
        fluxActual(t, e) = rawCountsToFlux*rawCounts(t, e);

        %Calculate the flux uncertainty.
        rawSigmaF = (fluxActual(t, e)/4.0)*sqrt(deltaGOverGSq(e) + deltaTOverTSq + ...
            deltaEOverESq + 4.0/rawCounts(t, e));
        
        %Now estimate the uncertainties.
        fluxLow(t, e) = fluxActual(t, e) - rawSigmaF;
        fluxHigh(t, e) = fluxActual(t, e) + rawSigmaF;

    end  %End of for loop - for t = 1 : rawNumEvents.       
end  %End of for loop - for e = 1 : numEnergyBins

%Fill the flux structure.
flux.fluxLow = fluxLow;
flux.fluxActual = fluxActual;
flux.fluxHigh = fluxHigh;

end  %End of the function getCDFSEEDFlux1.m


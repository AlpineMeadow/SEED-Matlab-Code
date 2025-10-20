function [fluxAll, flux15] = getCDFFlux1(info, time, Counts, deltaTime) 

%This function is called by SEEDCDF.m  It will convert SEED counts to SEED
%flux.

energyBins = info.energyBins;

%Get the geometric factor.
geometricFactor = info.g;

%Determine the energy bin width.
deltaE = info.deltaE;  %Units are in keV.

%Get the counts out of the Count structure.
differencedCounts = Counts.differencedCounts;
differencedDt15Counts = Counts.differencedDt15Counts;

%I need to check what is happening when I go from counts to flux.
%Something seems to be wrong.  So lets take the original counts and plot
%them.  And then plot the same fluxes.

%The first step is to add up the energy channels.  We call getSEEDEnergy.m
%to accomplish this.  The problem is that getCDFFlux.m(this function) was
%written so that the energy bins were not summed because we want to give
%the maximum number of energy bins.  So that means that in order to compare
%I will have to sum the energy bins in this function.
newSEEDCounts = getSEEDEnergy(info, differencedCounts);
newSEEDCounts15 = getSEEDEnergy(info, differencedDt15Counts);

%Set the figure position information.
left = 750;
bottom = 25;
width = 1200;
height = 500;
fig1 = figure();
set(gcf, 'Position', [left bottom width height]);

plot(450 : 550, 35*newSEEDCounts15(450 : 550, 55), 'g-*', ...
    450 : 550, newSEEDCounts15(450 : 550, 1), 'b-*')
xlabel('Time (arbitrary units)')
ylabel('Counts (arbitrary)')
title('Differenced Counts(delta t = 15 s) versus time for 5 March 2022')
legend(['Energy : ', num2str(info.energyBins(55, 2), '%4.2f'), ' keV'], ...
    ['Energy : ', num2str(info.energyBins(1,2), '%4.2f'), ' keV'])


%In order to calculate the error estimate we need to divide by the counts.
%This will cause a NaN result if the counts are ever zero.  Lets set all
%negative valued count differences to the value prior to going negative.

%First find the negative counts.  Choose energy bin 100 although it does
%not seem to matter which bin I choose since all of the energy channels go
%negative at the same time.
negCountsIndex = find(newSEEDCounts(:, 10) < 0);

%Next get the time index of the count difference just before it goes
%negative.
negCountsIndexPrior = negCountsIndex - 1;

%Finally replace the negative count differences with the count differences
%from just prior to going negative.
newSEEDCounts(negCountsIndex, :) = newSEEDCounts(negCountsIndexPrior, :);

%Determine the size of the counts array.
[numEventsAll, numEnergyBins] = size(newSEEDCounts);
[numEvents15, numEnergyBins] = size(newSEEDCounts15);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Allocate an array for the fluxes. 
fluxAll = zeros(numEventsAll, numEnergyBins);
fluxAll1 = zeros(numEventsAll, numEnergyBins);
flux15 = zeros(numEvents15, numEnergyBins);

%Set up the variable for delta time = 15 seconds.
deltaT = 15.0;

%Now calculate the uncertainties.
for e = 1 : numEnergyBins

    %Loop over the events for the unique data points.
    for t = 1 : numEventsAll
        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  The deltaTime values are 64
        %bit integers and so we need to convert them to doubles.
        countsToFluxAll = 1.0/(deltaE*geometricFactor(e)*double(deltaTime(t)));
        fluxAll(t, e) = countsToFluxAll*differencedCounts(t, e);
        fluxAll1(t, e) = countsToFluxAll*newSEEDCounts(t, e);

    end  %End of for loop - for t = 1 : rawNumEvents.       

    %Loop over the events for the delta t = 15 data points.
    
    for t = 1 : numEvents15
        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  
        countsToFlux = 1.0/(deltaE*geometricFactor(e)*deltaT);
%        disp(['Conversion Factor : ', num2str(countsToFlux)])
        flux15(t, e) = countsToFlux*differencedDt15Counts(t, e);

    end  %End of for loop - for t = 1 : rawNumEvents.       
end  %End of for loop - for e = 1 : numEnergyBins

end  %End of the function getSEEDFlux1.m

function [newTime, counts] = getUniqueDifferencedTestData(info, time, SEEDCounts)

%This function is called by FalconSEEDTestSpectrogram.m
%This function will return two structures.  The time structure will hold
%the times in event seconds and date numbers for the counts to be plotted.
%The counts structure will hold the raw counts(that is counts that have
%only been held for uniqueness.) and counts that have a delta t = 15
%seconds.  These will be called counts.rawData and counts.deltat15Data
%respectively.


[numEvents, numEnergyBins] = size(SEEDCounts);

% Start and stop times of data as "seconds of day"
rawTime = time.eventSeconds;
tstart = rawTime(1);
tend = rawTime(end);

%Pull the SEED data out of the data structure.
rawSEEDData = SEEDCounts;

%We need to get rid of the potentially 15 multiples(in time) of the energy
%spectra.  Here I am choosing without much data to look at energy channel
%number 150.  This should not matter but it very well may matter. 
%This next section investigates how choosing a particular energy bin value
%gives out different numbers of unique values.  The lower the energy the
%more unique values we have.  
%Choose some random energy bin values.
energyBin1 = 130;
energyBin2 = 160;
energyBin3 = 200;
uniqueSEEDDataIndex = determineUniqueIndexPerEnergy(rawSEEDData, ...
    energyBin1, energyBin2, energyBin3);

%Use the indices returned by unique to keep only the unique SEED data.
uniqueSEEDData = rawSEEDData(uniqueSEEDDataIndex, :);

%We use the unique SEED Data index to get the unique times.
uniqueTime = rawTime(uniqueSEEDDataIndex);
uniqueDateNumber = time.eventDateNumber(uniqueSEEDDataIndex);

%Lets fill in part of the time structure.
newTime.rawEventSeconds = uniqueTime;
newTime.rawEventDateNumber = uniqueDateNumber;

%Now find the difference between the rows.
orderOfDifference = 1;  %Subtract interval (i + 1) from interval (i).
%This will always be what we want.
arrayDimension = 1;  %The dimension over which the difference will be calculated.
%Here we are always working with vectors which have dimension 1 so this 
%will always be what we want.
countDifference = diff(uniqueSEEDData, orderOfDifference, arrayDimension);

%Now we difference the unique times.  We want to look at the 15 second
%intervals.
timeDifference = diff(uniqueTime, orderOfDifference, arrayDimension);

%Generate a comparison plot between 15 second time intervals only and for
%all time intervals for the differenced counts.
timeDifference15Index = showSEEDTimeIntervals(info, countDifference, timeDifference, uniqueTime, ...
    uniqueDateNumber);

%Now get count difference that corresponds to the delta t = 15.
dt15 = countDifference(timeDifference15Index, :);

%Fill the counts structure.
counts.rawData = countDifference;
counts.deltat15Data = dt15;

%Do the same for the time structure.
eventSeconds15 = uniqueTime(timeDifference15Index)';
eventDateNumber15 = uniqueDateNumber(timeDifference15Index);

%Fill the time structure.
newTime.deltat15EventSeconds = eventSeconds15;
newTime.deltat15EventDateNumber = eventDateNumber15;

%We need to prepend the original first row to the new array.
%counts = [countDifference];

end  %End of the function getUniqueDifferencedTestData.m
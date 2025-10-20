function [uniqueSEEDTime, uniqueSEEDCounts, uniqueDeltaTime] = ...
    getCDFUniqueDifferencedSEEDData(info, TT2000Time, TT2000SEEDCounts)

%This function is called by exportSEEDCDF.m
%This function is also called by generateSEEDCDF.m
%This function will return two structures.  The time structure will hold
%the times in TT2000 time for the unique events as well as unique events
%that have a delta t = 15 seconds.  These will be named
%uniqueSEEDTime.TT2000 and uniqueSEEDTime.dt15TT2000 respectively.
%The counts structure will hold the unique counts and counts that have a
%delta t = 15 seconds.  These will be called
%uniqueSEEDCounts.differencedCounts and
%uniqueSEEDCounts.differencedDt15Counts respectively.

%rawTime is given in nanoseconds since some starting time, which I do not
%know.  I am sure NASA defined it but I cannot find where it is recorded.
%Okay, just checking the values, it looks like TT2000 time is in
%nanoseconds from January 1, 2000.  Presumably midnight but possibly 6 AM.
rawTime = TT2000Time;

%Pull the SEED data out of the data structure.  Here we also limit the
%number of energy channels so as to remove the low energy issues.
rawSEEDData = TT2000SEEDCounts(:, info.startEnergyBinNumber:end);

%We need to get rid of the potentially 15 multiples(in time) of the energy
%spectra.  This next section investigates how choosing a particular energy
%bin value gives out different numbers of unique values.  The lower the
%energy the more unique values we have.  
%Choose some random energy bin values.
energyBin1 = 1;
energyBin2 = 6;
energyBin3 = 9;
uniqueSEEDDataIndex = determineUniqueIndexPerEnergy(rawSEEDData, ...
    energyBin1, energyBin2, energyBin3);

%Use the indices returned by unique to keep only the unique SEED data.
uniqueSEEDData = rawSEEDData(uniqueSEEDDataIndex, :);

%We use the unique SEED Data index to get the unique times.
uniqueTime = rawTime(uniqueSEEDDataIndex);

%We also want the times between data points.  Since the instrument
%integrates we will subtract(diff) the time values.  In order to get
%seconds from nanoseconds we divide by 1e9.
deltaTime = diff(uniqueTime)*1.0e-9;

%We want the delta times to be the same length as the unique data points so
%we need to prepend a delta time onto the diff result.  I will choose 15
%seconds as that time since I have no way of knowing what it actually is
%and it is supposed to be 15 seconds.
uniqueDeltaTime = [15; deltaTime];

%Lets fill in part of the time structure.  These values are in TT2000
%times.
uniqueSEEDTime.TT2000 = uniqueTime;

%Let us also calculate the time intervals associated with the unique times
%determined above.  First lets convert the TT2000 time to seconds.
rawTimeSeconds = 1.0e-9*(rawTime - rawTime(1));

%Now find the difference in time for the counts.
orderOfDifference = 1;  %Subtract interval (i + 1) from interval (i).
arrayDimension = 1;  %The dimension over which the difference will be calculated.
%Here we are working with the rows which has array dimension = 1.
countDifference = diff(uniqueSEEDData, orderOfDifference, arrayDimension);

%Now lets add the first row of uniqueSEEDData to the differenced data in
%countDifference.
countDifference = [uniqueSEEDData(1, :); countDifference];

%Set a lower limit to the differenced counts.
lowerCountsLimit = 0;

%Set the valid minimum and valid maximum values for the SEED instrument.
%These are taken from the CDF master file.
validMin = 0;
validMax = 4294967296;  %This is 2^32

%Get rid of the negative counts.
positiveCountDifference = countDifference;
positiveCountDifference(positiveCountDifference < lowerCountsLimit) = validMin;

%Now we difference the unique times.  We want to look at the 15 second
%intervals.  First we need to get time in seconds from start of the day.
%The factor of 1.0e-9 is due to the fact that TT2000 has time in
%nanoseconds-> 1 second = 1e9 nanoseconds.
timeSeconds = 1.0e-9*(uniqueTime - uniqueTime(1));
timeDifference = diff(timeSeconds, orderOfDifference, arrayDimension);
timeDifference = [15; timeDifference];

%Find indices that have time differences around 15 seconds.
timeDifference15Index = find(timeDifference > 0.0 & timeDifference < 30.0);

%Generate a comparison plot between 15 second time intervals only and for
%all time intervals for the differenced counts.
%timeDifference15Index = showSEEDTimeIntervals(info, countDifference, ...
%   timeDifference, uniqueTime, uniqueDateNumber);

%Now get count difference that corresponds to the delta t = 15.
dt15 = positiveCountDifference(timeDifference15Index, :);

%Fill the counts structure.
uniqueSEEDCounts.differencedCounts = countDifference;
uniqueSEEDCounts.differencedDt15Counts = dt15;

%Do the same for the time structure.
eventSeconds15 = uniqueTime(timeDifference15Index)';

%Fill the time structure.
uniqueSEEDTime.dt15TT2000 = eventSeconds15;

end  %End of the function getCDFUniqueDifferencedSEEDData.m
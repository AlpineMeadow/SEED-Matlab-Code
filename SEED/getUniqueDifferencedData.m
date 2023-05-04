function [time, counts] = getUniqueDifferencedData(info, time, rawCounts)

%This function is called by FalconSEEDSummary.m


%We need to get rid of the potentially 15 multiples(in time) of the energy
%spectra.
[C, uniqueSEEDDataIndex, ic] = unique(rawCounts(:, 100), 'rows', 'stable');

%Use the indices returned by unique to keep only the unique SEED data.
uniqueSEEDData = rawCounts(uniqueSEEDDataIndex, :);

%We use the unique SEED Data index to get the unique times.
time.eventSeconds = time.eventSeconds(uniqueSEEDDataIndex);

%We do the same for the datenum values.
time.eventDateNumber = time.eventDateNumber(uniqueSEEDDataIndex);


%Now we difference the data.

%Now find the difference between the rows.
orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.
countDifference = diff(uniqueSEEDData, orderOfDifference, arrayDimension);

%We need to prepend the original first row to the new array.
counts = [uniqueSEEDData(1,:); countDifference];
oneCounts = counts;

%Now set any negative differences to zero.  This may not be what we want to
%do.  Lets look at how it looks. 
%counts(counts < 0) = 0;
oneCounts(oneCounts < 0) = 1;

%Now let us fix the negative counts.  
counts = fixNegativeSEEDCounts(counts);

end  %End of the function getUniqueDifferencedData.m
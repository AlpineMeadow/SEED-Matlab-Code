function newCounts = fixNegativeSEEDCounts(counts);

%This function is called by getUniqueDifferencedData.m.  It will replace
%artificially negative counts with counts from the next time instance.
%This is not perfect but it is the best that can be done at least for now.

%The problem in the SEED analysis is that we need to take differences
%between the temporal data points.  This is fine but at various points in
%data acquisition the data stream is reset.  Then when a difference is
%calculated the result is negative points.  These are not physical, so we
%want to get rid of them.

%The question of what to replace these negative data points arises.  A
%simple solution is to just replace the bad data point with the point
%before it.  Another solution is to use the data point before the bad point
%to act as the mean of a Poisson distribution and draw the replacement data
%point from a Poisson distribution of that mean.  I am not sure which is
%the best to do but I will discuss with Geoff and Tony.

%The data comes in an array of [rows, cols] = [time, energy bins], that is
%the counts vary in time as a function of the rows.  We want to work with
%the rows and put the results for each column.

%First find the number of rows and columns.
[numEvents, numEnergyBins] = size(counts);

%Start by adding the first row to the top of the data array.
countsPlus = [counts(1, :); counts];

%Determine the total number of elements in the new array.
totalNumElements = numel(countsPlus);

%Now use the find function to pick out data entries that correspond to some
%condition.  In our real case this will be data points that are less than
%zero.  Here we will just look for entries greater than 10.
zeroIndex = find(countsPlus < 0);

%Now we will pick values that are directly below the tenIndex values.  I
%don't understand Matlab's process here and the Matlab description is
%completely worthless, however if I add one to the index values I believe
%that the new index will be the same column but one row below.  This is why
%I have added a row to the bottom of the array since any indices from the
%bottom row will return a value of zero.  Whatever.
zeroIndexPlus = zeroIndex - 1;

if zeroIndexPlus(1) == 0
    zeroIndexPlus(1) = 1;
end

%Now replace the data for the original index with the data from the new
%index, which is hopefully one row below the original data.
countsPlus(zeroIndex) = countsPlus(zeroIndexPlus);

%Finally lets get rid of the bottom row so that we go back to the original
%array.
newCounts = countsPlus(2 : numEvents + 1, :);

end  %end of the function fixNegativeSEEDCounts.m
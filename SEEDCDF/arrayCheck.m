%Generate a script that gives understanding about how to replace bad data
%points in the SEED data.

%The problem in the SEED analysis is that we need to take differences
%between the temporal data points.  This is fine but at various points in
%data acquisition the data stream is reset.  Then when a difference is
%calculated the result is negative points.  These are not physical, so we
%want to get rid of them.

%The data comes in an array of [rows, cols] = [time, energy bins], that is
%the counts vary in time as a function of the rows.  We want to work with
%the rows and put the results for each column.

%Start with a magic square.
n = 10;
data = magic(n)

%Add the first row to the top of the data array.
dataPlus = [data(1, :); data];

%Determine the total number of elements in the new array.
totalNumElements = numel(dataPlus);

%Now use the find function to pick out data entries that correspond to some
%condition.  In our real case this will be data points that are less than
%zero.  Here we will just look for entries greater than 10.
tenIndex = find(dataPlus >= 20);

%Now we will pick values that are directly below the tenIndex values.  I
%don't understand Matlab's process here and the Matlab description is
%completely worthless, however if I add one to the index values I believe
%that the new index will be the same column but one row below.  This is why
%I have added a row to the bottom of the array since any indices from the
%bottom row will return a value of zero.  Whatever.
tenIndexPlus = tenIndex - 1;

if tenIndexPlus(1) == 0
    tenIndexPlus(1) = 1;
end

%Now replace the data for the original index with the data from the new
%index, which is hopefully one row below the original data.
dataPlus(tenIndex) = dataPlus(tenIndexPlus);

%Finally lets get rid of the top row so that we go back to the original
%array.
newData = dataPlus(2:n, :);

%Let us check that this whole process produces the desired result.
newData

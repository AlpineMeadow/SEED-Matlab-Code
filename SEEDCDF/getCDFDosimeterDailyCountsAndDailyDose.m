function [dailyCountValues, dailyCountRateValues, dayNums] = ... 
    getCDFDosimeterDailyCountsAndDailyDose(info, TT2000Time, UTCTime, ...
    counts);

%This function is called by exportSEEDCDF.m.  This function outputs the
%integrated counts between roll overs and resets.

%Now find the difference between the rows.
orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.

%Difference the counts.
diffCounts = diff(counts, orderOfDifference, arrayDimension);
	
%Lets find the index for the counts that indicate either a roll over or a reset.
rRI = find(diffCounts <= -10);


%Handle the case when there are no roll overs or resets.  We just sum the
%count differences.
if length(rRI) == 0
    dailyCountValues = sum(diffCounts);
    dailyCountRateValues = dailyCountValues/(UTCTime(end) - UTCTime(1));
    dayNums = UTCTime(1)/86400.0 + datenum(info.startYear, info.startMonth, ...
        info.startDayOfMonth, 0, 0, 0);
    return
end

%Handle the case where there are resets or rollovers.
	
%Handle the case if the first entry in diffCounts is the first
%index.  This should not happen but it does.
if rRI(1) == 1
    %We remove the first difference value.
    diffCounts = diffCounts(2:end);

    %Redo the rRI index.
    rRI = find(diffCounts <= -10);
end

%Find the index just before the rollover or reset.
rolloverResetIndex = rRI - 1;

%Now find the index for the time just after either a roll over or a
%reset.  Prepend the index 1 onto the array so that we can catch the
%first interval.
previousCountRRI = [1; rRI(1 : end - 1) + 1];

%Save the day numbers of the time intervals.
dayNums = UTCTime(previousCountRRI)/86400.0 + datenum(info.startYear, ...
    info.startMonth, info.startDayOfMonth, 0, 0, 0);

%Set up some arrays that will hold the data analysis results.
numDataPoints = length(previousCountRRI);

dailyCountValues = zeros(1, numDataPoints);
dailyCountRateValues = zeros(1, numDataPoints);
deltaT = zeros(1, numDataPoints);

%Loop through all of the data points between each reset or rollover.
for j = 1 : numDataPoints

	%First get the starting and ending indices for the data slice.
	indexEnd = rolloverResetIndex(j) - 1;
	indexStart = previousCountRRI(j);
	
	if indexEnd == 0
		indexEnd = 1;
	end

	%Set up dummy variables that contain the times and differenced
	%counts.
	T = UTCTime(indexStart : indexEnd);
	CD = diffCounts(indexStart : indexEnd);

	%Calculate the time length for each data section.  We will use this
	%to determine the dose rate.
	deltaT(j) = UTCTime(indexEnd) - UTCTime(indexStart);
	
	%Now integrate.  Not sure if this is what we want.
	%Check to see the length of the input vectors.  If they are of length
	%one then do not call trapz.
	if ((indexEnd - indexStart) == 0)
		dailyCountRateValues(j) = CD;
	else
		dailyCountValues(j) = trapz(T, CD);
	end

	%Now determine the count rate values.
	dailyCountRateValues(j) = dailyCountValues(j)/deltaT(j);

end %End of for loop - for j = 1 : length(previousCountRolloverResetIndex)


% 
% dailyDose.channel1 = info.channel1CountsToRads*accumulatedCountValues1;
% dailyDose.channel2 = info.channel2CountsToRads*accumulatedCountValues2;
% dailyDose.channel3 = info.channel3CountsToRads*accumulatedCountValues3;
% dailyDose.channel4 = info.channel4CountsToRads*accumulatedCountValues4;

end  %End of function getDailyCountCountRateValues

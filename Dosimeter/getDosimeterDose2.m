function [totalDosePerDay, dailyDose, dailyDoseRate] = getDosimeterDose2(info, time, ...
    counts, countRate, numTimeEventsPerDay, includedDays)

%This function will calculate the dosimeter dose rate from the dosimeter
%counts.  I will use the procedure developed by Richard and myself to
%determine the counts to dose conversion factor.  This conversion factor is
%located in the info structure.

%This function is called by :
%DailyDosimeterDoseSummary.m,
%WeeklyDosimeterDoseSummary.m, 
%MonthlyDosimeterDoseSummary.m
%YearlyDosimeterDoseSummary.m
%YearToDateDosimeterDoseSummary.m

%Lets make a histogram and plot of the time values.
%dosimeterDoseTimeHistogram(info, rawTime, numTimeEventsPerDay, IncludedDays)
%dosimeterDoseTimeSeries(info, rawTime, numTimeEventsPerDay, IncludedDays, rawDose);

dailyTotalCounts1 = zeros(1, length(numTimeEventsPerDay));
dailyTotalCounts2 = zeros(1, length(numTimeEventsPerDay));
dailyTotalCounts3 = zeros(1, length(numTimeEventsPerDay));
dailyTotalCounts4 = zeros(1, length(numTimeEventsPerDay));

%Add the value zero to the numTimeEventsPerDay vector so that we can use the
%timeEventIndex result to index into the range of events in a given day.
timeEventIndex = [0; numTimeEventsPerDay];

%Here we loop over the days to be analyzed.
for i = 1 : length(numTimeEventsPerDay)

	%Set up a time vector.
	dayTime = time.eventSeconds(timeEventIndex(i) + 1 : timeEventIndex(i + 1));

	%Get the counts for each channel depending on the day in question.
	counts1 = counts.channel1(timeEventIndex(i) + 1 : timeEventIndex(i + 1));
	counts2 = counts.channel2(timeEventIndex(i) + 1 : timeEventIndex(i + 1));
    counts3 = counts.channel3(timeEventIndex(i) + 1 : timeEventIndex(i + 1));
	counts4 = counts.channel4(timeEventIndex(i) + 1 : timeEventIndex(i + 1));

	%Now for each section of data that has either a rollover or a reset we
	%want to integrate the dose.  Here we do channel 1.
	[dailyCountValues1, dailyCountRateValues1, deltaT1] = ...
        getDailyCountCountRateValues(info, dayTime, counts1);

	%Now for each section of data that has either a rollover or a reset we
	%want to integrate the dose.  Here we do channel 2.
	[dailyCountValues2, dailyCountRateValues2, deltaT2] = ...
        getDailyCountCountRateValues(info, dayTime, counts2);

	%Now for each section of data that has either a rollover or a reset we
	%want to integrate the dose.  Here we do channel 3.
	[dailyCountValues3, dailyCountRateValues3, deltaT3] = ...
        getDailyCountCountRateValues(info, dayTime, counts3);

	%Now for each section of data that has either a rollover or a reset we
	%want to integrate the dose.  Here we do channel 4.
	[dailyCountValues4, dailyCountRateValues4, deltaT4] = ...
        getDailyCountCountRateValues(info, dayTime, counts4);

	%Calculate the daily total counts from the daily counts.
	dailyTotalCounts1(i) = sum(dailyCountValues1);
	dailyTotalCounts2(i) = sum(dailyCountValues2);
	dailyTotalCounts3(i) = sum(dailyCountValues3);
	dailyTotalCounts4(i) = sum(dailyCountValues4);

	%Set up the concatenation of the arrays.
	if (i == 1)
		accumulatedCountValues1 = dailyCountValues1;
		accumulatedCountRateValues1 = dailyCountRateValues1;
		deltaTime1 = deltaT1;

		accumulatedCountValues2 = dailyCountValues2;
		accumulatedCountRateValues2 = dailyCountRateValues2;
		deltaTime2 = deltaT2;

		accumulatedCountValues3 = dailyCountValues3;
		accumulatedCountRateValues3 = dailyCountRateValues3;
		deltaTime3 = deltaT3;

		accumulatedCountValues4 = dailyCountValues4;
		accumulatedCountRateValues4 = dailyCountRateValues4;
		deltaTime4 = deltaT4;

	else
		accumulatedCountValues1 = cat(2, accumulatedCountValues1, dailyCountValues1);
		accumulatedCountRateValues1 = cat(2, accumulatedCountRateValues1, dailyCountRateValues1);
		deltaTime1 = cat(2, deltaTime1, deltaT1);

		accumulatedCountValues2 = cat(2, accumulatedCountValues2, dailyCountValues2);
		accumulatedCountRateValues2 = cat(2, accumulatedCountRateValues2, dailyCountRateValues2);
		deltaTime2 = cat(2, deltaTime2, deltaT2);

		accumulatedCountValues3 = cat(2, accumulatedCountValues3, dailyCountValues3);
		accumulatedCountRateValues3 = cat(2, accumulatedCountRateValues3, dailyCountRateValues3);
		deltaTime3 = cat(2, deltaTime3, deltaT3);

		accumulatedCountValues4 = cat(2, accumulatedCountValues4, dailyCountValues4);
		accumulatedCountRateValues4 = cat(2, accumulatedCountRateValues4, dailyCountRateValues4);
		deltaTime4 = cat(2, deltaTime4, deltaT4);
    end  %End of if if-else clause - if (i == 1)

end %End of for loop  for i = 1 : length(numTimeEventsPerDay)


%Set up the dailyDose and totalDosePerDay structures.
%Calculate the total dose per day.
totalDosePerDay.channel1 = info.channel1CountsToRads*dailyTotalCounts1;
totalDosePerDay.channel2 = info.channel2CountsToRads*dailyTotalCounts2;
totalDosePerDay.channel3 = info.channel3CountsToRads*dailyTotalCounts3;
totalDosePerDay.channel4 = info.channel4CountsToRads*dailyTotalCounts4;

%Calculate the daily dose per day.
dailyDose.channel1 = info.channel1CountsToRads*accumulatedCountValues1;
dailyDose.channel2 = info.channel2CountsToRads*accumulatedCountValues2;
dailyDose.channel3 = info.channel3CountsToRads*accumulatedCountValues3;
dailyDose.channel4 = info.channel4CountsToRads*accumulatedCountValues4;

%Finally set up the count rate structure.
dailyDoseRate.channel1 = info.channel1CountsToRads*accumulatedCountRateValues1;
dailyDoseRate.channel2 = info.channel2CountsToRads*accumulatedCountRateValues2;
dailyDoseRate.channel3 = info.channel3CountsToRads*accumulatedCountRateValues3;
dailyDoseRate.channel4 = info.channel4CountsToRads*accumulatedCountRateValues4;

end  %End of the function getDosimeterDose.m
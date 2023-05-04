function [monthlyMeanDose1, monthlyMeanDose2,monthlyMeanDose3, ...
    monthlyMeanDose4] = getMeanMonthlyDose(info, numMonths, totalDosePerDay, ...
    includedDays)

%This function is called by plotYearToDateDose.m
%This function calculates the mean dose per month.

%We need to get the data into monthly values.
dayMonthStartIndex = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
dayMonthEndIndex = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

%Set up the return variables.  These will hold the 
monthlyMeanDose1 = zeros(1, numMonths);
monthlyMeanDose2 = zeros(1, numMonths);
monthlyMeanDose3 = zeros(1, numMonths);
monthlyMeanDose4 = zeros(1, numMonths);

%Loop through the months to get the monthly Mean.
for i = info.startMonth : info.startMonth + numMonths - 1
    dayIndex = find(includedDays >= dayMonthStartIndex(i) & includedDays <= dayMonthEndIndex(i));
    monthlyMeanDose1(i) = mean(totalDosePerDay.channel1(dayIndex));
    monthlyMeanDose2(i) = mean(totalDosePerDay.channel2(dayIndex));
    monthlyMeanDose3(i) = mean(totalDosePerDay.channel3(dayIndex));
    monthlyMeanDose4(i) = mean(totalDosePerDay.channel4(dayIndex));

end  %End of for loop - for i = 1 : numMonths

end  %End of getMeanMonthlyDose.m
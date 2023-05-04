function cumulativeDose = getCumulativeDose(numEvents, totalDosePerDay)

%This function is called by plotYearToDateDose.m
%This function calculates the cumulative dose for each day starting from
%the beginning of the time interval and going to the end.

cumulativeDose = zeros(1, numEvents);

for i = 1 : numEvents
    if (i == 1) 
        cumulativeDose(i) = totalDosePerDay(i);
    else
        cumulativeDose(i) = cumulativeDose(i - 1) + totalDosePerDay(i);
    end
end  %End of for loop - for i = 1 : numEvents

end  %End of the function getCumulativeDose.m
%Test to see that loop works in the DNToMDN.m function.

dbstop if error;

clearvars;
close all;
fclose('all');

year = 2024;
doy = 131;
firstLightYear = 2022;
firstLightDayOfYear = 15;

if year == firstLightYear
    missionDayNumber = doy - firstLightDayOfYear + 1;
else
    %First take care of the days in the year for the last year.
    missionDayNumber = doy;

    %Now loop through the remaining years.
    for i = year - 1 : -1 : firstLightYear

        %Check for leap years.
        if isLeapYear(i)
            numDaysInYear = 366;
        else
            numDaysInYear = 365;
        end %End of if-else clause.

        missionDayNumber = missionDayNumber + numDaysInYear;
    end  %End of for loop - for i = year - 1 : -1 : firstLightYear
    
    %Finally subtract off the 15 days in the first year.
    missionDayNumber = missionDayNumber - firstLightDayOfYear + 1;
end %End of if-else clause 






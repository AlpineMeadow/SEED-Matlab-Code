function [dayOfYear, year] = MDNToDN(info, missionDayNumber)
%This function will convert mission day numbers into day of year and year
%numbers.

%Set the number of mission days for the first year.
firstYearNumDays = 365 - info.firstLightDayOfYear;

%Make a working copy of missionDayNumber.
daysSinceStart = missionDayNumber;

%Calculate the number of days since the mission started.
%Handle the first year as a special case.
if missionDayNumber <= firstYearNumDays
    dayOfYear = missionDayNumber + info.firstLightDayOfYear - 1;
    year = 2022;

else
    %Set out the number of days in the mission per year.  This will be done
    %for years 2022 - 2028.  If the mission last longer then we will have
    %to add more days.
    numMissionDaysPerYear = [350, 715, 1081, 1446, 1811, 2176, 2542];

    %First find the number of years.
    %This does not seem to work.  I tried with both fixing the ration of
    %missionDayNumber to 365.2425 and rounding the ratio.  Either worked
    %for certain examples but not both.
    %    year = fix(missionDayNumber/365.2425) + firstLightYear;

    %Set up the starting year.
    numYears = info.firstLightYear;
    for i = 1 : length(numMissionDaysPerYear)
        dayDiff = numMissionDaysPerYear(i) - missionDayNumber;
        
        %Check to find when the day difference goes positive.
        if dayDiff < 0
            numYears = numYears + 1;
            dayOfYear = dayDiff;
        else
            dayOfYear = abs(dayOfYear);
            break;
        end
    end

    %Set the number of years.
    year = numYears;

end %End of if-else clause 

end  %End of the function MDNToDN.m
function [dayOfYear, year] = MDNToDN(missionDayNumber)
%This function will convert mission day numbers into day of year and year
%numbers.

firstLightDayOfYear = 15;

%Now determine the year and day of year depending on the mission day
%number.
if missionDayNumber <= 351
    year = 2022;
    dayOfYear = missionDayNumber + firstLightDayOfYear - 1;
elseif missionDayNumber > 351 && missionDayNumber <= 716 
    year = 2023;
    dayOfYear = missionDayNumber - 351;
elseif missionDayNumber > 716 && missionDayNumber <= 1082 
    year = 2024;
    dayOfYear = missionDayNumber - 716;
elseif missionDayNumber > 1082 && missionDayNumber <= 1447 
    year = 2025;
    dayOfYear = missionDayNumber - 1082;                
elseif missionDayNumber > 1447 && missionDayNumber <= 1812
    year = 2026;
    dayOfYear = missionDayNumber - 1447;                
elseif missionDayNumber > 1812 && missionDayNumber <= 2177
    year = 2027;
    dayOfYear = missionDayNumber - 1812;
elseif missionDayNumber > 2177 && missionDayNumber <= 2543
    year = 2028;
    dayOfYear = missionDayNumber - 2177;
elseif missionDayNumber > 2543 && missionDayNumber <= 2908
    year = 2029;
    dayOfYear = missionDayNumber - 2543;               
elseif missionDayNumber > 2908 && missionDayNumber <= 3274
    year = 2030;
    dayOfYear = missionDayNumber - 2908;
else 
    year = 2031;
    dayOfYear = missionDayNumber - 2913;
    print('Year is underdetermined')
end %End of if-else clause - if missionDayNumber <= firstYearNumDays
      
end  %End of the function MDNToDN.m
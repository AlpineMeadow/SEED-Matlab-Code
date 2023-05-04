function missionDayNumber = MonthDayToMDN(info, month, dayOfMonth, year)
%This function will convert calendar month and day of
%month to mission day number.

%Convert month and day of month to day number and year.
dayOfYearStr = string(datetime(year, month, dayOfMonth), 'DDD');

%Convert the array of string to an array of doubles.  The array of strings
%will not work with str2num.  What a piece of shit.
dayOfYear = str2double(dayOfYearStr);

%Convert day of year and year to mission day number.
missionDayNumber = DNToMDN(dayOfYear, year);

end  %End of the function MonthDayToMDN.m
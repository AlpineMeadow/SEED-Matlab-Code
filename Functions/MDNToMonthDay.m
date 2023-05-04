function [year, month, dayOfMonth] = MDNToMonthDay(info, missionDayNumber)
%This function will convert mission day number to calendar month and day of
%month.

%Convert mission day number to day of year and year.
[dayOfYear, year] = MDNToDN(info, missionDayNumber);

%Convert day of year and year to month and day of month.
dateVector = datevec(datenum(year, 0, dayOfYear));
month = dateVector(2);
dayOfMonth = dateVector(3);

end  %End of the function MDNToMonthDay.m
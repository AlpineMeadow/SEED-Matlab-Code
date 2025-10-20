function [year, month, dayOfMonth] = MDNToMonthDay(missionDayNumber)
%This function will convert mission day number to calendar month and day of
%month.

%Convert mission day number to day of year and year.
[dayOfYear, year] = MDNToDN(missionDayNumber);

%Convert day of year and year to month and day of month.
dt = datetime(datenum(year, 0, dayOfYear), 'convertfrom', 'datenum');
month = dt.Month;
dayOfMonth = dt.Day;

end  %End of the function MDNToMonthDay.m
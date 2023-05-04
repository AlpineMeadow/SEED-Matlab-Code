function [month, dayOfMonth] = doyYear2MonthDay(year, dayOfYear)
%A generic function that will take as input the year and the day of year
%and output the month and day of month.  The month will be output as a
%number between 1 and 12 and the day will be output as a number from 1 to
%31.

%Set the day of year string and the year string.
dayOfYearStr = num2str(dayOfYear, '%03d');
yearStr = num2str(year);

%Generate a string containing the day of year and the year.
yearDoyStr = [num2str(year), ' ', dayOfYearStr];

%Determine the day of month, month and year.
[~, month, dayOfMonth] = ymd(datetime(yearDoyStr, 'InputFormat', 'uuuu DDD'));


end
function [xTickVals, dateFormat] = getAGU2023XTickValues(info)

%This function will determine the number of ticks and their values for the
%x axis plotting.  This is called by AGU2023.m

%Find the number of days being plotted.
numDays = info.endDayOfYear - info.startDayOfYear + 1;

%Find the starting second in datenum values.
startSecond = datenum([info.startYear, info.startMonth, ...
    info.startDayOfMonth, info.startHour, info.startMinute, ...
    info.startSecond]);

%Find the ending second in datenum values.
endSecond = datenum([info.endYear, info.endMonth, info.endDayOfMonth, ...
    info.endHour, info.endMinute, info.endSecond]);

%Find the number of hours to be plotted.  We multiply by 24 to convert the
%datenum values into actual hours.
numHours = floor(24.0*(endSecond - startSecond));

hoursPerDay = 24;
minutesPerHour = 60;
secondsPerMinute = 60;

%Now check the number of hours.
%The case where we have less than a single hour to analyze.
if numHours == 0
    dVec = [10, 20, 30, 40, 50, 60]/(hoursPerDay*minutesPerHour) + ...
        startSecond;
    xTickVals = datenum(dVec);

    %Set the plot time format.
    dateFormat = 'HH:MM:SS';
end

hourCount = 0:6;

%The case where we have up to six hours to analyze
if numHours > 0 & numHours <= 6
    hourMultiple = hoursPerDay;

    %Set the plot time format.
    dateFormat = 'HH:MM:SS';
end

if numHours > 6 & numHours <= 12
    hourMultiple = hoursPerDay/2;
    
    %Set the plot time format.
    dateFormat = 'HH:MM:SS';
end

if numHours > 12 & numHours <= 18
    hourMultiple = hoursPerDay/2;

    %Set the plot time format.
    dateFormat = 'HH:MM:SS';
end

if numHours > 18 & numHours <= 24
    hourMultiple = hoursPerDay/4;

    %Set the plot time format.
    dateFormat = 'HH:MM:SS';
end


if numDays >= 2
    hourCount = 0:8;
    hourMultiple = hoursPerDay*2;

    %Set the plot time format.
    dateFormat = 'HH:MM:SS';
end



%Fill the x tick values vector.
dVec = hourCount/hourMultiple + startSecond;
xTickVals = datenum(dVec);


end  %End of function getAGU2023XTickValues.m
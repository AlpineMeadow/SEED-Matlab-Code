function DstIndex = getDstIndex(info)

%This function will read in the Dst Index file and then pull out the
%requested data points.  This function is called by
%generateInformationStructure.m

startYear = info.startYear;
startDayOfYear = info.startDayOfYear;
startMonth = info.startMonth;
startDayOfMonth = info.startDayOfMonth;

endYear = info.endYear;
endDayOfYear = info.endDayOfYear;
endMonth = info.endMonth;
endDayOfMonth = info.endDayOfMonth;

%Get the Dst filename.
filename = info.DstFilename;

%Convert day of year into month and day of month.
startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
endMonth = endDateVector(2);
endDayOfMonth = endDateVector(3);

%Read in the file, it is a CSV.
Dst = readmatrix(filename);

%Since the data is limited in time, lets check to see that we can view it.
if startYear < Dst(1, 1)
    disp(['getDstIndex.m : Starting year is earlier than ', num2str(Dst(1, 1)), ...
        '. No data exists in the database.'])
end

if endYear > Dst(end, 1)
    disp(['getDstIndex.m : Ending year is beyond ', num2str(Dst(end, 1)), ...
        '. No data exists in the database.'])
end

if startMonth < Dst(1, 2) & startYear == Dst(1, 1)
    disp(['getDstIndex.m : Starting Month is earlier than ', num2str(Dst(1, 2)), ...
        '.  No data exists in the database.'])
end

if endMonth > Dst(end, 2) & endYear == Dst(end, 1)
    disp(['getDstIndex.m : Ending Month is later than ', num2str(Dst(end, 2)), ...
        '.  No data exists in the database.'])
end


if startDayOfMonth < Dst(1, 3) & startYear == Dst(1, 1) & ...
        startMonth == Dst(1, 2)
    disp(['getDstIndex.m : Starting Day of Month is earlier than ', ...
        num2str(Dst(1, 3)), '.  No data exists in the database.'])
end

if endDayOfMonth > Dst(end, 3) & endYear == Dst(end, 1) & ...
        endMonth == Dst(end, 2)
    disp(['getDstIndex.m : Ending Day of Month is later than ', ...
        num2str(Dst(end, 3)), '.  No data exists in the database.'])
end

%Find the starting index.
startIndex = find(Dst(:, 1) == info.startYear & ...
    Dst(:, 2) == startMonth & ...
    Dst(:, 3) == startDayOfMonth);

%Find the ending index.
endIndex = find(Dst(:, 1) == endYear & ...
    Dst(:, 2) == endMonth & ...
    Dst(:, 3) == endDayOfMonth);

%Get the requested data.
DstIndex.Year = Dst(startIndex : endIndex, 1);
DstIndex.Month = Dst(startIndex : endIndex, 2);
DstIndex.DayOfMonth = Dst(startIndex : endIndex, 3);
DstIndex.BaseValue = Dst(startIndex : endIndex, 4);
DstIndex.HourlyAverage = Dst(startIndex : endIndex, 5:28);
DstIndex.DailyMeanValue = Dst(startIndex : endIndex, 29);

end  %End of the function getDstIndex.m
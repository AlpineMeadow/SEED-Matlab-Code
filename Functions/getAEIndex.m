function  AEIndex = getAEIndex(info, startYear, startDayOfYear, startHour,...
    endYear, endDayOfYear, endHour)

%This function will read in the AE Index file and then pull out the
%requested data points.

%Get the Dst filename.
filename = info.AEFilename;

%Convert day of year into month and day of month.
startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
endMonth = endDateVector(2);
endDayOfMonth = endDateVector(3);

%Read in the file, it is a CSV.
AE = readmatrix(filename);

%Since the data is limited in time, lets check to see that we can view it.
if startYear < AE(1, 1)
    disp(['getAEIndex.m : Starting year is earlier than ', num2str(AE(1, 1)), ...
        '. No data exists in the database.'])
end

if endYear > AE(end, 1)
    disp(['getAEIndex.m : Ending year is beyond ', num2str(AE(end, 1)), ...
        '. No data exists in the database.'])
end

if startMonth < AE(1, 2) & startYear == AE(1, 1)
    disp(['getAEIndex.m : Starting Month is earlier than ', num2str(AE(1, 2)), ...
        '.  No data exists in the database.'])
end

if endMonth > AE(end, 2) & endYear == AE(end, 1)
    disp(['getAEIndex.m : Ending Month is later than ', num2str(AE(end, 2)), ...
        '.  No data exists in the database.'])
end

if startDayOfMonth < AE(1, 3) & startYear == AE(1, 1) & startMonth == AE(1, 2)
    disp(['getAEIndex.m : Starting Day of Month is earlier than ', ...
        num2str(AE(1, 3)), '.  No data exists in the database.'])
end

if endDayOfMonth > AE(end, 3) & endYear == AE(end, 1) & endMonth == AE(end, 2)
    disp(['getAEIndex.m : Ending Day of Month is later than ', num2str(AE(end, 3)), ...
        '.  No data exists in the database.'])
end

%Find the starting index.
startIndex = find(AE(:, 1) == startYear & AE(:, 2) == startMonth & ...
    AE(:, 3) == startDayOfMonth);

%Find the ending index.
endIndex = find(AE(:, 1) == endYear & AE(:, 2) == endMonth & ...
    AE(:, 3) == endDayOfMonth);

%Get the requested data.
AEIndex.Year = AE(startIndex : endIndex, 1);
AEIndex.Month = AE(startIndex : endIndex, 2);
AEIndex.DayOfMonth = AE(startIndex : endIndex, 3);
AEIndex.BaseValue = AE(startIndex : endIndex, 4);
AEIndex.HourlyAverage = AE(startIndex : endIndex, 5:28);
AEIndex.DailyMeanValue = AE(startIndex : endIndex, 29);

end  %End of the function getAEIndex.m
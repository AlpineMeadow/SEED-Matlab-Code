function ACEB = getACEB(info, startYear, startDayOfYear, ...
    startHour, endYear, endDayOfYear, endHour)


dirName = '/SS1/STPSat-6/AncillaryData/ACE/';
filename = [dirName, info.startYearStr, info.startMonthStr, ...
    '_ace_mag_1h.txt'];

%Convert day of year into month and day of month.
startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
endMonth = endDateVector(2);
endDayOfMonth = endDateVector(3);

%Read in the file, it is a CSV.
B = readmatrix(filename);

%Since the data is limited in time, lets check to see that we can view it.
if startYear < B(1, 1)
    disp(['getACEB.m : Starting year is earlier than ', ...
        num2str(B(1, 1)), '. No data exists in the database.'])
end

if endYear > B(end, 1)
    disp(['getACEB.m : Ending year is beyond ', ...
        num2str(B(end, 1)), ...
        '. No data exists in the database.'])
end

if startMonth < B(1, 2) & startYear == B(1, 1)
    disp(['getACEB.m : Starting Month is earlier than ', ...
        num2str(B(1, 2)), ...
        '.  No data exists in the database.'])
end

if endMonth > B(end, 2) & endYear == B(end, 1)
    disp(['getACEB.m : Ending Month is later than ', ...
        num2str(B(end, 2)), ...
        '.  No data exists in the database.'])
end


if startDayOfMonth < B(1, 3) & ...
        startYear == B(1, 1) & ...
        startMonth == B(1, 2)
    disp(['getACEB.m : Starting Day of Month is earlier than ', ...
        num2str(B(1, 3)), '.  No data exists in the database.'])
end

if endDayOfMonth > B(end, 3) & ...
        endYear == B(end, 1) & ...
        endMonth == B(end, 2)
    disp(['getACEB.m : Ending Day of Month is later than ', ...
        num2str(B(end, 3)), ...
        '.  No data exists in the database.'])
end

%Find the starting index.
startIndex = find(B(:, 1) == startYear & ...
    B(:, 2) == startMonth & ...
    B(:, 3) == startDayOfMonth);

%Find the ending index.
endIndex = find(B(:, 1) == endYear & ...
    B(:, 2) == endMonth & ...
    B(:, 3) == endDayOfMonth);

%Get the requested data.
ACEB.Year = B(startIndex(1) : endIndex(end), 1);
ACEB.Month = B(startIndex(1) : endIndex(end), 2);
ACEB.DayOfMonth = B(startIndex(1) : endIndex(end), 3);
ACEB.Hours = B(startIndex(1) : endIndex(end), 4);
ACEB.Bx = B(startIndex(1) : endIndex(end), 8);
ACEB.By = B(startIndex(1) : endIndex(end), 9);
ACEB.Bz = B(startIndex(1) : endIndex(end), 10);
ACEB.Bt = B(startIndex(1) : endIndex(end), 11);

end  %End of the function getACDB.m
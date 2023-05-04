function KpApIndex = getKpApIndex(info, startYear, startDayOfYear, startHour, ...
    endYear, endDayOfYear, endHour);

%This function will read in the KpAp Index file and then pull out the
%requested data points.

%Get the KpAp filename.
filename = info.KpApFilename;

%Convert day of year into month and day of month.
startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
endMonth = endDateVector(2);
endDayOfMonth = endDateVector(3);

%Read in the file, it is a CSV.
KpAp = readmatrix(filename);

%Since the data is limited in time, lets check to see that we can view it.
if startYear < KpAp(1, 1)
    disp(['getKpApIndex.m : Starting year is earlier than ', num2str(KpAp(1, 1)), ...
        '. No data exists in the database.'])
end

if endYear > KpAp(end, 1)
    disp(['getKpApIndex.m : Ending year is beyond ', num2str(KpAp(end, 1)), ...
        '. No data exists in the database.'])
end

if startMonth < KpAp(1, 2) & startYear == KpAp(1, 1)
    disp(['getKpApIndex.m : Starting Month is earlier than ', num2str(KpAp(1, 2)), ...
        '.  No data exists in the database.'])
end

if endMonth > KpAp(end, 2) & endYear == KpAp(end, 1)
    disp(['getKpApIndex.m : Ending Month is later than ', num2str(KpAp(end, 2)), ...
        '.  No data exists in the database.'])
end


if startDayOfMonth < KpAp(1, 3) & startYear == KpAp(1, 1) & startMonth == KpAp(1, 2)
    disp(['getKpApIndex.m : Starting Day of Month is earlier than ', ...
        num2str(KpAp(1, 3)), '.  No data exists in the database.'])
end

if endDayOfMonth > KpAp(end, 3) & endYear == KpAp(end, 1) & endMonth == KpAp(end, 2)
    disp(['getKpApIndex.m : Ending Day of Month is later than ', num2str(KpAp(end, 3)), ...
        '.  No data exists in the database.'])
end

%Find the starting index.
startIndex = find(KpAp(:, 1) == startYear & KpAp(:, 2) == startMonth & ...
    KpAp(:, 3) == startDayOfMonth);

%Find the ending index.
endIndex = find(KpAp(:, 1) == endYear & KpAp(:, 2) == endMonth & ...
    KpAp(:, 3) == endDayOfMonth);

%Get the requested data.
KpApIndex.Year = KpAp(startIndex : endIndex, 1);
KpApIndex.Month = KpAp(startIndex : endIndex, 2);
KpApIndex.DayOfMonth = KpAp(startIndex : endIndex, 3);
KpApIndex.BartellsSolarRotNumber = KpAp(startIndex : endIndex, 6);
KpApIndex.BartellsDayNumber = KpAp(startIndex : endIndex, 7);
KpApIndex.KpIndex = KpAp(startIndex : endIndex, 8 : 15);
KpApIndex.apIndex = KpAp(startIndex : endIndex, 16 : 23);
KpApIndex.ApIndex = KpAp(startIndex : endIndex, 24);
KpApIndex.SunspotNum = KpAp(startIndex : endIndex, 25);

end  %End of the funtion getKpApIndex.m


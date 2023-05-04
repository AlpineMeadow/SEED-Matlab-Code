function ACEElectronFlux = getACEElectronFlux(info, startYear, startDayOfYear, ...
    startHour, endYear, endDayOfYear, endHour)


dirName = '/SS1/STPSat-6/AncillaryData/ACE/';
filename = [dirName, info.startYearStr, info.startMonthStr, ...
    '_ace_epam_1h.txt'];

%Convert day of year into month and day of month.
startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
endMonth = endDateVector(2);
endDayOfMonth = endDateVector(3);

%Read in the file, it is a CSV.
ElectronFlux = readmatrix(filename);

%Since the data is limited in time, lets check to see that we can view it.
if startYear < ElectronFlux(1, 1)
    disp(['getACEElectronFlux.m : Starting year is earlier than ', ...
        num2str(ElectronFlux(1, 1)), '. No data exists in the database.'])
end

if endYear > ElectronFlux(end, 1)
    disp(['getACEElectronFlux.m : Ending year is beyond ', ...
        num2str(ElectronFlux(end, 1)), ...
        '. No data exists in the database.'])
end

if startMonth < ElectronFlux(1, 2) & startYear == ElectronFlux(1, 1)
    disp(['getACEElectronFlux.m : Starting Month is earlier than ', ...
        num2str(ElectronFlux(1, 2)), ...
        '.  No data exists in the database.'])
end

if endMonth > ElectronFlux(end, 2) & endYear == ElectronFlux(end, 1)
    disp(['getACEElectronFlux.m : Ending Month is later than ', ...
        num2str(ElectronFlux(end, 2)), ...
        '.  No data exists in the database.'])
end


if startDayOfMonth < ElectronFlux(1, 3) & ...
        startYear == ElectronFlux(1, 1) & ...
        startMonth == ElectronFlux(1, 2)
    disp(['getACEElectronFlux.m : Starting Day of Month is earlier than ', ...
        num2str(ElectronFlux(1, 3)), '.  No data exists in the database.'])
end

if endDayOfMonth > ElectronFlux(end, 3) & ...
        endYear == ElectronFlux(end, 1) & ...
        endMonth == ElectronFlux(end, 2)
    disp(['getACEElectronFlux.m : Ending Day of Month is later than ', ...
        num2str(ElectronFlux(end, 3)), ...
        '.  No data exists in the database.'])
end

%Find the starting index.
startIndex = find(ElectronFlux(:, 1) == startYear & ...
    ElectronFlux(:, 2) == startMonth & ...
    ElectronFlux(:, 3) == startDayOfMonth);

%Find the ending index.
endIndex = find(ElectronFlux(:, 1) == endYear & ...
    ElectronFlux(:, 2) == endMonth & ...
    ElectronFlux(:, 3) == endDayOfMonth);

%Get the requested data.
ACEElectronFlux.Year = ElectronFlux(startIndex(1) : endIndex(end), 1);
ACEElectronFlux.Month = ElectronFlux(startIndex(1) : endIndex(end), 2);
ACEElectronFlux.DayOfMonth = ElectronFlux(startIndex(1) : endIndex(end), 3);
ACEElectronFlux.Hours = ElectronFlux(startIndex(1) : endIndex(end), 4);
ACEElectronFlux.ElectronFluxLowEnergy = ElectronFlux(startIndex(1) : endIndex(end), 8);
ACEElectronFlux.ElectronFluxHighEnergy = ElectronFlux(startIndex(1) : endIndex(end), 9);

end  %End of the function getACEElectronFlux.m
%This script will input the various SuperMag data sets (each set has a
%duration of 1 year with 1 minute time resolution) and output a set of
%files that correspond to a single day.

dbstop if error;

clearvars;
close all;
fclose('all');


year = 2025;

yearStr = num2str(year);
rootDir = '/SS1/STPSat-6/AncillaryData/SuperMag/Data/';
inputRootFileName = ['SuperMag_', yearStr, '.csv'];

fileName = [rootDir, yearStr, '/', inputRootFileName];

%Now read in the .csv file.
dataTable = readtable(fileName);

%Now get the time out of the table.
time = dataTable.Date_UTC;

%Lets get the day of year out of these times.
dayOfYear = day(time, 'dayofyear');

%Get the SMR indices out of the table.
SMR = dataTable.SMR;
SMR00 = dataTable.SMR00;
SMR06 = dataTable.SMR06;
SMR12 = dataTable.SMR12;
SMR18 = dataTable.SMR18;
GSEBx = dataTable.GSE_Bx;
GSEBy = dataTable.GSE_By;
GSEBz = dataTable.GSE_Bz;
GSEVx = dataTable.GSE_Vx;
GSEVy = dataTable.GSE_Vy;
GSEVz = dataTable.GSE_Vz;
density = dataTable.DENSITY;
dynamicPressure = dataTable.PDYN;

%Loop through the days.
for dayNum = 1 : 365

    %First get the indices corresponding to the day.
    dayIndices = find(dayOfYear == dayNum);

    %Now we cannot save data into a .csv file using matlab's datetime as
    %well as doubles since these are mixed types.  This means that we need
    %to convert the datetime array in hours, minutes and seconds
    dayHours = time(dayIndices).Hour;
    dayMinutes = time(dayIndices).Minute;
    daySeconds = time(dayIndices).Second;
    dayYear = time(dayIndices).Year;
    dayMonth = time(dayIndices).Month;
    dayDayOfMonth = time(dayIndices).Day;
    dayDayOfYear = repmat(dayNum, length(dayIndices), 1);

    %Now make a file name.
    outFileName = [rootDir, yearStr, '/', 'SuperMag_', ...
        yearStr, '_', num2str(dayNum, '%03d'), '.csv'];

    %Now make the array to be output as a table.
    outArray = horzcat(dayYear, dayMonth, dayDayOfMonth, dayDayOfYear, ...
                dayHours, dayMinutes, daySeconds, SMR(dayIndices), ...
                SMR00(dayIndices), SMR06(dayIndices), ...
                SMR12(dayIndices), SMR18(dayIndices), ...
                GSEBx(dayIndices), GSEBy(dayIndices), ...
                GSEBz(dayIndices), GSEVx(dayIndices), ...
                GSEVy(dayIndices), GSEVz(dayIndices), ...
                density(dayIndices), dynamicPressure(dayIndices));

    %Now write the matrix to the file.
    writematrix(outArray, outFileName);

end  %End of for loop : for dayNum = 1 : 365

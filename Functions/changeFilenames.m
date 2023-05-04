function changeFilenames(info)

%Write a script to change the names of the CDF files.

%Set the starting day of year.
startDoy = 1;

%Set the ending day of year.
endDoy = 49;

%Set the year.
year = 2023;
yearStr = num2str(year);

%Set the root file name.
rootFilename = 'STPSat-6_FalconSEED_';

%Set the root directory.
rootDir = '/SS1/STPSat-6/SEED/';


for doy = startDoy : endDoy
    dayOfYearStr = num2str(doy, '%03d');

    %Determine the month and day of month for each day of year.
    startDateVector = datevec(datenum(year, 0, doy));
    month = startDateVector(2);
    dayOfMonth = startDateVector(3);
    monthStr = num2str(month, '%02d');
    dayOfMonthStr = num2str(dayOfMonth, '%02d');
    dirName = [rootDir, yearStr, '/L1/DayOfYear_', dayOfYearStr, '/'];

    oldFilename = [rootFilename, yearStr, monthStr, dayOfMonthStr, '_', ...
        dayOfYearStr, '_L1.cdf'];
    newFilename = ['STPSat-6_Falcon_SEED-L1_', yearStr, monthStr, ...
        dayOfMonthStr, '_v01.cdf'];
    
    oldName = [dirName, oldFilename];
    newName = [dirName, newFilename];
    command = ['mv ', oldName, ' ', newName];
%    disp(command)
    status = system(command)
    disp(status)
end


end
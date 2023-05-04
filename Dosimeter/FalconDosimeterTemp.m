%This program will input data from the temperature and dosimeter
%instruments.  It will generate Level 2 data and plot it.

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 229;
year = 2022;

info.year = year;
info.dayOfYear = doy;

%Set the plotting directory string.
plotDir = '/SS1/STPSat-6/Plots/';
rootDir = '/SS1/STPSat-6/SEED/';

info.plotDir = plotDir;
info.rootDir = rootDir;

%Generate the file name for the data to be analyzed.
DosimeterPathName = ['/SS1/STPSat-6/Dosimeter/', num2str(year), '/L1/DayOfYear_', num2str(doy, '%03d'), '/'];
TemperaturePathName = ['/SS1/STPSat-6/Temperature/', num2str(year), '/L1/DayOfYear_', num2str(doy, '%03d'), '/'];

info.dosimeterPathName = DosimeterPathName;
info.temperaturePathName = TemperaturePathName;

yearStr = num2str(year);
monthStr = datestr(doy2date(doy, year), 'mm');
dayOfMonthStr = datestr(doy2date(doy, year), 'dd');
dayOfYearStr = num2str(doy, '%03d');

info.yearStr = yearStr;
info.monthStr = monthStr;
info.dayOfMonthStr = dayOfMonthStr;
info.dayOfYearStr = dayOfYearStr;

%Generate the input file names.
DoseInFilename = [DosimeterPathName, 'STPSat-6_FalconDOSE_', yearStr, ...
    monthStr, dayOfMonthStr, '_', dayOfYearStr, '_L1.nc'];  
TempInFilename = [TemperaturePathName, 'STPSat-6_FalconTEMP_', yearStr, ...
    monthStr, dayOfMonthStr, '_', dayOfYearStr, '_L1.nc']; 


%Get the data.
[dataAttributesTemp, dataDimensionsTemp, rawTempData] = getNetCDFData(TempInFilename);
[dataAttributesDose, dataDimensionsDose, rawDoseData] = getNetCDFData(DoseInFilename);


makeDoseTempPlots(dataAttributesDose, rawTempData, rawDoseData, info);

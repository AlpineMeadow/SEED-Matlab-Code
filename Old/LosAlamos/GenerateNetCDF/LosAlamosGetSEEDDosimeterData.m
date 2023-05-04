%This script will generate and output NetCDF files for the Los Alamos
%group.

%Set Matlab to stop at the point of the error instead of dumping you back
%out to the main script which is helpful to no one.
dbstop if error;

%Clear all the variables.
clearvars;

%Close any open files.
fclose('all');

%Close any open plot windows.
close all;

%Set the starting and ending day of year as well as the year itself.
dayOfYear = 88;
startYear = 2022;

%Set the directory path for where the data is located.  Change to what ever
%is appropriate for your system.
inputSEEDDataDir = ['/SS1/STPSat-6/SEED/', num2str(startYear), '/L1/DayOfYear_', ...
	num2str(dayOfYear, '%03d'), '/'];

inputDosimeterDataDir = ['/SS1/STPSat-6/Dosimeter/', num2str(startYear), '/L1/DayOfYear_', ...
	num2str(dayOfYear, '%03d'), '/'];


%Set the directory path for where the output is located.  Change to what
%ever is appropriate to your system.
outputDataDir = '/SS1/STPSat-6/LosAlamos/';
	

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateLosAlamosInformation(dayOfYear, startYear, inputSEEDDataDir, ...
	inputDosimeterDataDir, outputDataDir);

%Get the dosimeter data.
[DosimeterTime, DosimeterCounts, DosimeterDose] = getLosAlamosDosimeterData(info);

%Get the SEED data.
[SEEDTime, SEEDCounts, SEEDFlux] = getLosAlamosSEEDData(info);

%Get the energy bins.
energyBins = getLosAlamosSEEDEnergy();

%Generate the file name that the output data file will be named.  Change
%this to your liking.
fname = ['LosAlamos_STPSat-6_FalconSEED_', info.startYearStr, info.startMonthStr, ...
	info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];

%Generate the NetCDF file for the Los Alamos group.
generateLosAlamosNetcdfFile(info, fname, DosimeterTime, DosimeterCounts, ...
	DosimeterDose, SEEDTime, SEEDCounts, SEEDFlux, energyBins)






%This program will be run as a driver program.  It will essentially
%generate Level 2 data and plot it.  In principle this program will be
%changed.  There are two tasks that need to be accomplished.  

%1.)  The first is combine the various days of data into a single day of day.  
%Due to the way the data were sent down to the ground, some days are split 
%into multiple files.  This need to be done for all three instruments.  At 
%the same time the unique data will be sent to the correct directories, 
%that is, SEED data will be placed in the Level 1 SEED directory and 
%Dosimeter data will be placed in the Level 1 Dosimeter directory and the 
%Temperature data will be placed in the Level 1 Temperature directory.

%2.)  The second task is to convert the instrument counts into meaningful 
% physical units.

%As of today(September 12, 2022)  I have written code to handle the first
%task but there are problems with the data that will take talking with
%Richard to solve.  The second task is also not completely possible right
%now as I do not know how to convert the Dosimeter data into physical
%units.  The same is true for the Temperature data.  I will have to get
%with Richard and Geoff for completion of these tasks.

dbstop if error;
clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 64;
startDayOfYear = doy;
endDayOfYear = doy;
startYear = 2022;
endYear = 2022;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

startEnergyBinNumber = 120;  %the energy bin number at which to start the data analysis. 
numEnergyBinsToSum = 10;  %The number of energy bins to sum.
numTimeBinsToSum = 1;  %The number of time bins to sum. This needs to remain set to 1.

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%Set a counter to be used for the CDF data version.
CDFDataVersionNumber = 1;

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateSEEDInformation(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber);

%Generate the file name for the data to be analyzed.  This will change
%depending on the user.
PathName = [info.SEEDRootDir, info.startYearStr, '/L1/DayOfYear_', ...
    info.startDayOfYearStr, '/'];

%Generate the file names.
L1File = ['STPSat-6_FalconSEED_2022', info.startMonthStr, ...
    info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];
fileName = [PathName, L1File];

%Get the data.
[dataAttributes, ~, rawData] = getNETCDFData(fileName);

%We convert the time in seconds from GPS epoch to time in seconds UTC.
[time, UTCCounts] = setUTCTime(info, rawData.SEEDTime, rawData.SEEDData);

%Now fix some of the data issues.
[time, Counts] = getUniqueDifferencedData(info, time, UTCCounts);

%Set the SEED energy bins and integrate(add) the energy channels that the
%user asks for.
Counts = getSEEDEnergy(info, Counts);

%In order to make the summary plots we will have to interpolate the data.
%This is, I believe, a Matlab problem that I was not able to figure out.
%Interpolation seems to make the features show up where they are supposed
%to so we do it.  This is for summary plots only and is not to be used in
%any real data analysis.
%[time, Counts] = interpolateSEEDData(info, time, energyBins, Counts);

%Determine the flux.  This function will return a structure containing the
%actual flux as well as estimates of the error/uncertainty in the flux.
flux = getSEEDFlux2(info, time, Counts);

%Make summary spectra
plotSEEDSummarySpectrogram(info, time, flux);
%makeSEEDSpectra2(info, time, flux);

%makeDeltaTHistogram(info, time);

%Make a movie of the line spectra.
%makeLineSpectraMovie(info, time, flux, energyBins);

%This function is used to generate netcdf files for Carlos.  
%generateSEEDNetCdfFile(flux, energyBins, time, info);

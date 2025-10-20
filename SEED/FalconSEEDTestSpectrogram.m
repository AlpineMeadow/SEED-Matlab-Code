%This program will be run as a driver program.  It will essentially
%generate Level 2 data and plot it.  In principle this program will be
%changed.  There are two tasks that need to be accomplished.  

dbstop if error;

%clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 64;
startDayOfYear = doy;
endDayOfYear = doy;
startYear = 2022;
endYear = 2022;

%Set up a starting time and ending time for the data analysis.
startHour = 7;
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 7;
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

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateSEEDInformation(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
	startHour, startMinute, startSecond, endHour, endMinute, endSecond);



%Generate the file name for the data to be analyzed.  This will change
%depending on the user.
PathName = [info.SEEDRootDir, info.startYearStr, '/L1/DayOfYear_', ...
    info.startDayOfYearStr, '/'];

%Generate the file names.
L1File = ['STPSat-6_FalconSEED_2022', info.startMonthStr, ...
    info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];
fileName = [PathName, L1File];


%Get the data.
[dataAttributes, ~, rawData] = getNetCDFData(fileName);

%We convert the time in seconds from GPS epoch to time in seconds UTC.
[time, UTCCounts] = setUTCTime(info, rawData.SEEDTime, rawData.SEEDData);

%Now fix some of the data issues.
[time, Counts] = getUniqueDifferencedTestData(info, time, UTCCounts);

%Set the SEED energy bins and integrate(add) the energy channels that the
%user asks for.
[energyBins, Counts] = getSEEDTestEnergy(info, Counts);

%In order to make the summary plots we will have to interpolate the data.
%This is, I believe, a Matlab problem that I was not able to figure out.
%Interpolation seems to make the features show up where they are supposed
%to so we do it.  This is for summary plots only and is not to be used in
%any real data analysis.
%[time, Counts] = interpolateSEEDTestData(info, time, energyBins, Counts);

%Determine the flux.  This function will return a structure containing the
%actual flux as well as estimates of the error/uncertainty in the flux.
flux = getSEEDFlux1(info, time, Counts);

%Now make plots.

%Make summary spectrogram plots.
%makeSpectra4(info, time, flux, energyBins);
%makeSEEDSpectra2(info, time, flux, energyBins);
%makeAGUSpectrogram(info, flux, energyBins, UTCTime, numEnergyBinsToSum, dataDateNum);

%Make a time series of some of the energy channels.
makeSEEDTestTimeSeries(info, flux, time);

%Make a movie of the line spectra.
%makeSEEDLineSpectraMovie(info, UTCTime, flux, energyBins, numEnergyBinsToSum);

%Make a single spectra plot for a specific time.
%makeSEEDLineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);
%makeAGULineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);


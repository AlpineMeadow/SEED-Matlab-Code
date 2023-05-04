%This program will be run as a driver program.  It is specifically made for
%the AGU conference.



dbstop if error;


clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 64;
%doy = 37;
startDayOfYear = doy;
endDayOfYear = doy;
startYear = 2022;
endYear = 2022;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startHour = 10;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endHour = 11;
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

%Get the data.
[dataAttributes, ~, rawData] = getNETCDFData(info);

%We convert the time in seconds from GPS epoch to time in seconds UTC.
[dataDateNum, UTCTime, UTCCounts] = setUTCTime(info, rawData.SEEDTime, rawData.SEEDData);

%Now fix some of the data issues.
[uniqueDateNum, UTCTime, SEEDCounts] = getUniqueDifferencedData(dataDateNum, UTCTime, UTCCounts);

%Set the SEED energy bins and integrate(add) the energy channels that the
%user asks for.
[energyBins, SEEDCounts] = getSEEDEnergy(startEnergyBinNumber, ...
    numEnergyBinsToSum, SEEDCounts);

%Determine the flux.  This function will return a structure containing the
%actual flux as well as estimates of the error/uncertainty in the flux.
flux = getSEEDFlux(info, energyBins, SEEDCounts);


%Now make plots.

%Make summary spectrogram plots.
%makeAGUSpectrogram(info, flux, energyBins, UTCTime, numEnergyBinsToSum);

%Make a time series of some of the energy channels.
makeSEEDAGUTimeSeries(info, flux, energyBins, UTCTime, numEnergyBinsToSum);

%Make a single spectra plot for a specific time.
%makeAGULineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);



%This program will be run as a driver program.  It will essentially
%generate Level 2 data and plot it.  

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 70;
startDayOfYear = 48;
endDayOfYear = 48;
startYear = 2023;
endYear = 2023;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%the energy bin number at which to start the data analysis. 
startEnergyBinNumber = 120;  

%The number of energy bins to sum.
numEnergyBinsToSum = 10;

%The number of time bins to sum. This needs to remain set to 1.
numTimeBinsToSum = 1;  

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%Set the CDF version number.
CDFDataVersionNumber = 1;

%Generate a structure that holds all of the information needed to do the
%analysis.
info =  generateInformationStructure(startDayOfYear, startYear, ...
    endDayOfYear, endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber);


%Read in the GOES Data files.
%GOESData = getGOESData(info);


%Read a cdf file.  The times that are read in are converted to Matlab's
%datenum time automatically.
[CDFInfo, CDFData] = importSEEDCDF(info);

%Now make plots.


time = CDFData.SEED_Time_Dt15_Good;
flux = CDFData.SEED_Electron_Flux_Dt15_Good;

%We want to set a flag to look at either the delta t = 15 s. data or the
%total data.  The options are "totalData" or "dt15Data".
dataTypeFlag = 'dt15Data';



%makeSEEDLineSpectraMovie(info, CDFData, dataTypeFlag);

%Make summary spectrogram plots.
makeSEEDSpectra2(info, time, flux, energyBins);
%makeGOESSpectra(info, GOESData);

compareSEEDToGOES(info, CDFData, GOESData);
%makeAGUSpectrogram(info, flux, energyBins, UTCTime, numEnergyBinsToSum, dataDateNum);

%Make a time series of some of the energy channels.
%makeSEEDTimeSeries(info, flux, energyBins, time);

%Make a movie of the line spectra.
%makeSEEDLineSpectraMovie(info, UTCTime, flux, energyBins, numEnergyBinsToSum);

%Make a single spectra plot for a specific time.
%makeSEEDLineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);
%makeAGULineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);

%The largest gamma ray burst in history occured on day of year 282(Oct.
%9th, 2022). Let us look more closely at that day.
%if info.startDayOfYear == 282
%	plotGRBLineSpectra(info, time, flux, energyBins, dataAttributes)
%end

%This function is used to generate netcdf files for Carlos.  
%generateSEEDNetCdfFile(flux, energyBins, time, info);

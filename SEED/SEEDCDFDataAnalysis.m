%This program will be run as a driver program.  It will essentially
%generate Level 2 data and plot it.  In principle this program will be
%changed.  There are two tasks that need to be accomplished.  

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

% countrate1 = diff(rawData.SEEDData(:,600))./diff(rawData.SEEDTime).^(1/1);
% countrate2 = diff(rawData.SEEDData(:,600))./diff(rawData.SEEDTime).^(1/2);
% countrate3 = diff(rawData.SEEDData(:,600))./diff(rawData.SEEDTime).^(1/.5);
% countrate4 = diff(rawData.SEEDData(:,600))./diff(rawData.SEEDTime).^(1/.3);
% 
% indposrate1 = find(countrate1 > 0);
% indposrate2 = find(countrate2 > 0);
% indposrate3 = find(countrate3 > 0);
% indposrate4 = find(countrate4 > 0);
% 
% plot(rawData.SEEDTime(indposrate1+1),countrate1(indposrate1),'bo', ...
%     rawData.SEEDTime(indposrate2+1),countrate2(indposrate2),'g*');
% ylabel('Count Rate (\DeltaCounts / \DeltaT)');
% xlabel('Time (Seconds since Epoch)');
% title('\DeltaCounts > 0, Sqrt(\DeltaT)')
% legend({"Raw Data", "Square root of delta t"})

%We convert the time in seconds from GPS epoch to time in seconds UTC.
[time, UTCCounts] = setUTCTime(info, rawData.SEEDTime, rawData.SEEDData);

%Now fix some of the data issues.
[time, Counts] = getUniqueDifferencedData(info, time, UTCCounts);

%Set the SEED energy bins and integrate(add) the energy channels that the
%user asks for.
Counts = getSEEDEnergy(info, Counts);

%Determine the flux.  This function will return a structure containing the
%actual flux as well as estimates of the error/uncertainty in the flux.
%flux = getSEEDFlux(info, energyBins, Counts);
flux = getSEEDFlux1(info, time, Counts);

%Now make plots.

%Make summary spectrogram plots.
%makeSEEDSpectra2(info, time, flux, energyBins);

%makeAGUSpectrogram(info, flux, energyBins, UTCTime, numEnergyBinsToSum, dataDateNum);

%Make a time series of some of the energy channels.
makeSEEDTimeSeries(info, flux, energyBins, time);

%Make a movie of the line spectra.
%makeSEEDLineSpectraMovie(info, UTCTime, flux, energyBins, numEnergyBinsToSum);

%Make a single spectra plot for a specific time.
%makeSEEDLineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);
%makeAGULineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum);

%The largest gamma ray burst in history occured on day of year 282(Oct.
%9th, 2022). Let us look more closely at that day.
if info.startDayOfYear == 282
	plotGRBLineSpectra(info, time, flux, energyBins, dataAttributes)
end

%This function is used to generate netcdf files for Carlos.  
%generateSEEDNetCdfFile(flux, energyBins, time, info);

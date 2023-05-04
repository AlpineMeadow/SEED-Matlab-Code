%This script will take the seperate level 1 data files for a given day of
%year and combine them into one single level 1 netcdf data file.  This
%needs to be run after the raw data are moved up to level 1 data and before
%any analysis of the data can be done.

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
startDayOfYear = 364;
endDayOfYear = 2;
startYear = 2022;
endYear = 2023;

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

%Generate the cdf data version number.
CDFDataVersionNumber = 1;

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateSEEDInformation(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
	startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber);

%Loop through the days of year.
for missionDayOfYear = info.startMissionDayNumber : info.endMissionDayNumber
    disp(['Mission Day of Year : ', num2str(missionDayOfYear)]);

    %Open the files and combine the data into one single file.
    combineDaysOfYearData(info, missionDayOfYear);

end  %End of for loop - for doyIndex = startDayOfYear : endDayOfYear

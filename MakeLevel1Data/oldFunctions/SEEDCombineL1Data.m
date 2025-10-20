%This script will take the seperate level 1 data files for a given day of
%year and combine them into one single level 1 netcdf data file.  This
%needs to be run after the raw data are moved up to level 1 data and before
%any analysis of the data can be done.

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
startDayOfYear = 33;
endDayOfYear = 34;
startYear = 2025;
endYear = 2025;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%The energy bin number at which to start the data analysis. This will give
%904 energy bins, which is the number of bins in the CDF file.
startEnergyBinNumber = 121;  
numEnergyBinsToSum = 1;  %The number of energy bins to sum.
numTimeBinsToSum = 1;  %The number of time bins to sum. This needs to remain set to 1.

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%We need to generate a variable that will contain the data version number
%for the CDF files.  This will be used for this program but not in others
%that use the info structure.  
CDFDataVersionNumber = 1;

%Generate a structure that holds all of the information needed to do the
%analysis.
instrument = 'SEED';
info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber);

%Loop through the days of year.
for missionDayOfYear = info.startMissionDayNumber : info.endMissionDayNumber
    disp(['Mission Day of Year : ', num2str(missionDayOfYear)]);

    %Open the files and combine the data into one single file.
    combineDaysOfYearData(info, missionDayOfYear);

end  %End of for loop - for doyIndex = startDayOfYear : endDayOfYear

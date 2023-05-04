%This script will combine the the various level 1 (L1) files for a given day of
%year and output CDF data files for the combined SEED data, the combined
%dosimeter data and the combined temperature data.

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 50;
startDayOfYear = 100;
endDayOfYear = 120;
startYear = 2023;
endYear = 2023;

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
info = generateInformationStructure(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber);


%Loop through the mission day of years.
for missionDayIndex = info.startMissionDayNumber : info.endMissionDayNumber

    %Convert mission day number to year and day of year.
    [dayOfYear, year] = MDNToDN(info, missionDayIndex);
    disp(['Year : ', num2str(year), ' Day of Year : ', ...
        num2str(dayOfYear, '%03d')])

    %Open the files and combine the data into one single file.
    combineData(info, missionDayIndex);
end



















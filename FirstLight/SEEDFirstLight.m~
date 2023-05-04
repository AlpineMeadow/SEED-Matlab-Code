%This program will be run as a driver program.  It will essentially
%generate Level 2 data and plot it.  

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
startDayOfYear = 64;
endDayOfYear = 64;
startYear = 2022;
endYear = 2022;

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


%Here is a list of the bad days of year for 2022 in mission day numbers.
badDays2022 = DNToMDN([23, 75, 76, 85, 135, 136, 137, 138, 200, 201, 202, 272, 299, ...
    320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 347, 348], 2022);

%There are no bad days so far in 2023.
badDays2023 = DNToMDN([22, 27, 28, 101, 102], 2023);

%Combine all of the bad days into one single vector.
badDays = [badDays2022, badDays2023];

%For large sets of days to be analyzed, it is easier to not allow the plots
%to show on the screen.  We make a flag that tells Matlab to either plot to
%the screen or not.
visibleFlag = 0;

%Initiate a structure index.
i = 1;

%Loop through the day of interest.
for missionDayNum = info.startMissionDayNumber : info.endMissionDayNumber

    %Check to see if the mission day number is in the list of bad mission
    %day numbers.
    badDayIndex = find(missionDayNum == badDays);

    %If the mission day number is bad, skip it and move on to the next one.
    if length(badDayIndex) >= 1
        continue
    else
        %Read in the GOES Data files.  This set of commands will create an
        %array of structures.
%        GOESData(i) = getGOESData(info, missionDayNum);
        [CDFInfo, CDFData(i)] = importSEEDCDF1(info, missionDayNum);
        %Increment the structure index.
        i = i + 1;
    end
end

plotSEEDFirstLightTimeSeries(info, CDFInfo, CDFData)
fred = 1;


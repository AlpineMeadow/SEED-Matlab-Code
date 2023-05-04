%This script will input the doismeter data for the selected parts of the 
%mission and sum up the dose.

dbstop if error;

%Clear all the variables.
clearvars;

%Close any open files.
fclose('all');

%Close any open plot windows.
close all;

%Set the starting and ending day of year as well as the year itself.
startDayOfYear = 64;
endDayOfYear = 64;
%startDayOfYear = 25;
%endDayOfYear = 35;

startYear = 2022;
endYear = 2022;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateDosimeterInformation(startDayOfYear, startYear, ...
    endDayOfYear, endYear, startHour, startMinute, startSecond, ...
    endHour, endMinute, endSecond);

if ~exist('counts')
    %Get the dosimeter data.  The counts and countRate variables are structures
    %containing all 4 data channels.
    [time, counts, countRate, numTimeEventsPerDay, ...
    includedDays, eventPercent] = getDosimeterData2(info);
end

if ~exist('dailyDose')
    %Convert the counts to radiation dose.
    [totalDosePerDay, dailyDose, dailyDoseRate] = getDosimeterDose2(info, ...
        time, counts, countRate, numTimeEventsPerDay, includedDays);
end

%Create some plots of the data.
%plotYearToDateDose(info, totalDosePerDay, dailyDose, dailyDoseRate, ...
%    UTCTime, numTimeEventsPerDay, includedDays);
plotDailyDose(info, totalDosePerDay, dailyDose, dailyDoseRate, time, ...
    numTimeEventsPerDay, includedDays)


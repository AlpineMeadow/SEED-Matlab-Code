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
startDayOfYear = 282;
endDayOfYear = 282;

startYear = 2022;
endYear = 2022;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%Set up an array of dosimeter channels to look at.
dosimeterChannels = [1, 2, 3, 4];

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateDosimeterInformation(startDayOfYear, startYear, ...
    endDayOfYear, endYear, startHour, startMinute, startSecond, ...
        endHour, endMinute, endSecond, dosimeterChannels);


%Get the dosimeter data.
[rawTime, rawCounts, countRate, xvalues, xdays, eventPercent] = getDosimeterData2(info);

%Convert the counts to radiation dose.
dosePerDay = getDosimeterDose2(info, rawTime, rawCounts, countRate, xvalues, xdays);


%Create some plots of the data.
%plotYearToDateDose(info, dosePerDay, rawTime, xvalues, xdays)
plotYearlyDoseSummary(info, dosePerDay, rawTime, xvalues, xdays)


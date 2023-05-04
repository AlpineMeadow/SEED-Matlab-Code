%This script will input the doismeter data for the selected parts of the 
%mission and sum up the dose.

%Clear all the variables.
clearvars;

%Close any open files.
fclose('all');

%Close any open plot windows.
close all;

%Set the starting and ending day of year as well as the year itself.
startDayOfYear = 15;
endDayOfYear = 282;
%startDayOfYear = 50;
%endDayOfYear = 54;

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

%Set up a flag for the type of plot that is to be made.  Options are "day",
%"month" or "year".
plotType = 'year';

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateDosimeterInformation(startDayOfYear, startYear, ...
    endDayOfYear, endYear, startHour, startMinute, startSecond, ...
        endHour, endMinute, endSecond, dosimeterChannels);

%Get the dosimeter data.
[rawTime, rawDose, xvalues, xdays] = getDosimeterData(info);

%Convert the counts to radiation dose.
dosePerDay = getDosimeterDose(info, rawTime, rawDose, xvalues, xdays);


%Create some plots of the data.
plotYearToDateDose(info, dosePerDay, rawTime, xvalues, xdays)



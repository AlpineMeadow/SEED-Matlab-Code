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
doy = 64;
startDayOfYear = doy;
endDayOfYear = doy;
%startDayOfYear = 16;
%endDayOfYear = 260;

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

%The largest gamma ray burst in history occured on day of year 282(Oct.
%9th, 2022). Let us look more closely at that day.
if info.startDayOfYear == 282
	plotGRBCounts(info, rawTime, rawCounts)
end



%Convert the counts to radiation dose.  TotalDosePerDay1 and
%totalDosePerDay2 are the sum of dailyDose1 and dailyDose2 respectively.
[totalDosePerDay1, totalDosePerDay2, dailyDose1, dailyDose2, ...
	UTCTime] = getDosimeterDose2(info, rawTime, rawCounts, countRate, ...
	xvalues, xdays);

%Create some plots of the data.
plotDailyDoseSummary(info, totalDosePerDay1, totalDosePerDay2, dailyDose1, ...
	dailyDose2, UTCTime, xvalues, xdays)


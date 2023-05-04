function [time, interpolatedData] = interpolateSEEDTestData(info, ...
    time, energyBins, data)

%This function is called by FalconSEEDSummarySpectrogram.m
%This function will interpolate the variable number of spectra in a given
%day into 5760 spectra.  This is done solely for cosmetic purposes.  I
%believe that Matlab does not properly generate spectrograms using the
%imagesc function.  

%Make a limit to the number of seconds in a day divided by 15.
eventsInDay = 60*60*24/15; 

%Create a vector of seconds at 15 second intervals.
timeVector = 15*[1 : eventsInDay]; 
numEvents = length(timeVector);

%Standard commands to create a date number vector.
year = repmat(info.startYear, 1, numEvents);
month = repmat(info.startMonth, 1, numEvents);
day = repmat(info.startDayOfMonth, 1, numEvents);
hours = floor(timeVector/3600);
minutes = floor((timeVector - 3600*hours)/60.0);
seconds = timeVector - 3600*hours - 60*minutes;

%Generate a vector of date numbers.
interpolatedTime = datenum(year, month, day, hours, minutes, seconds);

%Create a meshgrid version of the time and energy we have data at.
[xRawOriginal, yRawOriginal] = meshgrid(time.rawEventDateNumber(2:end), energyBins(:, 2));   
[xDeltat15Original, yDeltat15Original] = meshgrid(time.deltat15EventDateNumber, ...
    energyBins(:, 2));   

%xRawOriginal = xRawOriginal(2:end);
%yRawOriginal = yRawOriginal(2:end);

%Create a meshgrid version of the interpolated time we want to plot.
[xNew, yNew] = meshgrid(interpolatedTime, energyBins(:, 2)); 

%Interpolate the data. We want to transpose because for some reason Matlab
%delivers the result as a transpose.

rawData = data.rawData;
delta15Data = data.deltat15Data;

%Interpolate the data onto the two grids.
interpolatedRawData = interp2(xRawOriginal, yRawOriginal, rawData', xNew, yNew)';
interpolatedDeltat15Data = interp2(xDeltat15Original, yDeltat15Original, ...
    delta15Data', xNew, yNew)';

%Fill the data structure.
interpolatedData.rawCounts = interpolatedRawData;
interpolatedData.deltat15Counts = interpolatedDeltat15Data;

%Now fill the time structure with the interpolated times.
time.eventSeconds = 86400*(interpolatedTime - interpolatedTime(1));
time.eventDateNumber = interpolatedTime;


end  %End of function interpolateSEEDTestData.m


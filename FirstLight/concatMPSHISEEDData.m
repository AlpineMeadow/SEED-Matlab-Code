function [dt, TimeStructure, SEEDInterpolatedTime, ...
    SEEDInterpolatedCounts, GOESElectronFlux] = concatMPSHISEEDData(info, ...
    GOESData, CDFData, detectorNumber, smoothConstant)

%This function is called by plotGOESData.m
%This function concatinates the SEED and GOES data for the first light
%paper.

%Set the number of events per day.  For GOES data this is 1440(one data
%point per minute for the entire day).
numEventsPerDay = 1440;

%Find the number of days to be concatinated.
numDaysGOES = length(GOESData);

%Set a parameter that allows for the data to be declared too large.  The
%way this works is that we compare the individual counts(or flux) value to
%a value  equal to counts(or flux) + sigmaMultiple*std(counts or flux).
sigmaMultiple = 2.0;

%Concatinate the data by looping through the different days.
for i = 1 : numDaysGOES

    if (i == 1)
        year = GOESData(i).year;
        month = GOESData(i).month;
        dayOfMonth = GOESData(i).dayOfMonth;
        dayOfYear = GOESData(i).dayOfYear;
        GOESTime = GOESData(i).time;
        GOESElectronFlux = squeeze(GOESData(i).ElectronFlux(:, detectorNumber, :));
        
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;
        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
        SEEDElectronCounts = CDFData(i).SEED_Electron_Counts_Dt15_Good;
        
        %Let us replace the huge count values in the SEEDElectronCounts with
        %smaller values.
        [SEEDElectronCounts, SEEDElectronFlux] = ...
            fixHighDataPoints(CDFData(i).SEED_Electron_Counts_Dt15_Good, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good, sigmaMultiple);

        %Now interpolate the SEED electron counts onto a grid of 5760
        %times.
        [SEEDInterpolatedCounts, SEEDInterpolatedTime] = ...
            interpolateSEEDCounts(SEEDTime, smoothConstant, ...
            SEEDElectronCounts);

%         plot(SEEDTime, double(SEEDElectronCounts(:, 470)), 'b', ...
%             datenum(SEEDInterpolatedTime), ...
%             SEEDInterpolatedCounts(:, 470), 'g')

    else
        %Append the data onto the arrays.
        year = cat(1, year, GOESData(i).year);
        month = cat(1, month, GOESData(i).month);
        dayOfMonth = cat(1, dayOfMonth, GOESData(i).dayOfMonth);
        dayOfYear = cat(1, dayOfYear, GOESData(i).dayOfYear);
        GOESTime = cat(1, GOESTime, GOESData(i).time);
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);

        %Fix (i.e. get rid of) the high data points.
        [counts, flux] = fixHighDataPoints(CDFData(i).SEED_Electron_Counts_Dt15_Good, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good, sigmaMultiple);

        %For the GOES electron flux we want to concatinate along the columns.
        GOESElectronFlux = cat(2, GOESElectronFlux, ...
            squeeze(GOESData(i).ElectronFlux(:, detectorNumber, :)));

        %For the SEED electron flux we concatinate along the rows.
        SEEDElectronFlux = cat(1, SEEDElectronFlux, flux);
        SEEDElectronCounts = cat(1, SEEDElectronCounts, counts);

        %Interpolate the new days worth of counts.
        [numEventsPerDay, numEnergyChannels] = size(counts);
        [SEEDIC, SEEDIT] = interpolateSEEDCounts(CDFData(i).SEED_Time_Dt15_Good, ...
            smoothConstant, counts);
       
        %For the SEED electron counts we concatinate along the rows.
        SEEDInterpolatedCounts = cat(1, SEEDInterpolatedCounts, ...
            SEEDIC);

        SEEDInterpolatedTime = cat(2, SEEDInterpolatedTime, ...
            SEEDIT);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDaysGOES


%I do not know what system the time values are given in.  I will set all of
%the values to start from the starting day and then convert to date
%numbers.
GOESTime = GOESTime - GOESTime(1);

dt = datetime(year(1), month(1), dayOfMonth(1)) + seconds(GOESTime);

%Now convert to datenum values.
dt = datenum(dt);

%Generate a date structure.
TimeStructure.year = year;
TimeStructure.month = month;
TimeStructure.dayOfMonth = dayOfMonth;
TimeStructure.dayOfYear = dayOfYear;

%Let us handle the bad data values for the SEED data found between 2/21/23
%15:37:46 and 2/21/23 22:21:04
badYear = 2023;
badDayOfMonth = 21;
badMonth = 2;
badStartHour = 15;
badStartMinute = 37;
badStartSecond = 46;
badEndHour = 22;
badEndMinute = 21;
badEndSecond = 4;

%Find the intitial time in datenum format.
initialBadTime = datenum(datetime([badYear, badMonth, badDayOfMonth, ...
    badStartHour, badStartMinute, badStartSecond]));
finalBadTime = datenum(datetime([badYear, badMonth, badDayOfMonth, ...
    badEndHour, badEndMinute, badEndSecond]));

badIndex = [];
if SEEDTime.Day == badDayOfMonth & SEEDTime.Month == 2
    badIndex = find(SEEDTime.Hour >= badStartHour & ...
        SEEDTime.Minute >= badStartMinute & ...
        SEEDTime.Second >= badStartSecond & ...
        SEEDTime.Hour <= badEndHour & ...
        SEEDTime.Minute <= badEndMinute & ...
        SEEDTime.Second <= badEndSecond);
    joe = 1;
end


%badIndex = find(SEEDTime > initialBadTime & SEEDTime < finalBadTime);

if length(badIndex) ~= 0 
    for e = 1 : 904

        %First do the interpolated counts.
        for i = 18200 : 18630
            if SEEDInterpolatedCounts(i, e) > 60
                SEEDInterpolatedCounts(i, e) = 60;
            end  %end of the if statement - if SEEDInterpolatedCounts(i, e) > 60
        end  %end of the for statement - for i = 18200 : 18630

        %Now do the non-interpolated counts.  These occur at different time
        %indices.
        for i = 12500 : 14500
            if SEEDElectronCounts(i, e) > 60
                SEEDElectronCounts(i, e) = 60;
            end  %End of the if statement - if SEEDElectronCounts(i, e) > 60
        end %End of the for statement - for i = 12500 : 14500
    end  %End of the for statement - for e = 1 : 904
end  %End of if statement - if length(badIndex) ~= 0


end  %End of the function concatGOESSEEDData.m
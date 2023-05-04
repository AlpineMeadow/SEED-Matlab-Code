function [time, counts, countRate, numTimeEventsPerDay, ...
    includedDays, eventPercent] = getDosimeterData2(info)

%This function will get the Level 1 dosimeter data for the given time
%interval.  The data is returned as rawCounts and rawTime.  No summing or
%integrating is done.  
%This function is called by :
%DailyDosimeterDoseSummary.m,
%WeeklyDosimeterDoseSummary.m, 
%MonthlyDosimeterDoseSummary.m
%YearlyDosimeterDoseSummary.m
%YearToDateDosimeterDoseSummary.m


%First calculate the number of days between the starting date and the
%ending date.
dStart = datenum([info.startYear, 0, info.startDayOfYear]);
dEnd = datenum([info.endYear, 0, info.endDayOfYear]);

%Set up a day of year counter.
doyCounter = 0;        

orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.

%Loop through the days of year from the start date till the end date.
for i = dStart : dEnd
    doy = info.startDayOfYear + doyCounter;
    doyStr = num2str(doy, '%03d');

    %Determine the year, month and day of month for each day of year.
    dv = datevec(datenum(info.startYear, 0, doy));
    year = dv(1);
    month = dv(2);
    dayOfMonth = dv(3);

    %Generate the file name for the data to be analyzed.
    PathName = [info.dosimeterRootDir, num2str(year), '/L1/DayOfYear_', num2str(doy, '%03d'), '/'];        

    %Generate the file names.
    L1File = ['STPSat-6_FalconDOSE_2022', num2str(month, '%02d'), ...
        num2str(dayOfMonth, '%02d'), '_', doyStr, '_L1.nc'];   
    fileName = [PathName, L1File];

    %Check to see if the file exists.
    if exist(fileName) == 2
    
        %Get the data.
        [~, ~, rawData] = getNetCDFData(fileName);

        %Call setDosimeterUTCTime so that we have UTC time for all of
        %the data.  This is better than having the raw time.
        [UTCTime, UTCDateNum, UTCCounts] = setDosimeterUTCTime(info, ...
            rawData.DOSEData, rawData.DOSETime);

        %Handle the first file separately.
        if (doy == info.startDayOfYear) 
        
            rawCounts = UTCCounts;
            eventSeconds = UTCTime; 
            eventDateNum = UTCDateNum;

			%Generate the delta or change between individual dose
			%measurements.
			deltaCountsChannel1 = [UTCCounts(1, 1); diff(UTCCounts(:, 1), ...
                orderOfDifference, arrayDimension)];
			deltaCountsChannel2 = [UTCCounts(1, 2); diff(UTCCounts(:, 2), ...
                orderOfDifference, arrayDimension)];
			deltaCountsChannel3 = [UTCCounts(1, 3); diff(UTCCounts(:, 3), ...
                orderOfDifference, arrayDimension)];
			deltaCountsChannel4 = [UTCCounts(1, 4); diff(UTCCounts(:, 4), ...
                orderOfDifference, arrayDimension)];

			%Generate the delta or change in time between individual dose
			%measurements.
			deltaTime = [UTCTime(1); diff(UTCTime, orderOfDifference, ...
                arrayDimension)];
            
			%Calculate the dose rate for each event.
			countRateChannel1 = deltaCountsChannel1./deltaTime;
			countRateChannel2 = deltaCountsChannel2./deltaTime;
			countRateChannel3 = deltaCountsChannel3./deltaTime;
			countRateChannel4 = deltaCountsChannel4./deltaTime;	

            %Set the number of time values for the given day of year.
            numTimeEventsPerDay = length(UTCTime);

			%Calculate the percent of actual events out of possible events.
			eventPercent = 100.0*numTimeEventsPerDay/86400.0;

            %Set the actual day of year.
            includedDays = doy;
        else

            %Append the data onto the arrays.
            eventSeconds = cat(1, eventSeconds, UTCTime);
            eventDateNum = cat(1, eventDateNum, UTCDateNum);
            rawCounts = cat(1, rawCounts, UTCCounts);
            
			%Now determine the count rates for the channels.
			deltaCountsChannel1 = cat(1, deltaCountsChannel1, ...
				[rawData.DOSEData(1, 1); diff(rawData.DOSEData(:, 1), orderOfDifference, arrayDimension)]);

			deltaCountsChannel2 = cat(1, deltaCountsChannel2, ...
				[rawData.DOSEData(1, 2); diff(rawData.DOSEData(:, 2), orderOfDifference, arrayDimension)]);

			deltaCountsChannel3 = cat(1, deltaCountsChannel3, ...
				[rawData.DOSEData(1, 3); diff(rawData.DOSEData(:, 3), orderOfDifference, arrayDimension)]);

			deltaCountsChannel4 = cat(1, deltaCountsChannel4, ...
				[rawData.DOSEData(1, 4); diff(rawData.DOSEData(:, 4), orderOfDifference, arrayDimension)]);

            %Append the delta time.
			deltaTime = cat(1, deltaTime, ...
				[rawData.DOSETime(1); diff(rawData.DOSETime, orderOfDifference, arrayDimension)]);


			%Now get the count rates.
			countRateChannel1 = cat(1, deltaCountsChannel1./deltaTime);
			countRateChannel2 = cat(1, deltaCountsChannel2./deltaTime);
			countRateChannel3 = cat(1, deltaCountsChannel3./deltaTime);
        	countRateChannel4 = cat(1, deltaCountsChannel4./deltaTime);

			numTimeEventsPerDay = cat(1, numTimeEventsPerDay, length(rawTime) + ...
                length(numTimeEventsPerDay) - doyCounter);
			eventPercent = cat(1, eventPercent, 100.0*length(rawData.DOSETime)/86400.0);
            includedDays = cat(1, includedDays, doy);

        end %End of if-else clause - if (doy == startDoy)

    else
        disp(['The file :', fileName, ' does not exist.  Skipping'])
    end  %End of if-else statement - if exist(fileName) == 2



    %Increment the day of year counter.
    
    doyCounter = doyCounter + 1;
end %End of for loop - for i = dStart : dEnd

%Generate a plot of the event percent for each day.
%plotCountsPercentage(info, includedDays, eventPercent);

%plotDoseRateHistograms(info, includedDays, numTimeEventsPerDay, doseRateChannel1, ...
%	doseRateChannel2, doseRateChannel3, doseRateChannel4, rawTime)

%Create count and count rate structures.
counts.channel1 = rawCounts(:, 1);
counts.channel2 = rawCounts(:, 2);
counts.channel3 = rawCounts(:, 3);
counts.channel4 = rawCounts(:, 4);

countRate.channel1 = countRateChannel1;
countRate.channel2 = countRateChannel2;
countRate.channel3 = countRateChannel3;
countRate.channel4 = countRateChannel4;

%Create and fill the time structure.
time.eventSeconds = eventSeconds;
time.eventDateNum = eventDateNum;

end  %End of the function getDosimeterData.m
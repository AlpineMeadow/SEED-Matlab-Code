function [rawTime, rawDose, xvalues, xdays] = getDosimeterData(info)

%This function will get the Level 1 dosimeter data for the given time
%interval.
%This function is called by Dosimeter.m


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

    if i >= 738641 
        continue
%     elseif i == 738643
%         continue
%     elseif i == 738642
%         continue
%     elseif i == 738644
%         continue
    else
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
        disp(fileName)
        disp(num2str(i))
        disp('')

        %Check to see if the file exists.
        if exist(fileName) == 2
    
            %Get the data.
            [~, ~, rawData] = getNetCDFData(fileName);

            %Handle the first file separately.
            if (doy == info.startDayOfYear)
            
                % rawData.DOSETime holds the time and
                % rawData.DOSEData holds the dosimeter data
                rawTime = rawData.DOSETime;
                rawDose = rawData.DOSEData;

    			%Generate the delta or change between individual dose
    			%measurements.
    			deltaDoseChannel1 = [rawData.DOSEData(1, 1); diff(rawData.DOSEData(:, 1), orderOfDifference, arrayDimension)];
    			deltaDoseChannel2 = [rawData.DOSEData(1, 2); diff(rawData.DOSEData(:, 2), orderOfDifference, arrayDimension)];
    			deltaDoseChannel3 = [rawData.DOSEData(1, 3); diff(rawData.DOSEData(:, 3), orderOfDifference, arrayDimension)];
    			deltaDoseChannel4 = [rawData.DOSEData(1, 4); diff(rawData.DOSEData(:, 4), orderOfDifference, arrayDimension)];

    			%Generate the delta or change in time between individual dose
    			%measurements.
    			deltaTime = [rawData.DOSETime(1); diff(rawData.DOSETime, orderOfDifference, arrayDimension)];
            
    			%Calculate the dose rate for each event.
    			doseRateChannel1 = deltaDoseChannel1./deltaTime;
    			doseRateChannel2 = deltaDoseChannel2./deltaTime;
    			doseRateChannel3 = deltaDoseChannel3./deltaTime;
    			doseRateChannel4 = deltaDoseChannel4./deltaTime;

                %Set the number of time values for the given day of year.
                xvalues = length(rawTime);

    			%Calculate the percent of actual events out of possible events.
    			eventPercent = 100.0*length(rawData.DOSETime)/86400.0;
                %			disp(['For Day of Year : ', doyStr, ' Percent of Total Events : ', num2str(100.0*length(rawData.DOSETime)/86400.0)]);

                %Set the actual day of year.
                xdays = doy;
            else

                %Append the data onto the arrays.
                rawTime = cat(1, rawTime, rawData.DOSETime);
                rawDose = cat(1, rawDose, rawData.DOSEData);
    			deltaDoseChannel1 = cat(1, deltaDoseChannel1, ...
    				[rawData.DOSEData(1, 1); diff(rawData.DOSEData(:, 1), orderOfDifference, arrayDimension)]);

    			deltaDoseChannel2 = cat(1, deltaDoseChannel2, ...
    				[rawData.DOSEData(1, 2); diff(rawData.DOSEData(:, 2), orderOfDifference, arrayDimension)]);

    			deltaDoseChannel3 = cat(1, deltaDoseChannel3, ...
    				[rawData.DOSEData(1, 3); diff(rawData.DOSEData(:, 3), orderOfDifference, arrayDimension)]);

    			deltaDoseChannel4 = cat(1, deltaDoseChannel4, ...
    				[rawData.DOSEData(1, 4); diff(rawData.DOSEData(:, 4), orderOfDifference, arrayDimension)]);


    			deltaTime = cat(1, deltaTime, ...
    				[rawData.DOSETime(1); diff(rawData.DOSETime, orderOfDifference, arrayDimension)]);


    			%Now get the dose rates.
    			doseRateChannel1 = cat(1, deltaDoseChannel1./deltaTime);
    			doseRateChannel2 = cat(1, deltaDoseChannel2./deltaTime);
    			doseRateChannel3 = cat(1, deltaDoseChannel3./deltaTime);
            	doseRateChannel4 = cat(1, deltaDoseChannel4./deltaTime);


    			xvalues = cat(1, xvalues, length(rawTime) + length(xvalues) - doyCounter);
    			eventPercent = cat(1, eventPercent, 100.0*length(rawData.DOSETime)/86400.0);
                xdays = cat(1, xdays, doy);
                %			disp(['For Day of Year : ', doyStr, ' Percent of Total Events : ', num2str(100.0*length(rawData.DOSETime)/86400.0)]);
            end %End of if-else clause - if (doy == startDoy)

        else
            disp(['The file :', fileName, ' does not exist.  Skipping'])
        end  %End of if-else statement - if exist(fileName) == 2



        %Increment the day of year counter.
    
        doyCounter = doyCounter + 1;
    end


end %End of for loop - for i = dStart : dEnd

%Generate a plot of the event percent for each day.
%plotCountsPercentage(info, xdays, eventPercent);

%plotDoseRateHistograms(info, xdays, xvalues, doseRateChannel1, ...
%	doseRateChannel2, doseRateChannel3, doseRateChannel4, rawTime)



end  %End of the function getDosimeterData.m
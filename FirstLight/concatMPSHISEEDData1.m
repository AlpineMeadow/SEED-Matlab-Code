function [dt, SEEDInterpolatedTime, SEEDInterpolatedCounts] = ...
    concatMPSHISEEDData1(info, CDFData, smoothConstant)

%This function is called by plotGOESData.m
%This function concatinates the SEED and GOES data for the first light
%paper.

%Determine the number of days in the data structure.
numDays = length(CDFData);

%Set a parameter that allows for the data to be declared too large.  The
%way this works is that we compare the individual counts(or flux) value to
%a value  equal to counts(or flux) + sigmaMultiple*std(counts or flux).
sigmaMultiple = 2.0;

%Concatinate the data by looping through the different days.
for i = 1 : numDays

    %Pull out the relavent data.
    SEEDTime = CDFData(i).SEED_Time_Dt15_Good;

    %Sometimes there is only 1 single data point in the data array. This
    %screws up all of the analysis so lets check for single point arrays
    %and if we get one just skip to the next day.
    if length(SEEDTime) == 1
        continue
    end

    SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
    SEEDElectronCounts = CDFData(i).SEED_Electron_Counts_Dt15_Good;

    if (i == 1)        
        %Let us replace the huge count values in the SEEDElectronCounts with
        %smaller values.
        [SEEDElectronCounts, SEEDElectronFlux] = ...
            fixHighDataPoints(SEEDElectronCounts, ... 
            SEEDElectronFlux, sigmaMultiple);

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
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);

        %Fix (i.e. get rid of) the high data points.
        [counts, flux] = fixHighDataPoints(CDFData(i).SEED_Electron_Counts_Dt15_Good, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good, sigmaMultiple);

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




dt = SEEDInterpolatedTime;

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



badIndex = [];
if dt.Day == badDayOfMonth & dt.Month == badMonth

    badIndex = find(dt.Hour >= badStartHour & ...
        dt.Minute >= badStartMinute & ...
        dt.Second >= badStartSecond & ...
        dt.Hour <= badEndHour & ...
        dt.Minute <= badEndMinute & ...
        dt.Second <= badEndSecond);
    joe = 1;
end


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


end  %End of the function concatMPSHIGOESSEEDData1.m
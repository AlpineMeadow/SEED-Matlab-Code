function [dt, timeStructure, SEEDInterpolatedTime, ...
    SEEDInterpolatedCounts] = concatSEEDData(info, CDFData, smoothConstant)

%This function is called by plotSEEDLocalTimeEnergySpectra.m.  It will
%concatinate all of the days into single arrays.

%Set a parameter that allows for the data to be declared too large.  The
%way this works is that we compare the individual counts(or flux) value to
%a value  equal to counts(or flux) + sigmaMultiple*std(counts or flux).
sigmaMultiple = 2.0;

%Determine the number of days to be concatinated.
numDaysSEED = length(CDFData);

%Set the number of events per day.  For SEED data this is 5760(one data
%point per 15 seconds for the entire day).
numEventsPerDay = 5760;

%Concatinate the data by looping through the different days.
for i = 1 : numDaysSEED

    if (i == 1)
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;

        %Here I want to sum all of the energy bins so that I can get
        %smaller arrays.getSEEDEnergy(info, SEEDCounts)
%        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
%        SEEDElectronCounts = getSEEDEnergy(info, ...
%            CDFData(i).SEED_Electron_Counts_Dt15_Good);

        %Let us sum the original 904 energy channels into the number
        %requested.
        temp = getSEEDEnergy(info, CDFData(i).SEED_Electron_Counts_Dt15_Good);

        %Let us replace the huge count values in the SEEDElectronCounts with
        %smaller values.
        [SEEDElectronCounts, SEEDElectronFlux] = ...
            fixHighDataPoints(temp, CDFData(i).SEED_Electron_Flux_Dt15_Good, ...
            sigmaMultiple);

        %Now interpolate the SEED electron counts onto a grid of 5760
        %times.
        [SEEDInterpolatedCounts, SEEDInterpolatedTime] = ...
            interpolateSEEDCounts(SEEDTime, smoothConstant, ...
            SEEDElectronCounts, numEventsPerDay);

    else
        %Append the data onto the arrays.

        %Let us sum the original 904 energy channels into the number
        %requested.
        temp = getSEEDEnergy(info, CDFData(i).SEED_Electron_Counts_Dt15_Good);

        %Fix (i.e. get rid of) the high data points.
        [counts, flux] = fixHighDataPoints(temp, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good, sigmaMultiple);

        %For the SEED electron flux we concatinate along the rows.
        SEEDElectronFlux = cat(1, SEEDElectronFlux, flux);
%        SEEDElectronCounts = cat(1, SEEDElectronCounts, counts);

        %Interpolate the new days worth of counts.
        [SEEDIC, SEEDIT] = interpolateSEEDCounts(CDFData(i).SEED_Time_Dt15_Good, ...
            smoothConstant, counts, numEventsPerDay);
       
        %For the SEED electron counts we concatinate along the rows.
        SEEDInterpolatedCounts = cat(1, SEEDInterpolatedCounts, ...
            SEEDIC);

        SEEDInterpolatedTime = cat(2, SEEDInterpolatedTime, ...
            SEEDIT);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDaysGOES

%Now convert to datenum values.
dt = datenum(SEEDInterpolatedTime);

%Generate a date structure.
timeStructure.year = SEEDInterpolatedTime.Year;
timeStructure.month = SEEDInterpolatedTime.Month;
timeStructure.dayOfMonth = SEEDInterpolatedTime.Day;
timeStructure.dayOfYear = day(SEEDInterpolatedTime, 'dayofyear');
timeStructure.hour = SEEDInterpolatedTime.Hour;
timeStructure.minute = SEEDInterpolatedTime.Minute;
timeStructure.second = SEEDInterpolatedTime.Second;

end  %End of the function concatSEEDData.m

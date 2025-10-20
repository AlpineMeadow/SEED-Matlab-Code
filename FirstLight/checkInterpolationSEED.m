function checkInterpolationSEED(info, CDFData, smoothConstant)

%This function will check interpolation for SEED
%Find the number of days to be concatinated.
numDaysSEED = length(CDFData);


for i = 1 : numDaysSEED

    if (i == 1)
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;
        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
        SEEDElectronCounts = CDFData(i).SEED_Electron_Counts_Dt15_Good;
        
        %Let us replace the huge count values in the SEEDElectronCounts with
        %smaller values.
        for e = 1 : 904
            highCountIndex = find(SEEDElectronCounts(:, e) > 1e3);
            highFluxIndex = find(SEEDElectronFlux(:, e) > 1e8);
            SEEDElectronCounts(highCountIndex, e) = 50;
            SEEDElectronFlux(highFluxIndex, e) = 3300000;
        end
        
        %Now interpolate the SEED electron counts onto a grid of 5760
        %times.
        [SEEDInterpolatedCounts, SEEDInterpolatedTime] = ...
            interpolateSEEDCounts(SEEDTime, smoothConstant, ...
            SEEDElectronCounts);

    else
        %Append the data onto the arrays.
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);

        [counts, flux] = fixHighDataPoints(CDFData(i).SEED_Electron_Counts_Dt15_Good, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good, i);

        SEEDElectronCounts = cat(1, SEEDElectronCounts, counts);

        %For the SEED electron flux we concatinate along the rows.
        SEEDElectronFlux = cat(1, SEEDElectronFlux, flux);
        
        %Interpolate the new days worth of counts.
        [SEEDIC, SEEDIT] = interpolateSEEDCounts(CDFData(i).SEED_Time_Dt15_Good, ...
            smoothConstant, counts);
       
        %For the SEED electron counts we concatinate along the rows.
        SEEDInterpolatedCounts = cat(1, SEEDInterpolatedCounts, ...
            SEEDIC);

        SEEDInterpolatedTime = cat(2, SEEDInterpolatedTime, ...
            SEEDIT);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDaysGOES

energyChannel = 47;

plot(SEEDElectronCounts(:, energyChannel), 'b*')
hold on
plot(SEEDInterpolatedCounts(:, energyChannel), 'g*')


end  %End of the function checkConcatSEED.m
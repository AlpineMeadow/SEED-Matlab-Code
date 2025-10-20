function [uniqueSEEDDataIndex] = determineUniqueIndexPerEnergy(rawSEEDData, ...
    energyBin1, energyBin2, energyBin3)

%This function is called by getCDFUniqueDifferencedSEEDData.m
%Set a flag for making a plot.
makePlot = 0;

%Generate some energy values for the given energy bin numbers.
deltaEnergy = 0.1465;  %In units of keV.
energyBinOffset = -3.837;

E1 = energyBin1*deltaEnergy + energyBinOffset;
E2 = energyBin2*deltaEnergy + energyBinOffset;
E3 = energyBin3*deltaEnergy + energyBinOffset;

%plot(rawSEEDData(18000:19000, 200)+1, 'r-*')

%Find the unique data points(Counts) for the given energy bins.  We use the
%keyword "stable" because somehow Matlab thinks that default behavior 
%should be to change the order of the returned indices.  Stable keeps them
%sorted. 
% [C1, uniqueSEEDDataIndex1, ic1] = unique(rawSEEDData(:, energyBin1), ...
%     'rows', 'stable');
% [C2, uniqueSEEDDataIndex2, ic2] = unique(rawSEEDData(:, energyBin2), ...
%     'rows', 'stable');
% [C3, uniqueSEEDDataIndex3, ic3] = unique(rawSEEDData(:, energyBin3), ...
%     'rows', 'stable');


%Loop through the energy channels, finding the highest number of unique
%SEED count values.
[numTimeBins, numEnergyBins] = size(rawSEEDData);

for energyIndex = 1 : numEnergyBins
    [C, uniqueSEEDDataIndex, ic] = unique(rawSEEDData(:, energyIndex), ...
        'stable');
    %Find the number of unique counts.
    numUniqueCounts = length(uniqueSEEDDataIndex);

%    disp(['Energy Index : ', num2str(energyIndex), ...
%        ' Number of Unique Counts ', num2str(numUniqueCounts)])

    if energyIndex == 1
        goodDataIndex = uniqueSEEDDataIndex;
    else
        if length(goodDataIndex) < numUniqueCounts
            goodDataIndex = uniqueSEEDDataIndex;
        end  %End of if statement - if length(goodDataIndex) < numUniqueCounts 
    end  %End of if-else clause - if energyIndex == 1
end  %End of for loop - for energyIndex = 1 : numEnergyBins


%Now return the good index.
uniqueSEEDDataIndex = goodDataIndex;

% %Determine the number of unique events.
% numEnergyBin1 = length(uniqueSEEDDataIndex1);
% numEnergyBin2 = length(uniqueSEEDDataIndex2);
% numEnergyBin3 = length(uniqueSEEDDataIndex3);
% 
% %We want to return the index that has the most entries.
% if numEnergyBin1 >= numEnergyBin2 && numEnergyBin1 >= numEnergyBin3
%     uniqueSEEDDataIndex = uniqueSEEDDataIndex1;
% elseif numEnergyBin2 >= numEnergyBin1 && numEnergyBin2 >= numEnergyBin3
%     uniqueSEEDDataIndex = uniqueSEEDDataIndex2;
% else
%     uniqueSEEDDataIndex = uniqueSEEDDataIndex3;
% end


if makePlot == 1
    %Set up some strings for plotting.
    E1Str = ['Energy : ', num2str(E1), ' keV - Unique Events : ', ...
        num2str(numEnergyBin1)];
    E2Str = ['Energy : ', num2str(E2), ' keV - Unique Events : ', ...
        num2str(numEnergyBin2)];
    E3Str = ['Energy : ', num2str(E3), ' keV - Unique Events : ', ...
        num2str(numEnergyBin3)];

    %Make a plot of the results.
     figure()
     plot(1:length(uniqueSEEDDataIndex1), uniqueSEEDDataIndex1, 'b',...
        1:length(uniqueSEEDDataIndex2), uniqueSEEDDataIndex2, 'g', ...
        1:length(uniqueSEEDDataIndex3), uniqueSEEDDataIndex3, 'r')
    title('Plot of Unique Indices As a Function of Energy Channel')
    ylabel('Unique Indices')
    xlabel('Index of Unique Indices')
    legend(E1Str, E2Str, E3Str, 'Location', 'southeast')
end  %End of if statement - if makePlot == 1

end  %End of the functiondetermineUniqueIndexPerEnergy.m 
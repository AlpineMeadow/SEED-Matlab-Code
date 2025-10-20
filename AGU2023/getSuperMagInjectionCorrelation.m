function correlationCoefficient = getSuperMagInjectionCorrelation(info, ...
    superMagData, injectionDB)

%This function will calculate the correlation between the time series of
%the electron data and the SuperMag data.  It is called by
%ReadInjectionDB.m

%First we need to choose an energy to make the correlation calculations.
energyBin = 20;

%Here is a list of the bad days of year for 2022 in mission day numbers.
badDays2022 = DNToMDN([23, 75, 76, 85, 135, 136, 137, 138, 200, 201, ...
    202, 272, 299, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, ...
    330, 347, 348], 2022);

%These are the bad days in 2023.
badDays2023 = DNToMDN([22, 27, 28, 101, 102, 129, 131, 132, 133, ...
    134, 135, 136, 137, 138, 139, 140, 144, 145, 146, 147, 148, ...
    149, 150, 151, 161, 162, 163, 164, 165, 166, 167, 191, 191, ...
    192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, ...
    204, 205, 206, 207, 208, 209, 210], 2023);

%Combine all of the bad days into one single vector.
badDays = [badDays2022, badDays2023];

dayCount = 1;

%Loop through the day of interest.
for missionDayNumber = info.startMissionDayNumber : info.endMissionDayNumber
    
    %Check to see if the mission day number is in the list of bad mission
    %day numbers.
    badDayIndex = find(missionDayNumber == badDays);

    %If the mission day number is bad, skip it and move on to the next one.
    if length(badDayIndex) >= 1
        continue
    else
        %Read a cdf file.  The times that are read in are converted to Matlab's
        %datenum time automatically.
        [CDFInfo, CDFData] = importSEEDCDF1(info, missionDayNumber);
        data(dayCount).CDFData = CDFData;
        dayCount = dayCount + 1;
    end  %End of if-else clause - if length(badDayIndex) >= 1
end  %End of for loop - for missionDayNumber = info.startMissionDayNumber : info.endMissionDayNumber 


%Now find the various smr values for each of the injections.
numEvents = length(CDFData.SEED_Time_Dt15_Good);
SEEDIndex = ones(1, numEvents);

%Generate the times
dt = datetime(CDFData.SEED_Time_Dt15_Good, 'ConvertFrom', 'datenum');
months = dt.Month;
dayOfMonth = dt.Day;
hours = dt.Hour;
minutes = dt.Minute;
seconds = dt.Second;

superMagSeconds = 1 : 60 : 86400;
SEEDSeconds = (CDFData.SEED_Time_Dt15_Good(:,1) - ...
    CDFData.SEED_Time_Dt15_Good(1, 1)) * 86400;

startSuperMagIndex = info.startDayOfYear*1400;
superMagIndex = startSuperMagIndex : startSuperMagIndex + 1439;


%Because the superMag data does not contain times in seconds and the SEED
%data does, we cannot compare them easily.  So lets interpolate.
interpSME = interp1(superMagSeconds, superMagData.sme(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSML = interp1(superMagSeconds, superMagData.sml(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSMU = interp1(superMagSeconds, superMagData.smu(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSMR = interp1(superMagSeconds, superMagData.smr(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSMR00 = interp1(superMagSeconds, superMagData.smr00(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSMR06 = interp1(superMagSeconds, superMagData.smr06(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSMR12 = interp1(superMagSeconds, superMagData.smr12(superMagIndex), ...
    SEEDSeconds, 'linear');

interpSMR18 = interp1(superMagSeconds, superMagData.smr18(superMagIndex), ...
    SEEDSeconds, 'linear');

numEnergyBins = length(CDFData.SEED_Energy_Channels);
numEnergyBins = 200;

for i = 1 : numEnergyBins
    d = double(CDFData.SEED_Electron_Counts_Dt15_Good(:, i));

    [rSMU, pSMU] = corrcoef(interpSMU, d, 'Rows', 'complete');
    [rSME, pSME] = corrcoef(interpSME, d, 'Rows', 'complete');
    [rSML, pSML] = corrcoef(interpSML, d, 'Rows', 'complete');
    [rSMR, pSMR] = corrcoef(interpSMR, d, 'Rows', 'complete');
    [rSMR00, pSMR00] = corrcoef(interpSMR00, d, 'Rows', 'complete');
    [rSMR06, pSMR06] = corrcoef(interpSMR06, d, 'Rows', 'complete');
    [rSMR12, pSMR12] = corrcoef(interpSMR12, d, 'Rows', 'complete');
    [rSMR18, pSMR18] = corrcoef(interpSMR18, d, 'Rows', 'complete');

    correlationCoefficient.rSMU = rSMU(1,2);
    correlationCoefficient.pSMU = pSMU(1,2);

    correlationCoefficient.rSME = rSME(1,2);
    correlationCoefficient.pSME = pSME(1,2);

    correlationCoefficient.rSML = rSML(1,2);
    correlationCoefficient.pSML = pSML(1,2);

    correlationCoefficient.rSMR = rSMR(1,2);
    correlationCoefficient.pSMR = pSMR(1,2);

    correlationCoefficient.rSMR00 = rSMR00(1,2);
    correlationCoefficient.pSMR00 = pSMR00(1,2);

    correlationCoefficient.rSMR06 = rSMR06(1,2);
    correlationCoefficient.pSMR06 = pSMR06(1,2);

    correlationCoefficient.rSMR12 = rSMR12(1,2);
    correlationCoefficient.pSMR12 = pSMR12(1,2);

    correlationCoefficient.rSMR18 = rSMR18(1,2);
    correlationCoefficient.pSMR18 = pSMR18(1,2);

    cc(i) = correlationCoefficient;
end %End of for loop - for i = 1 : numEnergyBins


%Now make plots of the p-values as a function of energy for the different
%SuperMag indices.
fig2 = figure('DefaultAxesFontSize', 12);
ax2 = axes();
fig2.Position = [750 25 1200 500];
ax2.Position = [0.13, 0.11, 0.775, 0.8150];

satellite = 'STPSat-6';
instrument = 'SEED';
plotType = 'SuperMagP-Value';
dateStr = info.startDateStr;
doyStr = info.startDayOfYearStr;

saveName2 = [satellite, instrument, plotType, '_',  ...
   dateStr, '_', doyStr];

SEEDFileName2 = strcat('/SS1/STPSat-6/AGU2023/', saveName2, '.png');



subplot(4, 2, 1)
plot([1:numEnergyBins], [cc.pSMU], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
title('P-Value vs. Energy For SuperMag SMU Index')
set(gca,'xticklabel',[])

subplot(4, 2, 2)
plot([1:numEnergyBins], [cc.pSME], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
title('P-Value vs. Energy For SuperMag SME Index')
set(gca,'xticklabel',[])

subplot(4, 2, 3)
plot([1:numEnergyBins], [cc.pSML], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
title('P-Value vs. Energy For SuperMag SML Index')
set(gca,'xticklabel',[])

subplot(4, 2, 4)
plot([1:numEnergyBins], [cc.pSMR], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
title('P-Value vs. Energy For SuperMag SMR Index')
set(gca,'xticklabel',[])

subplot(4, 2, 5)
plot([1:numEnergyBins], [cc.pSMR00], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
%ylim([0 1])
title('P-Value vs. Energy For SuperMag SMR00 Index')
set(gca,'xticklabel',[])

subplot(4, 2, 6)
plot([1:numEnergyBins], [cc.pSMR06], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
%ylim([0 1])
title('P-Value vs. Energy For SuperMag SMR06 Index')
set(gca,'xticklabel',[])

subplot(4, 2, 7)
plot([1:numEnergyBins], [cc.pSMR12], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
title('P-Value vs. Energy For SuperMag SMR12 Index')
xticklabels({'14', '18', '22', '26', '30', '34', '38', '42'})
xticks([0, 28.57, 57.14, 85.71, 114.29, 142.86, 171.43, 200])
xlabel('Energy (keV)')

subplot(4, 2, 8)
plot([1:numEnergyBins], [cc.pSMR18], 'b', [1:numEnergyBins], [0.05*ones(1, numEnergyBins)], 'r')
ylabel('P-Value')
title('P-Value vs. Energy For SuperMag SMR18 Index')
xticks([0, 28.57, 57.14, 85.71, 114.29, 142.86, 171.43, 200])
xticklabels({'14', '18', '22', '26', '30', '34', '38', '42'})
xlabel('Energy (keV)')

if (info.startDayOfYear == 64)
    sgtitle([info.startDayOfMonthStr, ' ', info.startMonthName, ' ', ...
        info.startYearStr, ' - K_{p} = 3.63'])
end

if (info.startDayOfYear == 62)
    sgtitle([info.startDayOfMonthStr, ' ', info.startMonthName, ' ', ...
        info.startYearStr, ' - K_{p} = 3.42'])
end

if (info.startDayOfYear == 83)
    sgtitle([info.startDayOfMonthStr, ' ', info.startMonthName, ' ', ...
        info.startYearStr, ' - K_{p} = 5.05'])
end


%Save the time series to a file.
saveas(fig2, SEEDFileName2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end
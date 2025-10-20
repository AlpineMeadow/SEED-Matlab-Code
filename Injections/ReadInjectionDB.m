%This script will read in the SEED injection database and explore it.

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
doy = 83;
startDayOfYear = doy;
endDayOfYear = doy;
startYear = 2023;
endYear = 2023;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%The energy bin number at which to start the data analysis. This will give
%904 energy bins, which is the number of bins in the CDF file.
startEnergyBinNumber = 121;  

%The number of energy bins to sum.
numEnergyBinsToSum = 10;  

%The number of time bins to sum. This needs to remain set to 1.
numTimeBinsToSum = 1;  

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%We need to generate a variable that will contain the data version number
%for the CDF files.  This will be used for this program but not in others
%that use the info structure.  
CDFDataVersionNumber = 1;

%Create a flag that tell the plotting program whether or not to plot the
%sector boundaries.
plotSectorBoundaries = 0;

%Generate a structure that holds all of the information needed to do the
%analysis.
instrument = 'SEED';
info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber);

%Get the injection database values.
injectionDB = getInjectionDB();

%Get the SuperMag data.
superMagData = getSuperMagData();

%Find the correlation coefficients between the injections and the SuperMag
%data.
%correlationCoefficient = getSuperMagInjectionCorrelation(info, ...
%    superMagData, injectionDB)


%Now find the various smr values for each of the injections.
numInjections = length(injectionDB.year);
SMRIndex = ones(1, numInjections);
for i = 1 : numInjections
    temp = find(superMagData.month == injectionDB.month(i) & ...
        superMagData.UTCHours == injectionDB.UTCInjectionHours(i) & ...
        superMagData.UTCMinutes == injectionDB.UTCInjectionMinutes(i));
    SMRIndex(i) = temp(1);
end
fig2 = figure('DefaultAxesFontSize', 12);
ax2 = axes();
fig2.Position = [750 25 1200 500];
ax2.Position = [0.13, 0.11, 0.775, 0.8150];

satellite = 'STPSat-6';
instrument = 'SEED';
plotType = 'SuperMagTotalHistogram';
dateStr = info.startDateStr;
doyStr = info.startDayOfYearStr;

saveName2 = [satellite, instrument, plotType, '_',  ...
   dateStr, '_', doyStr];

SEEDFileName3 = strcat('/SS1/STPSat-6/AGU2023/', saveName2, '.png');

histogram(superMagData.smr(SMRIndex), 'FaceAlpha', 1.0, ...
    'Normalization', 'pdf', 'FaceColor', 'b')
ylabel('Events')
title('Histogram For SuperMag SMR Index')
hold on
histogram(superMagData.smr, 'FaceAlpha', 0.4, 'Normalization', 'pdf', ...
    'FaceColor', 'r')
legend('SMR - SEED Injection Data','SMR - All Data','location','northwest')

%Save the time series to a file.
saveas(fig2, SEEDFileName3);



%Lets find the indices for the different types of injections
IIndex = find(char(injectionDB.injectionType) == 'I');
WIndex = find(char(injectionDB.injectionType) == 'W');
EIndex = find(char(injectionDB.injectionType) == 'E');

numI = length(IIndex);
numW = length(WIndex);
numE = length(EIndex);
SMRIIndex = ones(1, numI);
SMRWIndex = ones(1, numW);
SMREIndex = ones(1, numE);

%Now find the corresponding SMR indices.
for i = 1 : numI
    temp = find(superMagData.month == injectionDB.month(IIndex(i)) & ...
        superMagData.UTCHours == injectionDB.UTCInjectionHours(IIndex(i)) & ...
        superMagData.UTCMinutes == injectionDB.UTCInjectionMinutes(IIndex(i)));
    SMRIIndex(i) = temp(1);
end

for i = 1 : numW
    temp = find(superMagData.month == injectionDB.month(WIndex(i)) & ...
        superMagData.UTCHours == injectionDB.UTCInjectionHours(WIndex(i)) & ...
        superMagData.UTCMinutes == injectionDB.UTCInjectionMinutes(WIndex(i)));
    SMRWIndex(i) = temp(1);
end

for i = 1 : numE
    temp = find(superMagData.month == injectionDB.month(EIndex(i)) & ...
        superMagData.UTCHours == injectionDB.UTCInjectionHours(EIndex(i)) & ...
        superMagData.UTCMinutes == injectionDB.UTCInjectionMinutes(EIndex(i)));
    SMREIndex(i) = temp(1);
end


%Make histograms of the injection types of the injection data base.
%generateInjectionTypeHistograms(injectionDB, IIndex, WIndex, EIndex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find the maximum month being analyzed.
maxMonth = max(injectionDB.month);

fig3 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig3.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

satellite = 'STPSat-6';
instrument = 'SEED';
plotType = 'Histogram';
year = 2022;
startMonth = 1;
endMonth = maxMonth;
startDayOfYear = 15;
endDayOfYear = 101;
dateStr = [num2str(year), num2str(startMonth, '%02d'), '-', ...
    num2str(year), num2str(endMonth, '%02d')];
doyStr = [num2str(startDayOfYear, '%03d'), '_', num2str(endDayOfYear, '%03d')];


saveName = [satellite, '_', instrument, '_', plotType, '_Total',  ...
   dateStr, '_', doyStr];

SEEDFileName = strcat('/SS1/STPSat-6/AGU2023/', saveName, '.png');



%Now generate a histogram of the local time hours.
histogram(ax, injectionDB.LTInjectionHours, 0:23)
xlabel('Local Time (Hours)')
xlim([0 23])
ylabel('Number of events')
title('Histogram of SEED injection events of all types for local time')
xticks([0 5 11 17 23])
xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})


%Save the time series to a file.
saveas(fig3, SEEDFileName);




%Let us look at the data for a given month of the year.
monthLocalTimeHistogram = zeros(24, maxMonth);

for month = 1 : maxMonth
    monthIndex = find(injectionDB.month == month & char(injectionDB.injectionType) == 'I');
    for h = 0 : 23
        numEventsPerHour = length(find(injectionDB.LTInjectionHours(monthIndex) == h));
        monthLocalTimeHistogram(h + 1, month) = numEventsPerHour;
    end
end


fig2 = figure('DefaultAxesFontSize', 12);
ax2 = axes();
fig2.Position = [750 25 1200 500];
ax2.Position = [0.13, 0.11, 0.775, 0.8150];

satellite = 'STPSat-6';
instrument = 'SEED';
plotType = 'Monthly_Histogram';
year = 2022;
startMonth = 1;
endMonth = maxMonth;
startDayOfYear = 15;
endDayOfYear = 156;
dateStr = [num2str(year), num2str(startMonth, '%02d'), '-', ...
    num2str(year), num2str(endMonth, '%02d')];
doyStr = [num2str(startDayOfYear, '%03d'), '_', num2str(endDayOfYear, '%03d')];

saveName2 = [satellite, instrument, plotType, '_',  ...
   dateStr, '_', doyStr];

SEEDFileName2 = strcat('/SS1/STPSat-6/AGU2023/', saveName2, '.png');



xTickValues = [0, 5, 11, 17, 23];
xTickLabels = ['Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'];

%Now generate a histogram of the local time hours.
subplot(4, 2, 1)
bar(1:24, monthLocalTimeHistogram(:, 1), 1.0)
xlim([0 23])
title('Histogram of SEED injection events - January')
set(gca,'xticklabel',[])

subplot(4, 2, 2)
bar(1:24, monthLocalTimeHistogram(:, 2), 1.0)
xlim([0 23])
title('Histogram of SEED injection events - February')
set(gca,'xticklabel',[])

subplot(4, 2, 3)
bar(1:24, monthLocalTimeHistogram(:, 3), 1.0)
xlim([0 23])
%ylabel('Number of events')
title('Histogram of SEED injection events - March')
set(gca,'xticklabel',[])

subplot(4, 2, 4)
bar(1:24, monthLocalTimeHistogram(:, 4), 1.0)
xlim([0 23])
title('Histogram of SEED injection events - April')
set(gca,'xticklabel',[])

subplot(4, 2, 5)
bar(1:24, monthLocalTimeHistogram(:, 5), 1.0)
xlim([0 23])
title('Histogram of SEED injection events - May')
set(gca,'xticklabel',[])

subplot(4, 2, 6)
bar(1:24, monthLocalTimeHistogram(:, 6), 1.0)
xlim([0 23])
title('Histogram of SEED injection events - June')
set(gca,'xticklabel',[])

subplot(4, 2, 7)
bar(1:24, monthLocalTimeHistogram(:, 7), 1.0)
xlabel('Local Time (Hours)')
xlim([0 23])
title('Histogram of SEED injection events - July')
xticks([0 5 11 17 23])
xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})


%Now generate a histogram of the local time hours.
subplot(4, 2, 8)
bar(1:24, monthLocalTimeHistogram(:, 8), 1.0)
xlabel('Local Time (Hours)')
xlim([0 23])
title('Histogram of SEED injection events - August')
xticks([0 5 11 17 23])
xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})





%Save the time series to a file.
saveas(fig2, SEEDFileName2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig3 = figure('DefaultAxesFontSize', 12);
ax3 = axes();
fig3.Position = [750 25 1200 500];
ax3.Position = [0.13, 0.11, 0.775, 0.8150];

satellite = 'STPSat-6';
instrument = 'SEED';
plotType = 'Monthly_Histogram';
year = 2022;
startMonth = 6;
endMonth = maxMonth;
startDayOfYear = 157;
endDayOfYear = 158;
dateStr = [num2str(year), num2str(startMonth, '%02d'), '-', ...
    num2str(year), num2str(endMonth, '%02d')];
doyStr = [num2str(startDayOfYear, '%03d'), '_', num2str(endDayOfYear, '%03d')];

saveName3 = [satellite, instrument, plotType, '_',  ...
   dateStr, '_', doyStr];

SEEDFileName3 = strcat('/SS1/STPSat-6/Plots/', saveName3, '.png');

xTickValues = [0, 5, 11, 17, 23];
xTickLabels = ['Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'];

%Now generate a histogram of the local time hours.
subplot(5, 1, 1)
bar(1:24, monthLocalTimeHistogram(:, 6), 1.0)
xlim([0 23])
title('Histogram of SEED injection events for local time - June')
set(gca,'xticklabel',[])

% %Now generate a histogram of the local time hours.
% subplot(5, 1, 2)
% bar(1:24, monthLocalTimeHistogram(:, 2), 1.0)
% xlim([0 23])
% title('Histogram of SEED injection events for local time - February')
% set(gca,'xticklabel',[])
% 
% %Now generate a histogram of the local time hours.
% subplot(5, 1, 3)
% bar(1:24, monthLocalTimeHistogram(:, 3), 1.0)
% xlim([0 23])
% ylabel('Number of events')
% title('Histogram of SEED injection events for local time - March')
% set(gca,'xticklabel',[])
% 
% %Now generate a histogram of the local time hours.
% subplot(5, 1, 4)
% bar(1:24, monthLocalTimeHistogram(:, 4), 1.0)
% xlim([0 23])
% title('Histogram of SEED injection events for local time - April')
% set(gca,'xticklabel',[])
% 
% %Now generate a histogram of the local time hours.
% subplot(5, 1, 5)
% bar(1:24, monthLocalTimeHistogram(:, 5), 1.0)
% xlabel('Local Time (Hours)')
% xlim([0 23])
% %ylabel('Number of events')
% title('Histogram of SEED injection events for local time - May')
% xticks([0 5 11 17 23])
% xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})

%Save the time series to a file.
saveas(fig3, SEEDFileName3);

























































































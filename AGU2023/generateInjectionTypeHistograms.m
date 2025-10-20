function generateInjectionTypeHistograms(injectionDB, IIndex, WIndex, ...
    EIndex)

%This function will create histograms of the injection types of the SEED
%injection database. It is called by ReadInjectionDB.m


%Find the maximum month being analyzed.
maxMonth = max(injectionDB.month);


fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];
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

saveName = [satellite, instrument, plotType, '_I',  ...
   dateStr, '_', doyStr];

SEEDFileName = strcat('/SS1/STPSat-6/AGU2023/', saveName, '.png');

xTickValues = [0, 5, 11, 17, 23];
xTickLabels = ['Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'];

%Now generate a histogram of the local time hours.
histogram(ax, injectionDB.LTInjectionHours(IIndex), 0:23)
xlabel('Local Time (Hours)')
xlim([0 23])
ylabel('Number of events')
title('Histogram of SEED injection events of type Injection for local time')
xticks([0 5 11 17 23])
xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})

%Save the time series to a file.
saveas(fig1, SEEDFileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig2.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

saveName = [satellite, instrument, plotType, '_W',  ...
   dateStr, '_', doyStr];

SEEDFileName = strcat('/SS1/STPSat-6/AGU2023/', saveName, '.png');


%Now generate a histogram of the local time hours.
histogram(ax, injectionDB.LTInjectionHours(WIndex), 0:23)
xlabel('Local Time (Hours)')
xlim([0 23])
ylabel('Number of events')
title('Histogram of SEED injection events of type Weak Injection for local time')
xticks([0 5 11 17 23])
xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})

%Save the time series to a file.
saveas(fig2, SEEDFileName);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig3 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig3.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

saveName = [satellite, instrument, plotType, '_E',  ...
   dateStr, '_', doyStr];

SEEDFileName = strcat('/SS1/STPSat-6/AGU2023/', saveName, '.png');


%Now generate a histogram of the local time hours.
histogram(ax, injectionDB.LTInjectionHours(EIndex), 0:23)
xlabel('Local Time (Hours)')
xlim([0 23])
ylabel('Number of events')
title('Histogram of SEED injection events of type Echo for local time')
xticks([0 5 11 17 23])
xticklabels({'Midnight', 'Dawn', 'Noon', 'Dusk', 'Midnight'})

%Save the time series to a file.
saveas(fig3, SEEDFileName);

end  %End of the function generateInjectionTypeHistograms.m
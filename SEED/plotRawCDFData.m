function plotRawCDFData(info, timeInNanoseconds, SEEDData, DoseData)


%Make a plot of the dosimeter and SEED data.

spacecraft = "Falcon";
mission = "STPSat-6";
instrument = "Dosimeter";
date = info.startDateStr;
doy = info.startDayOfYearStr;

titleStr = 'Raw' + " " + spacecraft + " " + mission + " " + ...
    instrument + " " + date + " " + doy;

SEEDTitleStr = 'Raw' + " " + spacecraft + " " + mission + " " + ...
    'SEED' + " " + date + " " + doy;

DosimeterSaveName = spacecraft + mission + "_Raw_" + instrument + ...
    "_" + date + "_" + doy;

SEEDSaveName  = spacecraft + mission + "_Raw_" + ...
    'SEED' + "_" + date + "_" + doy;

DosimeterFileName = strcat(info.dosimeterPlotDir, DosimeterSaveName, '.png');
SEEDFileName = strcat(info.SEEDPlotDir, SEEDSaveName, '.png');

%Set the figure width and height and x position.
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.70, 0.42, 0.14];

fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];
  
%Lets set the time to start from 0 and also be fractions of seconds.
time = (timeInNanoseconds - timeInNanoseconds(1))*1e-9;
DosimeterCounts = rawDosimeterData.DOSEData;

xtickSValues = [10219, 12793, 15478, 17991, 20452];
xtickLabels = {'2:00', '2:30', '3:00', '3:30', '4:00'};

sp1 = subplot(3, 1, 1); 
plot(time(7200:14400), DosimeterCounts(7200:14400, 1), 'b.')
sp1.XTick = xtickSValues;
ylabel('Counts');
title(titleStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
ylim([min(DosimeterCounts(7200:14400, 1)) max(DosimeterCounts(7200:14400, 1))])
xlim([time(7200) time(14400)]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(3, 1, 2);
plot(time(7200:14400), DosimeterCounts(7200:14400, 2), 'g.')
sp2.XTick = xtickSValues;
ylabel('Counts');
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
ylim([min(DosimeterCounts(7200:14400, 2)) max(DosimeterCounts(7200:14400, 2))])
xlim([time(7200) time(14400)]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(3, 1, 3);
plot(time(7200:14400), DosimeterCounts(7200:14400, 3), 'r.')
sp3.XTick = xtickSValues;
ylabel('Counts');
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 3', ...
      'FontSize', 15);
ylim([min(DosimeterCounts(7200:14400, 3)) max(DosimeterCounts(7200:14400, 3))])
set(gca, 'Xticklabel', []);
set(sp3, 'Position', [left, bottom(3), width, height]);
xlim([time(7200) time(14400)]);
sp3.XTick = xtickSValues;
sp3.XTickLabel = xtickLabels;
xlabel('UTC Time (Hours)')

%Save the time series to a file.
saveas(fig1, DosimeterFileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 700];
SEEDCounts = rawSEEDData.SEEDData;

EnergyStr1 = ['Energy : ', num2str(info.energyBins(80,2)), ' keV'];
EnergyStr2 = ['Energy : ', num2str(info.energyBins(180,2)), ' keV'];
EnergyStr3 = ['Energy : ', num2str(info.energyBins(280,2)), ' keV'];

sp1 = subplot(3, 1, 1); 
plot(time(7200:14400), SEEDCounts(7200:14400, 200), 'b.')
sp1.XTick = xtickSValues;
ylabel('Counts');
title(SEEDTitleStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', EnergyStr1, ...
      'FontSize', 15);
ylim([min(SEEDCounts(7200:14400, 200)) max(SEEDCounts(7200:14400, 200))])
xlim([time(7200) time(14400)]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(3, 1, 2);
plot(time(7200:14400), SEEDCounts(7200:14400, 300), 'g.')
sp2.XTick = xtickSValues;
ylabel('Counts');
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', EnergyStr2, ...
      'FontSize', 15);
ylim([min(SEEDCounts(7200:14400, 300)) max(SEEDCounts(7200:14400, 300))])
xlim([time(7200) time(14400)]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(3, 1, 3);
plot(time(7200:14400), SEEDCounts(7200:14400, 400), 'r.')
sp3.XTick = xtickSValues;
ylabel('Counts');
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', EnergyStr3, ...
      'FontSize', 15);
ylim([min(SEEDCounts(7200:14400, 400)) max(SEEDCounts(7200:14400, 400))])
set(gca, 'Xticklabel', []);
set(sp3, 'Position', [left, bottom(3), width, height]);
xlim([time(7200) time(14400)]);
sp3.XTick = xtickSValues;
sp3.XTickLabel = xtickLabels;
xlabel('UTC Time (Hours)')

%Save the time series to a file.
saveas(fig2, SEEDFileName);


end  %End of the function plotRawCDFData
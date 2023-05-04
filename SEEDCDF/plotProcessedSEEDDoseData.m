function plotProcessedSEEDDoseData(info, DosimeterCounts, TT2000Time, ...
    fluxAll, flux15, SEEDTime)

spacecraft = "Falcon";
mission = "STPSat-6";
instrument = "Dosimeter";
date = info.startDateStr;
doy = info.startDayOfYearStr;

titleStr = 'Processed' + " " + spacecraft + " " + mission + " " + ...
    instrument + " " + date + " " + doy;

SEEDTitleStr = 'Processed' + " " + spacecraft + " " + mission + " " + ...
    'SEED' + " " + date + " " + doy;

saveName = spacecraft + mission + "_Processed_" + instrument + "_" + ...
    date + "_" + doy;
SEEDSaveName  = spacecraft + mission + "_Processed_" + 'SEED' + "_" + ...
    date + "_" + doy;

DosimeterFileName = strcat(info.dosimeterPlotDir, saveName, '.png');
SEEDFileName = strcat(info.SEEDPlotDir, SEEDSaveName, '.png');

%Set the figure width and height and x position.
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.70, 0.42, 0.14];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Dosimeter Time Series Plots %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];

%Lets handle the times.  We need to convert from TT2000 to datenum and then
%from datenums to datetimes.  
dateNumTime = spdftt2000todatenum(TT2000Time);
d = datetime(dateNumTime,'ConvertFrom','datenum');

%Now lets find the datetimes we are interested in.
dHour = hour(d);
dHIndex = find(dHour >= 2 & dHour < 4);

%Make the plots.
sp1 = subplot(3, 1, 1); 
plot(dateNumTime(dHIndex), DosimeterCounts.channel1(dHIndex), 'b')
ylabel('Counts');
title(titleStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
ylim([min(DosimeterCounts.channel1(dHIndex)), ...
    max(DosimeterCounts.channel1(dHIndex))])
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(3, 1, 2);
plot(dateNumTime(dHIndex), DosimeterCounts.channel2(dHIndex), 'g')
ylabel('Counts');
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
ylim([min(DosimeterCounts.channel2(dHIndex)), ... 
    max(DosimeterCounts.channel2(dHIndex))])
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(3, 1, 3);
plot(dateNumTime(dHIndex), DosimeterCounts.channel2(dHIndex), 'r')
datetick('x', 'HH:MM')
ylabel('Counts');
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 3', ...
      'FontSize', 15);
ylim([min(DosimeterCounts.channel2(dHIndex)), ... 
    max(DosimeterCounts.channel2(dHIndex))])
set(sp3, 'Position', [left, bottom(3), width, height]);
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
xlabel('UTC Time (Hours)')

%Save the time series to a file.
saveas(fig1, DosimeterFileName);

%Make a close-up of the first channel.
fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 700];

%Generate a title string.
closeupTitleStr = 'Processed' + " " + spacecraft + " " + mission + " " + ...
    instrument + " " + date + " " + doy;

%Generate a file name.
saveName = spacecraft + mission + "_Processed_Channel_1" + instrument + "_" + ...
    date + "_" + doy;
DosimeterCloseupFileName = strcat(info.dosimeterPlotDir, saveName, '.png');


plot(dateNumTime(dHIndex), DosimeterCounts.channel1(dHIndex), 'b')
datetick('x', 'HH:MM')
ylabel('Counts')
xlabel('UTC Time (Hours)')
title(closeupTitleStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
ylim([-6, 10])
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
hold on
plot([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))], [0 0], 'r', ...
    'LineWidth', 5)

%Save the time series to a file.
saveas(fig2, DosimeterCloseupFileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% SEED Time Series Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fig3 = figure('DefaultAxesFontSize', 12);
fig3.Position = [750 25 1200 700];

EnergyBin1 = 80;
EnergyBin2 = 180;
EnergyBin3 = 280;

EnergyStr1 = ['Energy : ', num2str(info.energyBins(EnergyBin1, 2), '%6.2f'), ' keV'];
EnergyStr2 = ['Energy : ', num2str(info.energyBins(EnergyBin2, 2), '%6.2f'), ' keV'];
EnergyStr3 = ['Energy : ', num2str(info.energyBins(EnergyBin3, 2), '%6.2f'), ' keV'];

%Lets handle the times.  We need to convert from TT2000 to datenum and then
%from datenums to datetimes.  
dateNumTime = spdftt2000todatenum(SEEDTime.TT2000);
dateNumTimeDt15 = spdftt2000todatenum(SEEDTime.dt15TT2000');

%Here are the datetime values.
d = datetime(dateNumTime,'ConvertFrom','datenum');
d15 = datetime(dateNumTimeDt15,'ConvertFrom','datenum');

%Now lets find the datetimes we are interested in.
dHour = hour(d);
dHIndex = find(dHour >= 2 & dHour < 4);

d15Hour = hour(d15);
d15HIndex = find(d15Hour >= 2 & d15Hour < 4);

sp1 = subplot(3, 1, 1); 
plot(dateNumTime(dHIndex), fluxAll(dHIndex, EnergyBin1), 'b', ...
    dateNumTimeDt15(d15HIndex), flux15(d15HIndex, EnergyBin1), 'g')
title(SEEDTitleStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', EnergyStr1, ...
      'FontSize', 15);
%ylim([min(fluxAll(dHIndex, EnergyBin1)) max(fluxAll(dHIndex, EnergyBin1))])
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);
legend('Normal Time', 'Time - delta t = 15')

sp2 = subplot(3, 1, 2);
plot(dateNumTime(dHIndex), fluxAll(dHIndex, EnergyBin2), 'b', ...
    dateNumTimeDt15(d15HIndex), flux15(d15HIndex, EnergyBin2), 'g')
%sp2.XTick = xtickSValues;
ylabel('Flux (Counts/keV-ster-cm^{2}-s)');
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', EnergyStr2, ...
      'FontSize', 15);
%ylim([min(fluxAll(dHIndex, EnergyBin1)) max(fluxAll(dHIndex, EnergyBin1))])
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);
legend('Normal Time', 'Time - delta t = 15')

sp3 = subplot(3, 1, 3);
plot(dateNumTime(dHIndex), fluxAll(dHIndex, EnergyBin2), 'b', ...
    dateNumTimeDt15(d15HIndex), flux15(d15HIndex, EnergyBin2), 'g')
datetick('x', 'HH:MM')
%sp3.XTick = xtickSValues;
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', EnergyStr3, ...
      'FontSize', 15);
%ylim([min(fluxAll(dHIndex, EnergyBin1)) max(fluxAll(dHIndex, EnergyBin1))])
xlim([dateNumTime(dHIndex(1)) dateNumTime(dHIndex(end))]);
set(sp3, 'Position', [left, bottom(3), width, height]);
xlabel('UTC Time (Hours)')
legend('Normal Time', 'Time - delta t = 15')

%Save the time series to a file.
saveas(fig3, SEEDFileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% SEED Spectrogram  Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fig4 = figure('DefaultAxesFontSize', 12);
fig4.Position = [750 25 1200 700];

yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [info.energyBins(1), info.energyBins(end)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];


satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

%Just check to see if that data makes sense.
dateFormat = 'HH';
time = double((SEEDTime.TT2000 - SEEDTime.TT2000(1))*1.0e-9);
energyBins = info.energyBins(:, 2);
data = fluxAll;

imagesc(time, energyBins, log10(data)')
caxis('auto')
datetick('x', dateFormat)
ylabel('Energy (keV)');
title(titStr);
cb = colorbar;
ylabel(cb,'Log10(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;

SEEDSaveName  = spacecraft + mission + "_Spectrogram_" + 'SEED' + "_" + ...
    date + "_" + doy;
SEEDFileName = strcat(info.SEEDPlotDir, SEEDSaveName, '.png');

%Save the time series to a file.
saveas(fig4, SEEDFileName);






end  %End of the function plotProcessedSEEDDoseData.m
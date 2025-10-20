function makeSpectra4(info, time, flux, energyBins)



%This function is called by FalconSEEDTestSpectrogram.m

%Determine the number of events.
[numEvents, numEnergyBins] = size(flux.deltat15FluxActual);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram ";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;


rawTitStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr + " " + 'Raw Data';
deltat15TitStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr + " " + 'Delta t = 15 s.';

saveName = satellite + instrument + dateStr + "_" + doyStr + ...
    "_" + num2str(info.numEnergyBinsToSum) + "_" + info.startHourStr + "_" + ...
    info.endHourStr;


fig1FileName = strcat(info.SEEDPlotDir, 'Spectrogram/', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%Let's find the energy channels of interest.
energyIndex = 1:numEnergyBins;


%Now we find the times of interest.
timeInSecondsStart = info.startHour*3600 + info.startMinute*60 + info.startSecond;
timeInSecondsEnd = info.endHour*3600 + info.endMinute*60 + info.endSecond;

%Get the index of the times to be plotted.
timeIndex = find(time.eventSeconds > timeInSecondsStart & ...
    time.eventSeconds < timeInSecondsEnd);


%Set up the y-axis labels and limits.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [energyBins(energyIndex(1), 1), energyBins(energyIndex(end), 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set up the x-axis limits.
xLimLow = time.eventDateNumber(1);
xLimHigh = time.eventDateNumber(end);
xLimValues = [xLimLow, xLimHigh];

%Make the datetick tick values.
xTicks = zeros(1, 24);
for i = 1 : 24
    hh = info.startHour + i - 1;
    mm = 0;
    ss = 0;
    xTicks(i) = datenum(info.startYear, info.startMonth, info.startDayOfMonth, ...
        hh, mm, ss);
end


dateFormat = 'HH';

%set up the data array for plotting.
%First we get rid of any zero values.
flux.rawFluxActual(flux.rawFluxActual <= 0) = 1;
flux.deltat15FluxActual(flux.deltat15FluxActual == 0) = 1;

rawData = log10(flux.rawFluxActual(timeIndex, energyIndex));
deltat15Data = log10(flux.deltat15FluxActual(timeIndex, energyIndex));


[rawRow, rawCol] = find(isnan(rawData));
rawData(rawRow, rawCol) = 0;

[rawRow, rawCol] = find(isnan(deltat15Data));
deltat15Data(rawRow, rawCol) = 0;


sp1 = subplot(2, 1, 1);
imagesc(time.eventDateNumber, energyBins(energyIndex, 2), rawData')
xticks(xTicks)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
caxis([3 6])
title(rawTitStr);
ylabel('Energy (keV)');
ylim(yLimValues)
yticklabels(yTickLabels)
yticks(yTickValues)
xlim(xLimValues);
set(gca,'YDir','normal')
cb = colorbar;
ylabel(cb,'Log10(Flux)') 

sp2 = subplot(2, 1, 2);
imagesc(time.eventDateNumber, energyBins(energyIndex, 2), deltat15Data')
xticks(xTicks)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
caxis([3 5])
title(deltat15TitStr);
ylabel('Energy (keV)');
ylim(yLimValues)
yticklabels(yTickLabels)
yticks(yTickValues)
xlim(xLimValues);
set(gca,'YDir','normal')
cb = colorbar;
ylabel(cb,'Log10(Flux)') 

%Save the spectra to a file.
saveas(fig1, fig1FileName);


end
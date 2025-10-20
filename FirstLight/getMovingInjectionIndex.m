function movingInjectionIndex = getMovingInjectionIndex(info, SEEDElectronFlux, ...
    energyBin, sigmaValue, stepsToSkip, movingAverageLength, dt)

%This function is called by plotSEEDFirstLightTimeSeries.m.  This function
%will return an index that will be used to plot the location of electron
%injections.  

%dt contains the time intervals in terms of the datetime object.
%SEEDElectronFlux is input as [1163,904]



%Determine the number of data points and energy bins.
[numDataPoints, numEnergyBins] = size(SEEDElectronFlux);

maFlux = zeros(numDataPoints, numEnergyBins);
maStd = zeros(numDataPoints, numEnergyBins);

dtYear = dt.Year;
dtMonth = dt.Month;
dtDayOfMonth = dt.Day;
dtHours = dt.Hour;
dtMinutes = dt.Minute;
dtSeconds = dt.Second;

d = datenum(dt);

numDays = info.endMissionDayNumber - info.startMissionDayNumber + 1;

[maFlux, maStd, injectionValues] = ...
    getInjectionValues(info, SEEDElectronFlux, stepsToSkip, movingAverageLength, ...
    sigmaValue, d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plotFirstArrival = 0;

if plotFirstArrival == 1

    %Set up the figure handle.
    fig1 = figure('DefaultAxesFontSize', 12);
    ax = axes();
    fig1.Position = [750 25 1200 500];
    ax.Position = [0.13, 0.11, 0.775, 0.8150];


    %Just check to see if that data makes sense.
    dateFormat = 'DD';

    satellite = "STPSat-6";
    instrument = "SEED";
    plotType = "TimeSeries";

    if numDays == 1
        dateStr = [num2str(dtYear(1)), num2str(dtMonth(1), '%02d'), ...
            num2str(dtDayOfMonth(1), '%02d')];
        doyStr = num2str(info.startDayOfYear, '%03d');
    else
        dateStr = [num2str(dtYear(1)), num2str(dtMonth(1), '%02d'), ...
            num2str(dtDayOfMonth(1), '%02d'), '-', num2str(dtYear(end)), ...
            num2str(dtMonth(end), '%02d'), num2str(dtDayOfMonth(end), '%02d')];
        doyStr = [num2str(info.startDayOfYear, '%03d'), '-', ...
            num2str(info.endDayOfYear, '%03d')];
    end


    titStr = satellite + " " + instrument + " " + ...
        "Injection Arrival Times (Dispersion?)" + " " + dateStr + ...
        " " + doyStr;

    saveName = satellite + instrument + plotType + "_" + ...
        dateStr + "_" + doyStr;

    SEEDFileName = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');

    yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
    yLimValues = [info.energyBins(1, 1), info.energyBins(end, 3)];
    yTickValues = [20, 40, 60, 80, 100, 120, 140];


    %Generate the energy bins.  The values are in keV.  The delta E, number of
    %energy bins and offset are determined from the paper.
    deltaEnergy = 0.1465;  %In units of keV.
    energyBinOffset = -3.837;  %In units of keV.
    numEnergyBins = 1024;
    ebin = 0:1023;
    energyBins = deltaEnergy*ebin + energyBinOffset;
    energyBins = energyBins(121:end);

    d = datenum(dt);
    yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
    yLimValues = [info.energyBins(1, 1), info.energyBins(end, 3)];
    yTickValues = [20, 40, 60, 80, 100, 120, 140];

    arrivalTime = second(d(ii));
    %arrivalTime = arrivalTime - min(arrivalTime);

    plot(arrivalTime, energyBins, 'b')
    title(titStr);
    ylabel('Energy (keV)')
    xlabel('Relative Arrival Time (s)')
    yticks(yTickValues)
    yticklabels(yTickLabels)
    ylim(yLimValues)

    %Save the time series to a file.
    saveas(fig1, SEEDFileName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Set up the figure handle.
fig2 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig2.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "STPSat-6";
instrument = "SEED";
plotType = "DifferencedSpectrogram";

if numDays == 1 
    dateStr = [num2str(dtYear(1)), num2str(dtMonth(1), '%02d'), ...
        num2str(dtDayOfMonth(1), '%02d')];
    doyStr = num2str(info.startDayOfYear, '%03d');
else
    dateStr = [num2str(dtYear(1)), num2str(dtMonth(1), '%02d'), ...
        num2str(dtDayOfMonth(1), '%02d'), '-', num2str(dtYear(end)), ...
    num2str(dtMonth(end), '%02d'), num2str(dtDayOfMonth(end), '%02d')];
    doyStr = [num2str(info.startDayOfYear, '%03d'), '-', ...
        num2str(info.endDayOfYear, '%03d')];
end


titStr = satellite + " " + instrument + " " + "Differenced Spectrogram" + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

SEEDFileName1 = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');

yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [info.energyBins(1, 1), info.energyBins(end, 3)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

energyBins = info.energyBins(:, 2);


%Set up the x-axis tick labels and limits.
xTickLabels = {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...
	16, 17, 18, 19, 20, 21, 22, 23, 0]};

xLimValues = [d(1), d(end)];

dVec = [dtYear(1)*ones(1, 25); dtMonth(1)*ones(1, 25); ...
    dtDayOfMonth(1)*ones(1, 25); [0:24]; zeros(1, 25); zeros(1, 25)]';

xTickVals = datenum(dVec);


%fluxDiff = diff(SEEDElectronFlux);
fluxDiff = [SEEDElectronFlux(1,:); diff(SEEDElectronFlux)];

%Convert from the datetime structure into seconds from start of the day.
timeSeconds = seconds(dt - dt(1));

%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;

%Set up an interpolated flux array of size [5760,904]
interpFluxDiff = zeros(length(tt), numEnergyBins);

smoothConstant = 50;

%Now we loop through the energy channels.
for e = 1 : 904
    y = fluxDiff(:, e);
    interpFluxDiff(:, e) = smoothdata(interp1(timeSeconds, y, tt, 'linear'), ...
        'gaussian', smoothConstant);
end


imagesc(d, energyBins, interpFluxDiff')
caxis([-2 2])
%caxis('auto')
ylabel('Energy (keV)');
xlabel('Time (UTC)')
title(titStr);
cb = colorbar;
ylabel(cb,'Differenced Flux') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;
ax.XTick = xTickVals;
ax.XLim = xLimValues;
ax.XTickLabel = xTickLabels;

%Save the time series to a file.
saveas(fig2, SEEDFileName1);


end  %End of the function getMovingInjectionIndex.m
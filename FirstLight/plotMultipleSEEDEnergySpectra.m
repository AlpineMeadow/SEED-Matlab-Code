function plotMultipleSEEDEnergySpectra(info, numEnergyBins, SEEDFlux)

%This function is called by plotSEEDLocalTimeEnergySpectra.m.  It will make
%24 hour plots (on two separate files) of the energy spectra as a function
%of energy for each hour of local time.

xTickLabelsSEED = {[20, 40, 60, 80, 100, 120, 140]};
xLimValuesSEED = [20, 150];
xTickValuesSEED = [20, 40, 60, 80, 100, 120, 140];
SEEDEnergyBins = info.energyBins(:, 2);


titStr = ['Plot of Flux Versus Energy for Local Time for Day ', ...
    info.startDayOfYearStr, '-', info.endDayOfYearStr];

%Lets just check out what the counts look like.
fig1 = figure('DefaultAxesFontSize', 12);
ax1 = axes();
fig1.Position = [750 25 1200 500];
ax1.Position = [0.13, 0.11, 0.775, 0.8150];
ax = gca();

hourIndex = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
LocalHourValueLow = [18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5];
LocalHourValueHigh = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

for i = 1 : 12
    legendStr = ['Local Time Hour : ', num2str(LocalHourValueLow(i))];
    subplot(4, 3, i)

    f = log10(SEEDFlux.deltat15FluxActual(i, :));
    lF = log10(SEEDFlux.deltat15FluxLow(i, :));
    hF = log10(SEEDFlux.deltat15FluxHigh(i, :));

    hold on
    %Loop through the energy bins.
    for e = 1 : numEnergyBins
        eLow = info.energyBins(e, 1);
        eMiddle = info.energyBins(e, 2);
        eHigh = info.energyBins(e, 3);

        yy = semilogy([eLow, eHigh], [f(e), f(e)], 'black', ...
            [eMiddle, eMiddle], [lF(e), hF(e)], 'black');
        ylim([3 8])
    end  %End of for loop - for e = 1 : numEnergyBins
%    legend(legendStr)
    xticks(xTickValuesSEED)
    xlim(xLimValuesSEED)
    xticklabels(xTickLabelsSEED)
    text('Units', 'Normalized', 'Position', [0.45, 0.9], 'string', legendStr, ...
      'FontSize', 10);
    if i == 2
        title(titStr)
    end

    if i == 1 | i == 4 | i == 7 | i == 10
        ylabel('Flux')
    end

    if i == 10 | i == 11 | i == 12
        xlabel('Energy (keV)')   
    end
    hold off
end

saveName = ['STPSat-6LocalTimeEnergySpectraEarly_', info.startDateStr, ...
    '-', info.endDateStr, '_', info.startDayOfYearStr, '-', ...
    info.endDayOfYearStr, '.pdf'];
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName);
orientation = 'landscape';
writePDFFile(filename, orientation);

%Lets just check out what the counts look like.
fig2 = figure('DefaultAxesFontSize', 12);
ax2 = axes();
fig2.Position = [750 25 1200 500];
ax2.Position = [0.13, 0.11, 0.775, 0.8150];

for i = 1 : 12
    index = i + 12;
    legendStr = ['Local Time Hour : ', num2str(LocalHourValueHigh(i))];
    subplot(4, 3, i)

    f = log10(SEEDFlux.deltat15FluxActual(index, :));
    lF = log10(SEEDFlux.deltat15FluxLow(index, :));
    hF = log10(SEEDFlux.deltat15FluxHigh(index, :));

    hold on
    %Loop through the energy bins.
    for e = 1 : numEnergyBins
        eLow = info.energyBins(e, 1);
        eMiddle = info.energyBins(e, 2);
        eHigh = info.energyBins(e, 3);

        yy = semilogy([eLow, eHigh], [f(e), f(e)], 'black', ...
            [eMiddle, eMiddle], [lF(e), hF(e)], 'black');
        ylim([3 8])
    end  %End of for loop - for e = 1 : numEnergyBins

    xticks(xTickValuesSEED)
    xlim(xLimValuesSEED)
    xticklabels(xTickLabelsSEED)
    text('Units', 'Normalized', 'Position', [0.45, 0.9], 'string', legendStr, ...
      'FontSize', 10);
    if i == 2
        title(titStr)
    end

    if i == 1 | i == 4 | i == 7 | i == 10
        ylabel('Flux')
    end

    if i == 10 | i == 11 | i == 12
        xlabel('Energy (keV)')   
    end
    hold off
end

saveName = ['STPSat-6LocalTimeEnergySpectraLate_', info.startDateStr, ...
    '-', info.endDateStr, '_', info.startDayOfYearStr, '-', ...
    info.endDayOfYearStr, '.pdf'];
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName);
orientation = 'landscape';
writePDFFile(filename, orientation);

end  %End of the function plotMultipleSEEDEnergySpectra.m
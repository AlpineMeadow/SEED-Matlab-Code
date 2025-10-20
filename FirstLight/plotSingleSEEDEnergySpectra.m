function plotSingleSEEDEnergySpectra(info, numEnergyBins, newSEEDFlux)

%Lets just check out what the counts look like.
fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 500];
ax2 = gca();
ax2.Position = [0.13, 0.11, 0.775, 0.8150];


xTickLabelsSEED = {[20, 40, 60, 80, 100, 120, 140]};
xLimValuesSEED = [20, 146];
xTickValuesSEED = [20, 40, 60, 80, 100, 120, 140];
SEEDEnergyBins = info.energyBins(:, 2);

l1Str = 'Local Time Hour 18';
l2Str = 'Local Time Hour 19';
l3Str = 'Local Time Hour 20';
l4Str = 'Local Time Hour 21';
l5Str = 'Local Time Hour 22';
l6Str = 'Local Time Hour 23';
l7Str = 'Local Time Hour 0';
l8Str = 'Local Time Hour 1';
l9Str = 'Local Time Hour 2';
l10Str = 'Local Time Hour 3';
l11Str = 'Local Time Hour 4';
l12Str = 'Local Time Hour 5';
l13Str = 'Local Time Hour 6';
l14Str = 'Local Time Hour 7';
l15Str = 'Local Time Hour 8';
l16Str = 'Local Time Hour 9';
l17Str = 'Local Time Hour 10';
l18Str = 'Local Time Hour 11';
l19Str = 'Local Time Hour 12';
l20Str = 'Local Time Hour 13';
l21Str = 'Local Time Hour 14';
l22Str = 'Local Time Hour 15';
l23Str = 'Local Time Hour 16';
l24Str = 'Local Time Hour 17';

titStr = ['Plot of Flux Versus Energy for Local Time for Day ', ...
    info.startDayOfYearStr, '-', info.endDayOfYearStr];

colorVector = ["#00FF00", "#0000FF", "#000000", "#FFFF00", "#FF00FF", ...
    "#00FFFF", "#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", ...
    "#FF0000", "#AA1122", "#BB1122", "#CC1122", "#DD1122", "#EE1122", ...
    "#FF1122", "#AA3434", "#BB3434", "#CC3434", "#DD3434", "#EE3434", ...
    "#FF3434"];

hold on;
for i = 1 : 24
    f = newSEEDFlux.deltat15FluxActual(i, :);
    lF = newSEEDFlux.deltat15FluxLow(i, :);
    hF = newSEEDFlux.deltat15FluxHigh(i, :);

    for e = 1 : numEnergyBins
        eLow = info.energyBins(e, 1);
        eMiddle = info.energyBins(e, 2);
        eHigh = info.energyBins(e, 3);
%        yy = semilogy(ax2, [eLow, eHigh], [f(e), f(e)], 'Color', colorVector(i), ...
%            [eMiddle, eMiddle], [hF(e), lF(e)], 'Color', colorVector(i))
        yy = semilogy(ax2, [eLow, eHigh], [f(e), f(e)], 'k', ...
            [eMiddle, eMiddle], [hF(e), lF(e)], 'k');
    end  %End of for loop - for e = 1 : numEnergyBins

end  %End of for loop - for i = 1: 24
legend(l1Str, l2Str, l3Str, l4Str, l5Str, l6Str, l7Str, l8Str, ...
    l9Str, l10Str, l11Str, l12Str, l13Str, l14Str, l15Str,l16Str, l17Str,...
    l18Str,l19Str, l20Str, l21Str, l22Str, l23Str, l24Str)
xlim(xLimValuesSEED)
xticklabels(xTickLabelsSEED)
xlabel('Energy (keV)') 
ylabel('Flux (Counts s^{-1} keV^{-1} sr^{-1} cm^{-2})')
title(titStr)

end  %End of the function plotSingleSEEDEnergySpectra.m
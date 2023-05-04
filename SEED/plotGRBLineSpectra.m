function plotGRBLineSpectra(info, time, flux, energyBins, dataAttributes)
%Detemine the number of energy bins.
numEnergyBins = length(energyBins(:, 2));

%This function is called by FalconSEEDSummary.m

[m, ~] = size(flux.fluxActual);

startHour = 1;
endHour = 24;
numHours = endHour - startHour + 1;

timeStartIndex = fix(m/24)*startHour;
timeEndIndex = fix(m/24)*endHour;

a = "Falcon";
b = "SEED";
c = "EnergySpectra";
d = [info.yearStr, info.monthStr, info.dayOfMonthStr];
e = dataAttributes.julianday;

titleStr = a + " " + b + " " + c + " " + d + " " + e;
    
saveName = a + b + c + d + "_" + e;


outFileName = strcat(info.plotSEEDDir, 'LineSpectra/', saveName, '.png');

%Set the figure position information.
left = 750;
bottom = 25;
width = 1200;
height = 500;

%Pick a time for the energy spectra.
timeIndex = 234;
epoch = '6 Jan 1980 00:00:00';
time = time/86400 + datenum(epoch);

timeStr = ['Time - ', datestr(time(timeIndex), 'hh:MM:ss')];

%Set the low and high flux limits.
yMin = 4;
yMax = 8;

%Get the low and high flux values.
lowFlux = flux.fluxLow;
highFlux = flux.fluxHigh;
newFlux = flux.fluxActual;

%Take the log base 10 of the fluxes.
flux = log10(newFlux(timeIndex, :) + 1);
lFlux = log10(lowFlux(timeIndex, :) + 1);
hFlux = log10(highFlux(timeIndex, :) + 1);

%Get a figure handle.
fig1 = figure();
ax = gca();

%Set the gcf position.
set(gcf, 'Position', [left bottom width height]);
hold on

%Plot the fluxes with their associated uncertainty on a semilog y plot.
 for e = 1 : numEnergyBins 
     semilogy([energyBins(e, 1), energyBins(e, 3)], [flux(e), flux(e)], 'black',...
         [energyBins(e, 2), energyBins(e, 2)], [hFlux(e), lFlux(e)], 'black');
 end

%e = 10;
%semilogy([energyBins(e, 1), energyBins(e, 3)], [flux(e), flux(e)], 'black',...
%        [energyBins(e, 2), energyBins(e, 2)], [hFlux(e), lFlux(e)], 'black');
xlabel('Energy (keV)');
title(titleStr);
ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', timeStr, ...
      'FontSize', 15);
ylim(ax, [yMin yMax])
yticks([4 5 6 7 8])
yticklabels({'4', '5', '6', '7', '8'})
xlim([10 150])
xticks(linspace(10, 150, 15))
xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
    '100', '110', '120', '130', '140', '150'})

%Save the spectra to a file.
saveas(fig1, outFileName);


end  %End of the function plotGRBLineSpectra.m
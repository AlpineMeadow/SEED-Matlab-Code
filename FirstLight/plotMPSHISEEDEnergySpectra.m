function plotGOESSEEDEnergySpectra(dt, GOESEnergyBins, GOESElectronFlux)

%This function is called by plotGOESData.m.  It creates a set of
%spectrograms, one for the GOES data and one for the SEED data.


%Set up the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 700];
ax.Position = [0.13, 0.11, 0.775, 0.8150];


yTickLabelsSEED = {[20, 40, 60, 80, 100, 120, 140]};
yLimValuesSEED = [CDFData(1).SEED_Energy_Channels(1), ...
    CDFData(1).SEED_Energy_Channels(end)];
yTickValuesSEED = [20, 40, 60, 80, 100, 120, 140];




satellite1 = "GOES";
instrument1 = "SEISS";

satellite2 = "STPSat-6";
instrument2 = "SEED";

plotType = "Spectrogram";
dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
    num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];

doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];

titStr1 = satellite1 + " " + instrument1 + " " + plotType + " " + dateStr + ...
    " " + doyStr;

titStr2 = satellite2 + " " + instrument2 + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite1 + instrument1 + plotType + "_" + ...
    dateStr + "_" + doyStr;

GOESFileName = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Set up the figure size and location.
left = 0.1;
bottom = [0.56, 0.15];
width = 0.8;
height = 0.34;


sp1 = subplot(2, 1, 1);
imagesc(dt, GOESEnergyBins, log10(GOESElectronFlux))
xticklabels([]);
xticks(xTickValuesGOES);
ylabel('Energy (keV)');
caxis('auto')
caxis([-1 8])
title(titStr1);
cb1 = colorbar;
ylabel(cb1,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
yticks(yTickValuesGOES)
ylim(yLimValuesGOES)
yticklabels(yTickLabelsGOES)
set(sp1, 'Position', [left, bottom(1), width, height]);


SEEDData = newSEEDFlux.deltat15FluxActual;

%Now get rid of zeros.
SEEDData(SEEDData <= 0.1) = 0.1;

time = datenum(SEEDInterpolatedTime);


sp2 = subplot(2, 1, 2);
imagesc(time, SEEDEnergyBins,  log10(SEEDData'))
xticklabels(xTickLabelsSEED);
xticks(xTickValuesSEED);
xlim(xLimValuesSEED);
ylabel('Energy (keV)');
caxis('auto')
caxis([-1 6])
title(titStr2);
xlabel('Date');
cb2 = colorbar;
ylabel(cb2,'Log_{10}(Flux)') 
set(gca,'YDir','normal')
yticks(yTickValuesSEED);
ylim(yLimValuesSEED);
yticklabels(yTickLabelsSEED);
set(sp2, 'Position', [left, bottom(2), width, height]);

%Save the time series to a file.
saveas(fig1, GOESFileName);
end  %End of the function plotGOESSEEDEnergySpectra.m
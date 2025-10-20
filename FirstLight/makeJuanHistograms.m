function makeJuanHistograms(weightedSEEDFlux1, weightedSEEDFlux2)

%This function is written to somehow convince Juan Rodriguez that we are
%not cheating or lying or trying to fuck him over.  It is called by
%plotMPSHIData.m.

%Save the plot as a .png.
dateStr = '20230209-20230227';
doyStr = '040-058';
saveName1 = "Histogram_Weighted_SEED_Energy_Flux_73_" + dateStr + ...
    '_' + doyStr;
saveName2 = "Histogram_Weighted_SEED_Energy_Flux_129_" + dateStr + ...
    '_' + doyStr;

logWeightedSEEDFlux1 = log10(weightedSEEDFlux1);
logWeightedSEEDFlux2 = log10(weightedSEEDFlux2);

flux1Edges = floor(min(logWeightedSEEDFlux1)) : 0.1 : ...
    ceil(max(logWeightedSEEDFlux1));

flux2Edges = floor(min(logWeightedSEEDFlux2)) : 0.1 : ...
    ceil(max(logWeightedSEEDFlux2));


fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

h1 = histogram(logWeightedSEEDFlux1, flux1Edges, 'FaceColor', 'blue', ...
    'Normalization', 'probability');
xlabel('log_{10}(Weighted SEED Flux)')
ylabel('Number of Events')
title('Histogram of log_{10}(Weighted SEED Flux - Energy : 73.1 keV)')
filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName1, '.png');
saveas(fig, filename);


fig = figure('DefaultAxesFontSize', 12);
ax = axes();
fig.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

h2 = histogram(logWeightedSEEDFlux2, flux2Edges, 'FaceColor', 'red', ...
    'Normalization', 'probability');
xlabel('log_{10}(Weighted SEED Flux)')
ylabel('Number of Events')
title('Histogram of log_{10}(Weighted SEED Flux - Energy : 129.2 keV)')



filename = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName2, '.png');
saveas(fig, filename);




end  %End of the function makeJuanHistograms.m
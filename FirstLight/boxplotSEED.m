%This plot was made by Tony Vincent for the SEED GOES paper.
dbstop if error;

clearvars;
close all;
fclose('all');


FSyear = csvread("/SS1/STPSat-6/Data/STPSat-6_FluxVsTime20220115-20221231.csv");


fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 500];
ax = axes();
ax.Position = [0.13, 0.11, 0.775, 0.8150];

flux1Edges = floor(0.5e7 : 0.1e7 : 2.8e7);
flux1FirstQuartileIndex = fix(1*length(flux1Edges)/4.0);
flux1MedianIndex = fix(2.0*length(flux1Edges)/4.0);
flux1ThirdQuartileIndex = fix(3.0*length(flux1Edges)/4.0);


flux2Edges = floor(0.5e6 : 0.2e6 : 6.0e6);
flux2FirstQuartileIndex = fix(1*length(flux2Edges)/4.0);
flux2MedianIndex = fix(2.0*length(flux2Edges)/4.0);
flux2ThirdQuartileIndex = fix(3.0*length(flux2Edges)/4.0);

flux1Index = 12;
flux2Index = 22;

flux1 = FSyear(:, flux1Index);
flux1Quantile = quantile(flux1, [0.25 0.5 0.75]);
flux1FirstQuartileStr = ['First Quartile : ', ...
    num2str(flux1Quantile(1), '%4.1e')];
flux1MedianStr = ['Median : ', num2str(flux1Quantile(2), '%4.1e')];
flux1ThirdQuartileStr = ['Third Quartile : ', ...
    num2str(flux1Quantile(3), '%5.1e')];

flux2 = FSyear(:, flux2Index);
flux2Quantile = quantile(flux2, [0.25 0.5 0.75]);
flux2FirstQuartileStr = ['First Quartile : ', ...
    num2str(flux2Quantile(1), '%4.1e')];
flux2MedianStr = ['Median : ', num2str(flux2Quantile(2), '%4.1e')];
flux2ThirdQuartileStr = ['Third Quartile : ', ...
    num2str(flux2Quantile(3), '%5.1e')];


h1 = histogram(flux1,  flux1Edges, 'FaceColor', 'blue');
hold on
plot([flux1Quantile(1), flux1Quantile(1)], [0, 2.5e4], 'r', ...
    [flux1Quantile(2), flux1Quantile(2)], [0, 2.5e4], 'r', ...
    [flux1Quantile(3), flux1Quantile(3)], [0, 2.5e4], 'r', 'lineWidth', 2)
xlabel('Electron Flux (Counts keV^{-1} s^{-1} cm^{-2}) ster^{-1}')
ylabel('Number of Events')
title('Histogram of Flux for Electrons between 70 and 75 keV')
text('Units', 'Normalized', 'Position', [0.7, 0.88], 'string', ...
    flux1FirstQuartileStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.83], 'string', ...
    flux1MedianStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.78], 'string', ...
    flux1ThirdQuartileStr, 'FontSize', 12);


filename1 = strcat('/SS1/STPSat-6/Plots/FirstLight/LowEnergyHistogram.png');
saveas(fig1, filename1);

hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 500];
ax = axes();
ax.Position = [0.13, 0.11, 0.775, 0.8150];


h2 = histogram(flux2, flux2Edges, 'FaceColor', 'blue');
hold on
 plot([flux2Quantile(1), flux2Quantile(1)], [0, 4.0e4], 'r', ...
     [flux2Quantile(2), flux2Quantile(2)], [0, 4.0e4], 'r', ...
     [flux2Quantile(3), flux2Quantile(3)], [0, 4.0e4], 'r', ...
     'lineWidth', 2)
xlabel('Electron Flux (Counts keV^{-1} s^{-1} cm^{-2}) ster^{-1}')
ylabel('Number of Events')
title('Histogram of Flux for Electrons between 120 and 125 keV')
text('Units', 'Normalized', 'Position', [0.7, 0.88], 'string', ...
    flux2FirstQuartileStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.83], 'string', ...
    flux2MedianStr, 'FontSize', 12);
text('Units', 'Normalized', 'Position', [0.7, 0.78], 'string', ...
    flux2ThirdQuartileStr, 'FontSize', 12);


filename2 = strcat('/SS1/STPSat-6/Plots/FirstLight/HighEnergyHistogram.png');
saveas(fig2, filename2);

lbls = {'< 20','20-25','25-30','30-35','35-40','40-45','45-50','50-55',...
    '55-60','60-65','65-70','70-75','75-80','80-85','85-90','90-95',...
    '95-100','100-105','105-110','110-115','115-120','120-125','125-130',...
    '130-135','135-140','140-145','145-147'};

fig3 = figure('DefaultAxesFontSize', 12);
fig3.Position = [750 25 1200 500];
ax = axes();
ax.Position = [0.13, 0.11, 0.775, 0.8150];

b=boxplot(log10(FSyear), 'Symbol', '', 'widths', 0.7,'Jitter', 0.3,...
    'Labels', lbls);
set(b, 'linew', 1);
ylabel('Log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
xlabel('Electron Energy Range (keV)');
ax = gca; 
ax.FontSize = 14;

filename3 = strcat('/SS1/STPSat-6/Plots/FirstLight/Figure2.png');
saveas(fig3, filename3);




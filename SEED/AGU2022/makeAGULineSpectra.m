function makeAGULineSpectra(info, flux, energyBins, UTCTime, numEnergyBinsToSum)

%Detemine the number of energy bins.
numEnergyBins = length(energyBins(:, 2));

%This function is called by FalconSEEDFlux.m

[m, ~] = size(flux.fluxActual);

startHour = 1;
endHour = 24;
numHours = endHour - startHour + 1;

timeStartIndex = fix(m/24)*startHour;
timeEndIndex = fix(m/24)*endHour;

satellite = "Falcon";
instrument = "SEED";
plotType1 = "EnergySpectra";
plotType2 = "DifferencedEnergySpectra";

dateStr = datestr(datetime(info.startYear, info.startMonth, info.startDayOfMonth));
startDate = [info.startYearStr, info.startMonthStr, info.startDayOfYearStr];
startDayOfYear = info.startDayOfYearStr;

titleStr1 = satellite + " " + instrument + " " + "Energy Spectra" + " " + ...
    dateStr + " " + startDayOfYear;  
titleStr2 = satellite + " " + instrument + " " + "Differenced Energy Spectra" + " " + ...
    dateStr + " " + startDayOfYear;
  
saveName1 = satellite + instrument + plotType1 + startDate + "_" + startDayOfYear;
saveName2 = satellite + instrument + plotType2 + startDate + "_" + startDayOfYear;

outFileName1 = strcat(info.SEEDRootDir, 'Plots/AGU/', saveName1, '.png');
outFileName2 = strcat(info.SEEDRootDir, 'Plots/AGU/', saveName2, '.png');

%Set the figure position information.
% left = 750;
% bottom = 25;
% width = 1200;
% height = 500;

if info.startDayOfYear == 64
    preInjectionHour = 10;
    preInjectionMinute = 30;
    preInjectionSecond = 30;

    postInjectionHour = 11;
    postInjectionMinute = 31;
    postInjectionSecond = 30;

    lineTimes.preInjectionHour = preInjectionHour;
    lineTimes.preInjectionMinute = preInjectionMinute;
    lineTimes.preInjectionSecond = preInjectionSecond;
    lineTimes.postInjectionHour = postInjectionHour;
    lineTimes.postInjectionMinute = postInjectionMinute;
    lineTimes.postInjectionSecond = postInjectionSecond;

   plotAGUEnergySpectra(info, lineTimes, energyBins, flux,  UTCTime, ...
         titleStr1, titleStr2, outFileName1, outFileName2);

end

if info.startDayOfYear == 88

    preInjectionHour = 18;
    preInjectionMinute = 30;
    preInjectionSecond = 0;

    postInjectionHour = 19;
    postInjectionMinute = 30;
    postInjectionSecond = 0;

    lineTimes.preInjectionHour = preInjectionHour;
    lineTimes.preInjectionMinute = preInjectionMinute;
    lineTimes.preInjectionSecond = preInjectionSecond;
    lineTimes.postInjectionHour = postInjectionHour;
    lineTimes.postInjectionMinute = postInjectionMinute;
    lineTimes.postInjectionSecond = postInjectionSecond;

    plotAGUEnergySpectra(info, lineTimes, energyBins, flux,  UTCTime, ...
         titleStr1, titleStr2, outFileName1, outFileName2);

end


if info.startDayOfYear == 112
    preInjectionHour = 17;
    preInjectionMinute = 8;
    preInjectionSecond = 0;

    postInjectionHour = 18;
    postInjectionMinute = 0;
    postInjectionSecond = 0;

    lineTimes.preInjectionHour = preInjectionHour;
    lineTimes.preInjectionMinute = preInjectionMinute;
    lineTimes.preInjectionSecond = preInjectionSecond;
    lineTimes.postInjectionHour = postInjectionHour;
    lineTimes.postInjectionMinute = postInjectionMinute;
    lineTimes.postInjectionSecond = postInjectionSecond;

   plotAGUEnergySpectra(info, lineTimes, energyBins, flux,  UTCTime, ...
         titleStr1, titleStr2, outFileName1, outFileName2);


end


%Find the index for the times we want to plot.

% preInjectionTime1 = preInjectionHour1*3600 + preInjectionMinute1*60 + ...
%     preInjectionSecond1;
% preInjectionTime2 = preInjectionHour2*3600 + preInjectionMinute2*60 + ...
%     preInjectionSecond2;
% preInjectionTime3 = preInjectionHour3*3600 + preInjectionMinute3*60 + ...
%     preInjectionSecond3;
% preInjectionTime4 = preInjectionHour4*3600 + preInjectionMinute4*60 + ...
%     preInjectionSecond4;
% 
% preInjectionIndex1 = find(UTCTime >= preInjectionTime1);
% preInjectionFirstIndex1 = preInjectionIndex1(1);
% 
% preInjectionIndex2 = find(UTCTime >= preInjectionTime2);
% preInjectionFirstIndex2 = preInjectionIndex2(1);
% 
% preInjectionIndex3 = find(UTCTime >= preInjectionTime3);
% preInjectionFirstIndex3 = preInjectionIndex3(1);
% 
% preInjectionIndex4 = find(UTCTime >= preInjectionTime4);
% preInjectionFirstIndex4 = preInjectionIndex4(1);



%Take the log base 10 of the fluxes.
% preInjectionFlux1 = log10(flux.fluxActual(preInjectionFirstIndex1, :) + 1);
% preInjectionLowFlux1 = log10(flux.fluxLow(preInjectionFirstIndex1, :) + 1);
% preInjectionHighFlux1 = log10(flux.fluxHigh(preInjectionFirstIndex1, :) + 1);
% 
% preInjectionFlux2 = log10(flux.fluxActual(preInjectionFirstIndex2, :) + 1);
% preInjectionLowFlux2 = log10(flux.fluxLow(preInjectionFirstIndex2, :) + 1);
% preInjectionHighFlux2 = log10(flux.fluxHigh(preInjectionFirstIndex2, :) + 1);
% 
% preInjectionFlux3 = log10(flux.fluxActual(preInjectionFirstIndex3, :) + 1);
% preInjectionLowFlux3 = log10(flux.fluxLow(preInjectionFirstIndex3, :) + 1);
% preInjectionHighFlux3 = log10(flux.fluxHigh(preInjectionFirstIndex3, :) + 1);
% 
% preInjectionFlux4 = log10(flux.fluxActual(preInjectionFirstIndex4, :) + 1);
% preInjectionLowFlux4 = log10(flux.fluxLow(preInjectionFirstIndex4, :) + 1);
% preInjectionHighFlux4 = log10(flux.fluxHigh(preInjectionFirstIndex4, :) + 1);
% 
% 
% 
% 
% postInjectionTime = postInjectionHour*3600 + postInjectionMinute*60 + ...
%     postInjectionSecond;
% postInjectionIndex = find(UTCTime >= postInjectionTime);
% postInjectionFirstIndex = postInjectionIndex(1);
% 
% %Take the log base 10 of the fluxes.
% postInjectionFlux = log10(flux.fluxActual(postInjectionFirstIndex, :) + 1);
% postInjectionLowFlux = log10(flux.fluxLow(postInjectionFirstIndex, :) + 1);
% postInjectionHighFlux = log10(flux.fluxHigh(postInjectionFirstIndex, :) + 1);
% 
% 
% 
% preInjectionTimeStr1 = ['Prior To Injection - ', num2str(preInjectionHour1, '%02d'), ':', ...
%     num2str(preInjectionMinute1, '%02d'), ':',num2str(preInjectionSecond1, '%04.2f')];
% 
% preInjectionTimeStr2 = [num2str(preInjectionHour2, '%02d'), ':', ...
%     num2str(preInjectionMinute2, '%02d'), ':',num2str(preInjectionSecond2, '%04.2f')];
% 
% preInjectionTimeStr3 = [num2str(preInjectionHour3, '%02d'), ':', ...
%     num2str(preInjectionMinute3, '%02d'), ':',num2str(preInjectionSecond3, '%04.2f')];
% 
% preInjectionTimeStr4 = [num2str(20, '%02d'), ':', ...
%     num2str(0, '%02d'), ':',num2str(0, '%04.2f')];
% 
% postInjectionTimeStr = ['Post Injection - ', num2str(postInjectionHour, '%02d'), ':', ...
%     num2str(postInjectionMinute, '%02d'), ':',num2str(postInjectionSecond, '%04.2f')];
% 

%Set the low and high flux limits.
% yMin = 4;
% yMax = 9;
% 
% %Get a figure handle.
% fig1 = figure();
% ax = gca();
% 
% %Set the gcf position.
% set(gcf, 'Position', [left bottom width height]);
% hold on
% 
% %Plot the fluxes with their associated uncertainty on a semilog y plot.
%  for e = 1 : numEnergyBins 
%      semilogy([energyBins(e, 1), energyBins(e, 3)], [preInjectionFlux1(e), ...
%          preInjectionFlux1(e)], ...
%          [energyBins(e, 2), energyBins(e, 2)], [preInjectionHighFlux1(e), ...
%          preInjectionLowFlux1(e)], 'Color', 'magenta', 'LineWidth', 1.2);
%  end
%  
%  for e = 1 : numEnergyBins 
%      semilogy([energyBins(e, 1), energyBins(e, 3)], [preInjectionFlux2(e), ...
%          preInjectionFlux2(e)], ...
%          [energyBins(e, 2), energyBins(e, 2)], [preInjectionHighFlux2(e), ...
%          preInjectionLowFlux2(e)], 'Color', 'red', 'LineWidth', 1.2);
%  end
% 
%  for e = 1 : numEnergyBins 
%      semilogy([energyBins(e, 1), energyBins(e, 3)], [preInjectionFlux3(e), ...
%          preInjectionFlux3(e)], ...
%          [energyBins(e, 2), energyBins(e, 2)], [preInjectionHighFlux3(e), ...
%          preInjectionLowFlux3(e)], 'Color', 'green', 'LineWidth', 1.2);
%  end
% 
%  for e = 1 : numEnergyBins 
%      semilogy([energyBins(e, 1), energyBins(e, 3)], [preInjectionFlux4(e), ...
%          preInjectionFlux4(e)], ...
%          [energyBins(e, 2), energyBins(e, 2)], [preInjectionHighFlux4(e), ...
%          preInjectionLowFlux4(e)], 'Color', 'blue', 'LineWidth', 1.2);
%  end
% 
%  for e = 1 : numEnergyBins 
%      semilogy([energyBins(e, 1), energyBins(e, 3)], [postInjectionFlux(e), ...
%          postInjectionFlux(e)], ...
%          [energyBins(e, 2), energyBins(e, 2)], [postInjectionHighFlux(e), ...
%          postInjectionLowFlux(e)], 'Color', 'black', 'LineWidth', 1.2);
%  end
% 
% xlabel('Energy (keV)');
% title(titleStr);
% ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
% text('Units', 'Normalized', 'Position', [0.6, 0.9], 'string', preInjectionTimeStr1, ...
%       'FontSize', 15, 'Color', 'magenta');
% text('Units', 'Normalized', 'Position', [0.6, 0.84], 'string', preInjectionTimeStr2, ...
%       'FontSize', 15, 'Color', 'red');
% text('Units', 'Normalized', 'Position', [0.6, 0.78], 'string', preInjectionTimeStr3, ...
%       'FontSize', 15, 'Color', 'green');
% text('Units', 'Normalized', 'Position', [0.6, 0.72], 'string', preInjectionTimeStr4, ...
%       'FontSize', 15, 'Color', 'blue');
% text('Units', 'Normalized', 'Position', [0.6, 0.66], 'string', postInjectionTimeStr, ...
%       'FontSize', 15, 'Color', 'black');
% ylim(ax, [yMin yMax])
% yticks([4 5 6 7 8])
% yticklabels({'4', '5', '6', '7', '8'})
% xlim([10 150])
% xticks(linspace(10, 150, 15))
% xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
%     '100', '110', '120', '130', '140', '150'})
% 
% %Save the spectra to a file.
% saveas(fig1, outFileName);

end  %End of the function makeAGULineSpectra.m


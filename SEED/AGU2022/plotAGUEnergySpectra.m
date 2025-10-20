function    plotAGUEnergySpectra(info, lineTimes, energyBins, flux,  UTCTime, ...
         titleStr1, titleStr2, outFileName1, outFileName2);

%Set the figure position information.
left = 750;
bottom = 25;
width = 1200;
height = 500;


%Set the low and high flux limits.
yMin = 4;
yMax = 9;

numEnergyBins = length(energyBins(:, 2));


%Find the time for setting the line prior to the injection.
preInjectionTime = lineTimes.preInjectionHour*3600 + ...
                   lineTimes.preInjectionMinute*60 + ...
                   lineTimes.preInjectionSecond;

preInjectionIndex = find(UTCTime >= preInjectionTime);
preInjectionFirstIndex = preInjectionIndex(1);

%Take the log base 10 of the pre-injection fluxes.
preInjectionFlux = log10(flux.fluxActual(preInjectionFirstIndex, :) + 1);
preInjectionLowFlux = log10(flux.fluxLow(preInjectionFirstIndex, :) + 1);
preInjectionHighFlux = log10(flux.fluxHigh(preInjectionFirstIndex, :) + 1);

%Find the time for setting the line past the injection.
postInjectionTime = lineTimes.postInjectionHour*3600 + ...
                    lineTimes.postInjectionMinute*60 + ...
                    lineTimes.postInjectionSecond;

postInjectionIndex = find(UTCTime >= postInjectionTime);
postInjectionFirstIndex = postInjectionIndex(1);

%Take the log base 10 of the post-injection fluxes.
postInjectionFlux = log10(flux.fluxActual(postInjectionFirstIndex, :) + 1);
postInjectionLowFlux = log10(flux.fluxLow(postInjectionFirstIndex, :) + 1);
postInjectionHighFlux = log10(flux.fluxHigh(postInjectionFirstIndex, :) + 1);

%Find the difference spectra between the pre and post injection flux.
%First convert to counts.
postInjectionCounts = info.deltaT*info.deltaG*energyBins(1,4)*flux.fluxActual(postInjectionFirstIndex, :);
preInjectionCounts = info.deltaT*info.deltaG*energyBins(1,4)*flux.fluxActual(preInjectionFirstIndex, :);

%Now find the difference counts.
differenceCounts = postInjectionCounts - preInjectionCounts;

%Check for negative differences.
negDiffCountsIndex = find(differenceCounts < 0);
if length(negDiffCountsIndex) ~= 0
    differenceCounts(negDiffCountsIndex) = 0;
end

%Determine the energy bin width.
deltaE = info.numEnergyBinsToSum*energyBins(1, 4);  %Units are in keV.

%Now convert to flux.
differenceFlux = differenceCounts/(deltaE*info.deltaT*info.g);

%The quantity of (delta t)/t is a constant so we will calculate it here.
%We are interested in the square of this quantity so I will actually
%calculate just that value.
deltaTOverTSq = (info.deltaT/info.timeBinWidth)^2;

%The quantity of (delta g)/g is a constant so we will calculate it here.
%We are interested in the square of this quantity so I will actually
%calculate just that value.
deltaGOverGSq = (info.deltaG/info.g)^2;

%Set up the high and low difference flux vectors.
differenceFluxLow = zeros(1, numEnergyBins);
differenceFluxHigh = zeros(1, numEnergyBins);

%Loop through the energies to calculate the high and low difference fluxes
%as well as the errors.
for e = 1 : numEnergyBins

    %Calculate the energy uncertainty squared.
    deltaEOverESq = (deltaE/energyBins(e, 2))^2; 

    %Calculate the flux uncertainty.
    sigmaF = differenceFlux(e)/4.0*sqrt(deltaGOverGSq + deltaTOverTSq + ...
        deltaEOverESq + 4.0/differenceCounts(e));

    %Now estimate the uncertainties.
    differenceFluxLow(e) = differenceFlux(e) - sigmaF;
    differenceFluxHigh(e) = differenceFlux(e) + sigmaF;

end  %End of for loop - for e = 1 : numEnergyBins


%Check for negative differences.
negDiffFluxIndex = find(differenceFluxLow < 0);
if length(negDiffFluxIndex) ~= 0
    differenceFluxLow(negDiffFluxIndex) = 0;
end


differenceFluxHigh = log10(differenceFluxHigh + 1);
differenceFlux = log10(differenceFlux + 1);
differenceFluxLow = log10(differenceFluxLow + 1);


%Set the pre and post injection strings.
preInjectionTimeStr = ['Prior To Injection - ', num2str(lineTimes.preInjectionHour, '%02d'), ':', ...
    num2str(lineTimes.preInjectionMinute, '%02d'), ':',num2str(lineTimes.preInjectionSecond, '%04.2f')];

postInjectionTimeStr = ['Post Injection - ', num2str(lineTimes.postInjectionHour, '%02d'), ':', ...
    num2str(lineTimes.postInjectionMinute, '%02d'), ':',num2str(lineTimes.postInjectionSecond, '%04.2f')];

differenceTimeStr = ['Post-Injection - Pre-Injection'];


%Get a figure handle.
fig1 = figure();
ax = gca();

%Set the gcf position.
set(gcf, 'Position', [left bottom width height]);
hold on

%Plot the fluxes with their associated uncertainty on a semilog y plot.
 for e = 1 : numEnergyBins 
     semilogy([energyBins(e, 1), energyBins(e, 3)], [preInjectionFlux(e), ...
         preInjectionFlux(e)], ...
         [energyBins(e, 2), energyBins(e, 2)], [preInjectionHighFlux(e), ...
         preInjectionLowFlux(e)], 'Color', 'magenta', 'LineWidth', 1.2);
 end
 
 for e = 1 : numEnergyBins 
     semilogy([energyBins(e, 1), energyBins(e, 3)], [postInjectionFlux(e), ...
         postInjectionFlux(e)], ...
         [energyBins(e, 2), energyBins(e, 2)], [postInjectionHighFlux(e), ...
         postInjectionLowFlux(e)], 'Color', 'black', 'LineWidth', 1.2);
 end

 for e = 1 : numEnergyBins 
     semilogy([energyBins(e, 1), energyBins(e, 3)], [postInjectionFlux(e), ...
         postInjectionFlux(e)], ...
         [energyBins(e, 2), energyBins(e, 2)], [postInjectionHighFlux(e), ...
         postInjectionLowFlux(e)], 'Color', 'black', 'LineWidth', 1.2);
 end

xlabel('Energy (keV)');
title(titleStr1);
ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
text('Units', 'Normalized', 'Position', [0.6, 0.9], 'string', preInjectionTimeStr, ...
      'FontSize', 15, 'Color', 'magenta');
text('Units', 'Normalized', 'Position', [0.6, 0.8], 'string', postInjectionTimeStr, ...
      'FontSize', 15, 'Color', 'black');
ylim(ax, [yMin yMax])
yticks([4 5 6 7 8])
yticklabels({'4', '5', '6', '7', '8'})
xlim([10 150])
xticks(linspace(10, 150, 15))
xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
    '100', '110', '120', '130', '140', '150'})

%Save the spectra to a file.
saveas(fig1, outFileName1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Get a figure handle.
fig2 = figure();
ax2 = gca();

%Set the gcf position.
set(gcf, 'Position', [left bottom width height]);
hold on

%Plot the fluxes with their associated uncertainty on a semilog y plot.
 for e = 1 : numEnergyBins 
     semilogy([energyBins(e, 1), energyBins(e, 3)], [differenceFlux(e), ...
         differenceFlux(e)], ...
         [energyBins(e, 2), energyBins(e, 2)], [differenceFluxHigh(e), ...
         differenceFluxLow(e)], 'Color', 'black', 'LineWidth', 1.2);
 end

xlabel('Energy (keV)');
title(titleStr2);
ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
text('Units', 'Normalized', 'Position', [0.6, 0.9], 'string', differenceTimeStr, ...
      'FontSize', 15, 'Color', 'black');
%ylim(ax2, [1 3.5])
%yticks([1 2 3])
%yticklabels({'1', '2', '3'})
xlim([10 150])
xticks(linspace(10, 150, 15))
xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
    '100', '110', '120', '130', '140', '150'})

%Save the spectra to a file.
saveas(fig2, outFileName2);


end  %End of function plotAGUEnergySpectra.m
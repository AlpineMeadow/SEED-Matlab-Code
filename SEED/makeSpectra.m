function makeSpectra(info, flux, energyBins, dataAttributes, ...
    numEnergyBinsToSum, time)

%This function is called by FalconSEEDFlux.m

newFlux = flux.fluxActual;


%Set up an index that corresponds to the times in which the data were
%taken.  We use round here but it may be possible to use floor as well.
intTimeIndex = round(specTime);
if(intTimeIndex(1) == 0)
	intTimeIndex(1) = 1;
end

%Loop through all of the available data and put the data into the giant
%specCountsData and specFluxData array.

%First set up a counter.
dataCounter = 1;

for i = 1 : length(intTimeIndex)
	specCountsData(intTimeIndex(i), :) = specCounts(dataCounter, :);
	specFluxData(intTimeIndex(i), :) = specFlux(dataCounter, :);
	dataCounter = dataCounter + 1;
end




[numInstances, numEnergyBins] = size(newFlux);


a = "Falcon";
b = "SEED";
c = "Spectrogram";
d = [info.yearStr, info.monthStr, info.dayOfMonthStr];
e = dataAttributes.julianday;
f = [num2str(numInstances), '/', num2str(5760)];

titStr = a + " " + b + " " + c + " " + d + " " + e + " " + f;

    
%Generate the file name of the plot to be saved.
saveName = a + b + c + d + "_" + e + "_" + num2str(numEnergyBinsToSum);
fig1FileName = strcat(info.plotSEEDDir, 'Spectrogram/', saveName, '.png');


fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];


data = log10(newFlux)';

imagesc([0 24],[10 150],data)
%caxis([0 3])
caxis('auto')
ylabel('Energy (keV)');
title(titStr);
cb = colorbar;
ylabel(cb,'Log10(Flux)') 
set(gca,'YDir','normal')
ax.YTick = [20 40 60 80 100 120 140];
ax.YLim = [10, 150];
ax.XTick = [1 3 5 7 9 11 13 15 17 19 21 23]; 
ax.XLim = [0, 24]; 

% Set axis limits for all other axes
%additionalAxisLimits = [...
%    0, 23];       % axis 2


additionalAxisTicks = {[19 21 23 1 3 5 7 9 11 13 15 17]};

% Set up multi-line ticks
allTicks = [ax.XTick; cell2mat(additionalAxisTicks')];
tickLabels = compose('%4d\\newline%4d', allTicks(:).'); 
% The %4d adds space to the left so the labels are centered.
% You'll need to add "%.1f\\newline" for each row of labels (change formatting as needed). 
% Alternatively, you can use the flexible line below that works with any number
% of rows but uses the same formatting for all rows. 
%    tickLabels = compose(repmat('%.2f\\newline',1,size(allTicks,1)), allTicks(:).'); 

% Decrease axis height & width to make room for labels
ax.Position(3:4) = ax.Position(3:4) * .75; % Reduced to 75%
ax.Position(2) = ax.Position(2) + .2;  % move up

% Add x tick labels
set(ax, 'XTickLabel', tickLabels, 'TickDir', 'out', 'XTickLabelRotation', 0)

% Define each row of labels
ax2 = axes('Position',[sum(ax.Position([1,3]))*1.08, ax.Position(2), .02, 0.001]);
linkprop([ax,ax2],{'TickDir','FontSize'});

axisLabels = {'Time (UTC)', 'LT'}; % one for each x-axis
set(ax2,'XTick',0.5,'XLim',[0,1],'XTickLabelRotation',0, 'XTickLabel', strjoin(axisLabels,'\\newline'))
ax2.TickLength(1) = 0.2; % adjust as needed to align ticks between the two axes

%Save the spectra to a file.
saveas(fig1, fig1FileName);

end
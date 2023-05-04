function makeLosAlamosSpectra(info, energyBins, specTime, specCounts, specFlux)


%This function is called by LosAlamosCheckNetcdf.m

%Get the size of the day's data.
[numInstances, numEnergyBins] = size(specFlux);

%Set up some plotting and output file name values.
a = "Falcon";
b = "SEED";
c = "Spectrogram";
d = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
e = info.startDayOfYearStr;
f = [num2str(numInstances), '/', num2str(5760)];

titStr = a + " " + b + " " + c + " " + d + " " + e;
saveName = a + b + c + d + "_" + e;

%Generate the output file name.
fig1FileName = strcat(info.LosAlamosOutputDataDir, 'Spectrogram', saveName, '.png');

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

%We want to be careful about the plotting times.  So we set up a giant
%array of NaN's for all possible time instances(86400) by all possible energy
%channels(1024).  We inject the available spectra into that giant array.
specCountsData = NaN(86400, numEnergyBins);
specFluxData = NaN(86400, numEnergyBins);

%Set up an index that corresponds to the times in which the data were
%taken.  We use round here but it may be possible to use floor as well.
intTimeIndex = round(specTime);

%Loop through all of the available data and put the data into the giant
%specCountsData and specFluxData array.

%First set up a counter.
dataCounter = 1;

for i = 1 : length(intTimeIndex)
	specCountsData(i, :) = specCounts(dataCounter, :);
	specFluxData(i, :) = specFlux(dataCounter, :);
	dataCounter = dataCounter + 1;
end

%Take the base 10 log of the data.
%data = log10(specFluxData)';
data = log10(specFlux)';

%Generate the image.
imagesc([0 24],[10 150],data)
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



end  %End of the function makeLosAlamosSpectr.m
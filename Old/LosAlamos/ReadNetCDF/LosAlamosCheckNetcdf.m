%This script will test the output of the LosAlamosGetSEEDDosimeterData.m
%script.  This is mostly for Geoff to play around with.


%Clear all the variables.
clearvars;

%Close any open files.
fclose('all');

%Close any open plot windows.
close all;

%Set the day of year as well as the year itself.
dayOfYear = 88;
startYear = 2022;

%Set the directory path for where the data is located.  Change to what ever
%is appropriate for your system.
inputDataDir = '/SS1/STPSat-6/LosAlamos/';
outputDir = '/SS1/STPSat-6/LosAlamos/';

%Generate a structure that holds all of the information needed to do the
%analysis.
info = genLosAlamosInfo(dayOfYear, startYear, inputDataDir, ...
	outputDir);

%Get the data.  The outputs are the dosimeter time, dosimeter counts and
%the dosimeter dose as well as the spectrometer time, spectrometer counts, 
%spectrometer flux and spectrometer energy bins.  The dosimeter time 
%and the spectrometer time are not the same!(I think).  The SEED data has not been
%cleaned of repetitious spectra nor has any other manipulation been done to
%it.  Therefore, the spectrogram might be messy and it is certainly
%non-physical.  Likewise the dosimeter data has not been differenced or had
%any other manipulation done to it. As it is the dosimeter data is
%non-physical. By non-physical, I mean that the units are not correct.
[DosimeterTime, DosimeterCounts, DosimeterDose, SpecTime, SpecCounts, ...
	SpecFlux, SpecEnergyBins] = LosAlamosGetNetcdfData(info);

%Generate the energy bins.  The values are in keV.  The delta E, number of 
%energy bins and offset are determined from the paper.
deltaEnergy = 0.1465;  %In units of keV.
energyBinOffset = -3.837;  %In units of keV.
numEnergyBins = 1024;

%Allocate memory for the new energy bins and the new counts array.
energyBins = [1:numEnergyBins]*deltaEnergy + energyBinOffset;

%Now make plots.
%Make summary spectrogram plot.
makeLosAlamosSpectra(info, energyBins, SpecTime, SpecCounts, SpecFlux);

%Make the summary dosimeter plot.
plotLosAlamosDosimeter(info, DosimeterTime, DosimeterCounts, DosimeterDose)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function info = genLosAlamosInfo(dayOfYear, startYear, inputDataDir, ...
	outputDataDir)

%This function will fill the information structure.
%This function is called by LosAlamosNetCDFFiles.m

%Let's make some conversion factors.  These values convert the counts into
%Rads.  These are determined from the data itself.
Channel1CountsToRads = 1.0/2.47919e6;

info.channel1CountsToRads = Channel1CountsToRads;

%Handle the directories.
info.LosAlamosInputDataDir = inputDataDir;
info.LosAlamosOutputDataDir = outputDataDir;

%Take care of the year and day of year
info.startYear = startYear;
info.startYearStr = num2str(startYear);
info.startDayOfYear = dayOfYear;
info.startDayOfYearStr = num2str(dayOfYear, '%03d');

%Determine the month and day of month for each day of year.    
startDateVector = datevec(datenum(startYear, 0, dayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

info.startMonth = startMonth;
info.startMonthStr = num2str(startMonth, '%02d');
info.startDayOfMonth = startDayOfMonth;
info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');

end  %End of the function generateDosimeterInformation.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DosimeterTime, DosimeterCounts, DosimeterDose, SpecTime, SpecCounts, ...
	SpecFlux, SpecEnergyBins] = LosAlamosGetNetcdfData(info)

    %This function will return the netcdf data from the SEED mission.
    %the data.  The input is the info structure.  Neither the attributes or
	%the dimensions are output from this function although the data is
	%available.  

	%Generate the file name to be opened.
	fname = ['LosAlamos_STPSat-6_FalconSEED_', info.startYearStr, info.startMonthStr, ...
		info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];
	fileName = [info.LosAlamosInputDataDir, fname];


    %First open the file for reading.
    fileID = netcdf.open(fileName,'NOWRITE');


    % Read the number of dimensions, variables, and attributes to make sure
    % it's not an empty file.
    [ndims, nvars, natts, ~] = netcdf.inq(fileID);

    %Check to see if the file is intact.
    if (ndims == 0) || (natts == 0) || (nvars == 0)
        error('ERROR: L1 file has insufficient fields to proceed.');
    end  %End of if statement.

    % Read in the L1 file attributes 
    for j = 0 : natts - 1
        attname = ['att',num2str(j)];
        attributeName.(attname) = netcdf.inqAttName(fileID,netcdf.getConstant('NC_GLOBAL'), j);
        attributeValue.(attname) = netcdf.getAtt(fileID,netcdf.getConstant('NC_GLOBAL'),attributeName.(attname));
        Attributes.(attributeName.(attname)) = attributeValue.(attname); 
    end  %End of for loop - for j = 0 : natts - 1

    % Read in the L1 file dimensions 
    for j = 0 : ndims - 1
        dimname = ['dim',num2str(j)];
        [Dimensions.(dimname), netcdfDimLength.(dimname)] = netcdf.inqDim(fileID, j);
    end  %End of for loop - for j = 0 : ndims - 1

    % Read in the L1 file variables 
    for j = 0 : nvars - 1
        varname = ['var',num2str(j)];
        variableName.(varname) = netcdf.inqVar(fileID, j);
        varValue.(varname) = netcdf.getVar(fileID, j);
        data.(variableName.(varname)) = varValue.(varname);
    end  %End of for loop - for j = 0 : nvars - 1

	%Now return the data.
	DosimeterTime = data.Dosimeter_Time;
	DosimeterCounts = data.Dosimeter_Counts;
	DosimeterDose = data.Dosimeter_Dose;

	SpecTime = data.Spectrometer_Time;
	SpecCounts = data.Spectrometer_Counts;
	SpecFlux = data.Spectrometer_Flux;
	SpecEnergyBins = data.Spectrometer_Energy_Bin_Center_Energy;

end  %End of function LosAlamosGetNetcdfData.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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



end  %End of the function makeLosAlamosSpectra.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function plotLosAlamosDosimeter(info, dosimeterTime, dosimeterCounts, ...
	dosimeterDose)


    %Make a vector holding the cumulative counts.
	cumulativeCounts = zeros(1, length(dosimeterTime));

	%Generate a cumulative count vector.
	for i = 1 : length(dosimeterTime)
		cumulativeCounts(i) = sum(dosimeterCounts(1 : i));
	end

	%Make a plot of the noise in the signal.
	fig1 = figure('DefaultAxesFontSize', 12);
	fig1.Position = [750 25 1200 700];

	%Make some plotting strings.
	titStr1 = ['Channel 1 Dose Versus Time For Day of Year : ', info.startDayOfYearStr, ' - ', ...
		datestr([info.startYear, info.startMonth, info.startDayOfMonth, 0, 0, 0])];
	titStr2 = ['Channel 1 Cumulative Dose Versus Time For Day of Year : ', info.startDayOfYearStr, ' - ', ...
		datestr([info.startYear, info.startMonth, info.startDayOfMonth, 0, 0, 0])];

	%Make a plot name string.
	satellite = 'Falcon';
	instrument = 'Dosimeter';
	conFactor = 'TimeSeries';
	saveName = strcat(satellite, instrument, conFactor, info.startYearStr, ...
		'_', info.startDayOfYearStr);

	fig1FileName = strcat(info.LosAlamosOutputDataDir, saveName, '.png');

	left = 0.1;
	width = 0.8;
	height = 0.3;
	bottom = [0.54, 0.12];

	xbins = 1:length(dosimeterTime)/25:length(dosimeterTime);

	xtickValues = xbins;
	xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
      ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};


	sp1 = subplot(2, 1, 1);
	plot(dosimeterTime, dosimeterDose, 'b')
	title(titStr1)
	text('Units', 'Normalized', 'Position', [0.82, 0.9], 'string', ...
		'Channel 1', 'FontSize', 11);
	ylabel('Dose (Rad)')
	xlabel('Time (Hours - UTC)')
	set(sp1, 'Position', [left, bottom(1), width, height]);
	sp1.XTick = xtickValues;
	sp1.XTickLabel = xtickLabels;
	xlim([1 xtickValues(end)])


	sp2 = subplot(2, 1, 2);
	plot(dosimeterTime, info.channel1CountsToRads*cumulativeCounts, 'b')
    text('Units', 'Normalized', 'Position', [0.82, 0.9], 'string', ...
		'Channel 1', 'FontSize', 11);
	title(titStr2)
	ylabel('Dose (Arbitrary Units)')
	xlabel('Time (Hours - UTC)')
	set(sp2, 'Position', [left, bottom(2), width, height]);
	sp2.XTick = xtickValues;
	sp2.XTickLabel = xtickLabels;
	xlim([1 xtickValues(end)])

	%Save the histogram to a file.
	saveas(fig1, fig1FileName);


end  %End of the function plotLosAlamosDosimeter.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












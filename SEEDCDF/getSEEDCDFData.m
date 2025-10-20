%This script will read a NASA CDF file of the SEED data.  The only
%necessary input will be day of year.  The data variables will be returned
%in a structure with the following fields :

% Epoch: [n×1 double]  - A vector of n times given in Matlab's datenum
% variable of type double.

% SEED_Time_Dt15: [m×1 double] - A vector of m times given in Matlab's
% datenum variable of type double.

%The values of n and m are not the same.  The value of n corresponds to the
%unique data values for a given day.  The value of m corresponds to those
%unique value(n) that are found to have a delta time of 15 seconds.  In
%general, m will be smaller than n.  It is remotely possible that m and n
%can be equal. 

% SEED_Electron_Counts: [n×e uint32] - An array of electron counts of
% length n time values by e energy channels of type 32 bit unsigned int.

% SEED_Electron_Counts_Dt15: [m×e uint32] - An array of electron counts
% of length m time values by e energy channels of type 32 bit unsigned int.

% SEED_Electron_Flux: [n×e single] - An array of electron flux of length
% n time values  by e energy channels of type 32 bit float.

% SEED_Electron_Flux_Dt15: [m×e single] - An array of electron flux of
% length m time values by e energy channels of type 32 bit float.

% SEED_Energy_Channels: [ex1] - An array of energy channels.  This will be
% 904 channels ranging from 13.8 keV to 146 keV.

% SEED_Geometric_Factor: [ex1] - An array of geometric factor values.  It
% is of length 904(one for each energy) ranging from 6e-7 to 5e-5.

% SEED_Dosimeter_Time: [t×1 double] - A vector of t times given in Matlab's
% datenum variable of type double.

%The value of t is not the same as either n or m.  The times for the
%dosimeter are close to the total number of seconds in a day(86400).

% SEED_Dosimeter_Counts: [t×3 uint32] - An array of counts of length t values
% for three dosimeter channels.  The counts are of type 32 bit unsigned int.

% SEED_Dosimeter_Dose: [t×3 single] - An array of dosimeter dose of length
% t values for three dosimeter channels.  The dose values are of type
% 32-bit float.   

% SEED_Dosimeter_Counts_To_Dose: [3x1]  - An array of 3 values used to
% convert the dosimeter counts to dosimeter dose.  These values are of type
% 32-bit float.

% SEED_Dosimeter_Channels: [3x1] - An array that contains a listing of the
% number of dosimeter channels.  

% SEED_Dosimeter_Counts_LABEL: [3×31 char] - A string containing the
% dosimeter counts label. Not sure this has a use.

% SEED_Dosimeter_Dose_Label: [3×29 char] - A string containing the
% dosimeter dose label.  Not sure this has a use.

% SEED_Temperature : [t uint8] - A vector of temperatures(degrees Celsius)
% from the instrument.

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
dayOfYear = 61;
year = 2023;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateCDFInfomation(dayOfYear, year, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond);

%Read a cdf file.  The times that are read in are converted to Matlab's
%datenum time automatically.
[CDFInfo, CDFData] = importSEEDCDF(info);

%Make plots of the data.
SEEDCDFPlotSEEDData(info, CDFInfo, CDFData)
%SEEDCDFPlotDoseTempData(info, CDFInfo, CDFData)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% generateCDFInformation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function info = generateCDFInfomation(dayOfYear, year, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond);

%This function will be used to generate the information structure for both
%SEED and the Dosimeter and will be used for getSEEDCDFData.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info.startHour = startHour;
info.startHourStr = num2str(startHour, '%02d');
info.startMinute = startMinute;
info.startMinuteStr = num2str(startMinute, '%02d');
info.startSecond = startSecond;
info.startSecondStr = num2str(startSecond, '%02d');
info.endHour = endHour;
info.endHourStr = num2str(endHour, '%02d');
info.endMinute = endMinute;
info.endMinuteStr = num2str(endMinute, '%02d');
info.endSecond = endSecond;
info.endSecondStr = num2str(endSecond, '%02d');

%Take care of the year and day of year
info.startYear = year;
info.startYearStr = num2str(year);
info.startDayOfYear = dayOfYear;
info.startDayOfYearStr = num2str(dayOfYear, '%03d');

%Determine the month and day of month for each day of year.    
startDateVector = datevec(datenum(year, 0, dayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

info.startMonth = startMonth;
info.startMonthStr = num2str(startMonth, '%02d');
info.startDayOfMonth = startDayOfMonth;
info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');

%Lets write a month string.  Matlab has a way to do this
startMonthName = datestr(datetime(1, startMonth, 1), 'mmmm');
info.startMonthName = startMonthName;

%Generate a date string.
info.startDateStr = [info.startYearStr, info.startMonthStr, ...
    info.startDayOfMonthStr];

%Add in the epoch time data.
epochYear = 1980;
epochMonth = 1;
epochDayOfMonth = 6;
epochHour = 0;
epochMinute = 0;
epochSecond = 0.0;

info.epochYear = epochYear;
info.epochMonth = epochMonth;
info.epochDayOfMonth = epochDayOfMonth;
info.epochHour = epochHour;
info.epochMinute = epochMinute;
info.epochSecond = epochSecond;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%  Directory Information  %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info.dosimeterRootDir = '/SS1/STPSat-6/Dosimeter/';
info.dosimeterPlotDir = '/SS1/STPSat-6/Plots/Dosimeter/';
info.temperatureRootDir = '/SS1/STPSat-6/Temperature/';
info.temperaturePlotDir = '/SS1/STPSat-6/Plots/Temperature/';
info.SEEDRootDir = '/SS1/STPSat-6/SEED/';
info.SEEDPlotDir = '/SS1/STPSat-6/Plots/SEED/';
info.STPSat6RootDir = '/SS1/STPSat-6/';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% importSEEDCDF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CDFInfo, CDFData] = importSEEDCDF(info)

%This function is called by SEEDCDF.m  It will read in a CDF file and
%output the results.

%Generate the CDF filename to be opened.
CDFFileName = ['STPSat-6_Falcon_SEED-L1_', info.startYearStr, ...
    info.startMonthStr, info.startDayOfMonthStr, '_v01.cdf'];

fullFilenameCDF = ['/SS1/STPSat-6/SEED/', info.startYearStr, ...
    '/L1/DayOfYear_', info.startDayOfYearStr, '/', CDFFileName];

%Get the CDF data.
[data, CDFInfo] = spdfcdfread(fullFilenameCDF);

%Get the data into the appropriate variables.
numVariables = length(data);

for i = 1 : numVariables
    CDFData.(CDFInfo.Variables{i,1}) = data{i};
end

end  %End of the function importSEEDCDF.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% SEEDCDFPlotSEEDData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SEEDCDFPlotSEEDData(info, CDFInfo, CDFData)

%Now plot a spectrogram of the data.

fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'on');

ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];


yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [CDFData.SEED_Energy_Channels(1), ...
    CDFData.SEED_Energy_Channels(end)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Just check to see if that data makes sense.
dateFormat = 'HH';
time = CDFData.Epoch;
energyBins = CDFData.SEED_Energy_Channels;
data = double(CDFData.SEED_Electron_Flux_Total);
numEnergyBins = length(energyBins);


satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + "_Summary" + "_" + ...
    info.startDateStr + "_" + info.startDayOfYearStr;

SEEDFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

%Let us now interpolate and smooth the data.
%First make an interpolation vector. We will interpolate onto a time grid
%with a delta t of 15 seconds.
ttDatetime = datetime(time,'ConvertFrom','datenum');

%Convert from the datetime structure into seconds from start of the day.
timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
    ttDatetime.Second;

%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;

%Set up an interpolated flux array of size [5760,904]
interpFlux = zeros(length(tt), numEnergyBins);

%Now we loop through the energy channels.
for e = 1 : numEnergyBins
    y = data(:, e);
    interpFlux(:, e) = smoothdata(interp1(timeSeconds, y, tt, 'linear'), ...
        'gaussian', 100);
end


%The array interpFlux can potentially have negative values most likely due
%to the interpolation/smoothing.  Lets get rid of them.
interpFlux(interpFlux < 0) = 0.001;


imagesc(time, energyBins, log10(interpFlux)')
caxis('auto')
datetick('x', dateFormat)
ylabel('Energy (keV)');
title(titStr);
caxis([3 8])
cb = colorbar;
ylabel(cb,'Log10(Flux)') 
set(gca,'YDir','normal')
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;

%Create a flag to determine if we will plot the local time on the x-axis.
ltAxis = 1;

%Set up the x-axis tick labels and limits.
xTickLabels = {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...
	16, 17, 18, 19, 20, 21, 22, 23, 0]};

xLimValues = [time(1), time(end)];

if ltAxis == 1
	additionalAxisTicks = {[18 19 20 21 22 23 0 1 2 3 4 5 6 7 8 9 10 ...
        11 12 13 14 15 16 17 18]};

	% Set up multi-line ticks
	allTicks = [cell2mat(xTickLabels'); cell2mat(additionalAxisTicks')];
	
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

	axisLabels = {'Hours(UTC)', 'Hours(LT)'}; % one for each x-axis
	set(ax2,'XTick',0.5,'XLim',[0,1],'XTickLabelRotation',0, 'XTickLabel', strjoin(axisLabels,'\\newline'))
	ax2.TickLength(1) = 0.2; % adjust as needed to align ticks between the two axes
end  %End of if statement - if ltAxis == 1


%Save the time series to a file.
saveas(fig1, SEEDFileName);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% SEEDCDFPlotDoseTempData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SEEDCDFPlotDoseTempData(info, CDFInfo, CDFData)

fig2 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
ax = axes();
fig2.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];

left = 0.1;
width = 0.8;
height = 0.19;
bottom = [0.74, 0.5, 0.3, 0.1];

%Just check to see if that data makes sense.
dateFormat = 'HH';
time = CDFData.Epoch;
energyBins = CDFData.SEED_Energy_Channels;
data = double(CDFData.SEED_Electron_Flux_Total);
numEnergyBins = length(energyBins);


satellite = "Falcon";
instrument = "SEED";
plotType = "Dosimeter Temperature";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;

titleStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + "_Summary_" + "DosimeterTemperature" + "_" + ...
    info.startDateStr + "_" + info.startDayOfYearStr;

DosimeterFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');

%Make the plots.
sp1 = subplot(4, 1, 1); 
plot(CDFData.SEED_Dosimeter_Time(2:end), CDFData.SEED_Dosimeter_Dose(2:end, 1), 'b')
title(titleStr);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 1)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 1))])
xlim([CDFData.SEED_Dosimeter_Time(2) CDFData.SEED_Dosimeter_Time(end)]);
set(gca, 'Xticklabel', []);
set(sp1, 'Position', [left, bottom(1), width, height]);

sp2 = subplot(4, 1, 2);
plot(CDFData.SEED_Dosimeter_Time(2:end), CDFData.SEED_Dosimeter_Dose(2:end, 2), 'g')
ylabel('Dose (Rads)','FontSize', 16);
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 2)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 2))])
xlim([CDFData.SEED_Dosimeter_Time(2) CDFData.SEED_Dosimeter_Time(end)]);
set(gca, 'Xticklabel', []);
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(4, 1, 3);
plot(CDFData.SEED_Dosimeter_Time(2:end), CDFData.SEED_Dosimeter_Dose(2:end, 3), 'r')
datetick('x', 'HH:MM')
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 3', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Dosimeter_Dose(2:end, 3)), ...
    max(CDFData.SEED_Dosimeter_Dose(2:end, 3))])
set(gca, 'Xticklabel', []);
set(sp3, 'Position', [left, bottom(3), width, height]);
xlim([CDFData.SEED_Dosimeter_Time(1) CDFData.SEED_Dosimeter_Time(end)]);

sp4 = subplot(4, 1, 4);
plot(CDFData.SEED_Dosimeter_Time, CDFData.SEED_Temperature, 'black')
datetick('x', 'HH:MM')
ylabel('Temperature ^{\circ}C');
text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Temperature', ...
      'FontSize', 15);
ylim([min(CDFData.SEED_Temperature), 100])
set(sp4, 'Position', [left, bottom(4), width, height]);
xlim([CDFData.SEED_Dosimeter_Time(1) CDFData.SEED_Dosimeter_Time(end)]);
xlabel('UTC Time (Hours)')
yticks([50, 60 70 80 90])
yticklabels({'50', '60', '70', '80', '90'})


%Save the time series to a file.
saveas(fig2, DosimeterFileName);



end


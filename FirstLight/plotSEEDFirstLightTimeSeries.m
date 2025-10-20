function plotSEEDFirstLightTimeSeries(info, CDFInfo, CDFData)


%Now plot a time series of the data.
%This function is called by SEEDFirstLight.m

%Convert mission day of year into year, month and day of month.
%[year, month, dayOfMonth] = MDNToMonthDay(info, missionDayOfYear);
%[dayOfYear, year] = MDNToDN(missionDayOfYear);

%First calculate the number of days in the GOES data set.
numDays = length(CDFData);


%Let us concatinate the various variables.
for i = 1 : numDays

    if (i == 1)
        SEEDTime = CDFData(i).SEED_Time_Dt15_Good;
        SEEDElectronFlux = CDFData(i).SEED_Electron_Flux_Dt15_Good;
    else
        %Append the data onto the arrays.
        SEEDTime = cat(1, SEEDTime, CDFData(i).SEED_Time_Dt15_Good);
        SEEDElectronFlux = cat(1, SEEDElectronFlux, ...
            CDFData(i).SEED_Electron_Flux_Dt15_Good);

    end %End of the if-else clause - if (i == 1)
end  %End of the for loop - for i = 1 : numDays

%Separate out the various parts of the datetime vector.
dt = datetime(SEEDTime, 'ConvertFrom', 'datenum');  
year = dt.Year;
month = dt.Month;
dayOfMonth = dt.Day;
missionDayNumber = MonthDayToMDN(info, month, dayOfMonth, year);
dayOfYear = MDNToDN(missionDayNumber(1));
dn = SEEDTime;

%Set up the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.11, 0.775, 0.8150];


%Just check to see if that data makes sense.
dateFormat = 'DD';

satellite = "STPSat-6";
instrument = "SEED";
plotType = "TimeSeries";

if numDays == 1 
    dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
        num2str(dayOfMonth(1), '%02d')];
    doyStr = num2str(dayOfYear(1), '%03d');
else
    dateStr = [num2str(year(1)), num2str(month(1), '%02d'), ...
        num2str(dayOfMonth(1), '%02d'), '-', num2str(year(end)), ...
    num2str(month(end), '%02d'), num2str(dayOfMonth(end), '%02d')];
    doyStr = [num2str(dayOfYear(1), '%03d'), '-', num2str(dayOfYear(end), '%03d')];
end


titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

SEEDFileName = strcat('/SS1/STPSat-6/Plots/FirstLight/', saveName, '.png');


dateFormat = 'HH';

%Choose some energy bins for the injection analysis.
energyBin1 = 10;
energyBin2 = 50;

Energy1Str = ['SEED Energy : ', num2str(CDFData(1).SEED_Energy_Channels(energyBin1), ...
    '%3.1f'), ' keV'];
Energy2Str = ['SEED Energy : ', num2str(CDFData(1).SEED_Energy_Channels(energyBin2), ...
    '%3.1f'), ' keV'];

%Let us use a sliding average technique to find the points in time when an
%injection occurs.

%Choose a sigma value. This value will set the number of standard
%deviations beyond the mean at which we assert that an injection occured.
sigmaValue = 3.0;

%Next we choose the number of intervals to look forward in order to find an
%injection.
stepsToSkip = 5;

%Next choose the size of the sliding window over which to run the data.
slidingAverageLength = 15;

[saBoundaries, slidingInjectionIndex1] = getSlidingInjectionIndex(SEEDElectronFlux, ...
    energyBin1, sigmaValue, stepsToSkip, slidingAverageLength, dt);


%Now try to use a moving average instead of a sliding average.  Seems like
%these should return the same result but this may be more sensitive to the
%data.
stepsToSkip = 15;
movingInjectionIndex1 = getMovingInjectionIndex(info, SEEDElectronFlux, ...
    energyBin1, sigmaValue, stepsToSkip, slidingAverageLength, dt);

hold on;

% h = plot(dt, SEEDElectronFlux(:, energyBin1), 'b', ...
%     dt, SEEDElectronFlux(:, energyBin2), 'black', ...
%     dt(raBoundaries(1, injectionIndex) + fix(runningAverageLength/2)), ...
%     SEEDElectronFlux(raBoundaries(1, injectionIndex), energyBin1), 'b*', ...
%     dt(raBoundaries(1, injectionIndex) + fix(runningAverageLength/2)), ...
%     SEEDElectronFlux(raBoundaries(1, injectionIndex), energyBin2), 'black*');

h1 = plot(datenum(dt), SEEDElectronFlux(:, energyBin1), 'b', ...
    datenum(dt), SEEDElectronFlux(:, energyBin2), 'black');
h2 = plot(datenum(dt(slidingInjectionIndex1)), ...
    SEEDElectronFlux(slidingInjectionIndex1, energyBin1), 'y*');

%Set a flag for whether to plot the intervals and the standard deviation of
%the mean flux value for each interval.
plotIntervalsError = 0;

if plotIntervalsError == 1
    for i = 1 : numDataChunks
        yyy = plot(ax, [dt(saBoundaries(1, i)), dt(saBoundaries(1, i))], ...
            [raFlux1(i) + stdFlux1(i), raFlux1(i) - stdFlux1(i)], 'g', ...
            [dt(saBoundaries(1, i)), dt(saBoundaries(2, i))], ...
            [raFlux1(i), raFlux1(i)], 'g', ...
            [dt(saBoundaries(2, i)), dt(saBoundaries(2, i))], ...
            [raFlux1(i) + stdFlux1(i), raFlux1(i) - stdFlux1(i)], 'g');
        zzz = plot(ax, [dt(saBoundaries(1, i)), dt(saBoundaries(1, i))], ...
            [raFlux2(i) + stdFlux2(i), raFlux2(i) - stdFlux2(i)], 'r', ...
            [dt(saBoundaries(1, i)), dt(saBoundaries(2, i))], ...
            [raFlux2(i), raFlux2(i)], 'r', ...
            [dt(saBoundaries(2, i)), dt(saBoundaries(2, i))], ...
            [raFlux2(i) + stdFlux2(i), raFlux2(i) - stdFlux2(i)], 'r');
    end
end  %End of if statement - if plotIntervalsError

datetick('x', dateFormat)
set(h1(1),'linewidth', 1.3);
set(h1(2),'linewidth', 1.3);
legend(h1, Energy1Str, Energy2Str)
ylabel('log_{10}Flux (Counts s^{-1} sr^{-1} cm^{-2} keV^{-1})');
title(titStr);
xlabel('Hours (UTC)');

%Save the time series to a file.
saveas(fig1, SEEDFileName);

end  %End of the function plotSEEDFirstLightTimeSeries.m
function makeFigure1(info, CDFData)

%This function will make the first figure of the first light paper.
%It is called by SEEDFirstLight.m

%Find the number of days in the dataset.
numDays = length(CDFData);

%Set the total possible number of spectra in a given day.  This is set by
%the fact that the time resolution of the data is 15 seconds.
totalNumSpectraPerDay = 86400/15;

%Set an array that will hold the number of spectra in a given day.
numSpectraPerDay = NaN(numDays, 1);

%Loop through the number of days.
for dn = 1 : numDays
    numSpectraPerDay(dn) = length(CDFData(dn).SEED_Time_Dt15_Good);
end

%Calculate the percentage of spectra per day.
percentSpectra = 100.0*numSpectraPerDay/totalNumSpectraPerDay;

%Now find some mean percent spectra.
percentPre = mean(percentSpectra(1:138));
percentDuring = mean(percentSpectra(139:229));
percentAfter = mean(percentSpectra(230:end));


percentPreStr = num2str(percentPre, '%4.1f');
percentDuringStr = num2str(percentDuring, '%4.1f');
percentAfterStr = num2str(percentAfter, '%4.1f');
yearlyPercentStr = ['Yearly Percent Coverage : ', num2str(89.45), '%'];
originalStr = 'Original Reset Schedule  -- 20 Minutes';
newScheduleStr = 'New Schedule -- ';
fortyMinuteStr = '40 Minutes';

%Set up some plotting variables.
satellite = "Falcon";
instrument = "SEED";
plotType = "Percent Valid Spectra ";
dateStr = '2022 - 2023';

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr;

saveName = satellite + instrument + "_PercentValidSpectra" + "_2022";

percentSpectraFileName = strcat('/SS1/STPSat-6/Plots/FirstLight/', ...
                saveName, '.png');

%Set up the figure.
fig1 = figure();
fig1.Position = [750 25 1200 500];
ax = axes();
set(gca,'fontsize', 12) 

%Plot the data.
p = plot(1 : numDays, percentSpectra, ...
     [139, 139], [0, 100], 'k', ...
     [229, 229], [0 100], 'k', ...
     [350, 1000], [84.5, 84.5], 'k', ...
     [550, 550], [90, 70], 'k', ...
     [810, 810], [90, 70], 'k');
p(1).LineWidth = 2;
p(2).LineWidth = 3;
p(3).LineWidth = 3;
p(4).LineWidth = 2;
p(5).LineWidth = 2;
p(6).LineWidth = 2;
ylim([0 100])
xlim([1 numDays])
ylabel('Percent Possible Spectra', 'FontSize', 12, 'FontWeight', 'bold')
xlabel('Mission Day Number', 'FontSize', 12, 'FontWeight', 'bold')
plotText(ax, [0.3, 0.9], 'Mission Day', 'black', 12, 'bold')
plotText(ax, [0.32, 0.865], 'Number', 'black', 12, 'bold')
plotText(ax, [0.51, 0.9], 'Reset Schedule', 'black', 12, 'bold')
plotText(ax, [0.53, 0.865], '(Minutes)', 'black', 12, 'bold')
plotText(ax, [0.71, 0.9], 'Possible Spectra', 'black', 12, 'bold')
plotText(ax, [0.74, 0.865], '(Percent)', 'black', 12, 'bold')
plotText(ax, [0.31, 0.815], '1 - 124', 'black', 12, 'bold')
plotText(ax, [0.31, 0.775], '125 - 216', 'black', 12, 'bold')
plotText(ax, [0.31, 0.735], '217 - 1327', 'black', 12, 'bold')
plotText(ax, [0.55, 0.815], '20', 'black', 12, 'bold')
plotText(ax, [0.55, 0.775], '40', 'black', 12, 'bold')
plotText(ax, [0.55, 0.735], '20', 'black', 12, 'bold')
plotText(ax, [0.75, 0.815], percentPreStr, 'black', 12, 'bold')
plotText(ax, [0.75, 0.775], percentDuringStr, 'black', 12, 'bold')
plotText(ax, [0.75, 0.736], percentAfterStr, 'black', 12, 'bold')

%Save the time series to a file.
saveas(fig1, percentSpectraFileName);

end
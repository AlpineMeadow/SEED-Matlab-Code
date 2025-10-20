function plotCDFDosimeterData(info, rawDosimeterData)


%This function will plot the raw dosimeter data.

%Find the number of events.
numEvents = length(rawDosimeterData.DOSEData(:,1));

%Now find the difference between the rows.
orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.
countDifferenceChannel1 = diff(rawDosimeterData.DOSEData(:, 1), orderOfDifference, arrayDimension);
countDifferenceChannel2 = diff(rawDosimeterData.DOSEData(:, 2), orderOfDifference, arrayDimension);
countDifferenceChannel3 = diff(rawDosimeterData.DOSEData(:, 3), orderOfDifference, arrayDimension);
countDifferenceChannel4 = diff(rawDosimeterData.DOSEData(:, 4), orderOfDifference, arrayDimension);

%Find the conversion factor between counts and dose.			
%newChannel1CountsToRads = findConversionFactor(countDifferenceChannel1, info);

%We need to prepend the original first row to the new array.
countsChannel1 = [rawDosimeterData.DOSEData(1, 1); countDifferenceChannel1];
countsChannel2 = [rawDosimeterData.DOSEData(1, 2); countDifferenceChannel2];
countsChannel3 = [rawDosimeterData.DOSEData(1, 3); countDifferenceChannel3];
countsChannel4 = [rawDosimeterData.DOSEData(1, 4); countDifferenceChannel4];

makeHistogram = 0;

if makeHistogram 
    %Make a histogram to see the distribution of the delta t values.
    binEdges = -20:10:50;

    %Now make the histogram.
    fig = figure('DefaultAxesFontSize', 12);
    fig.Position = [750 25 1200 700];

    %Make a plot name string.
    satellite = 'Falcon';
    instrument = 'Dosimeter';
    conFactor = 'Histogram';
    saveName3 = strcat(satellite, instrument, conFactor, info.startYearStr, ...
        '_', info.startDateStr);

    figFileName = strcat(info.dosimeterPlotDir, 'TimeHistogram/', saveName3, '.png');

    titStr = ['Dosimeter Channel 1 Differenced Counts Histogram For : ', ...
        info.startDayOfMonthStr, ' ', info.startMonthName, ' ' , ...
        info.startYearStr];

    h = histogram(countsChannel1, binEdges, 'Normalization', 'probability');
    xlabel('Count Values')
    ylabel('Normalized Frequency')
    title(titStr)
    numNegValues = ['Number of Negative Values : ', ...
        num2str(h.Values(2)*length(countsChannel1))];
    text('Units', 'Normalized', 'Position', [0.5, 0.9], 'string', numNegValues, ...
        'FontSize', 12);

    %Save the histogram to a file.
    saveas(fig, figFileName);
end  %end of if statement - if makeHistogram


%Now we want to check out how keeping or removing negative counts will
%affect the results.  We will accomplish this by setting a value which will
%keep or discard the counts.

lowerCountsLimitA = 1;
lowerCountsLimitB = -10;
lowerCountsLimitB = 0;


%Now set any negative differences to NaN.  This may not be what we want to
%do.  Lets look at how it looks.  We may just want to take the absolute
%value of the entire data array.
%counts(counts < 0) = 0;

countsChannel1A = countsChannel1;
countsChannel2A = countsChannel2;
countsChannel3A = countsChannel3;
countsChannel4A = countsChannel4;

countsChannel1B = countsChannel1;
countsChannel2B = countsChannel2;
countsChannel3B = countsChannel3;
countsChannel4B = countsChannel4;

countsChannel1A(countsChannel1A < lowerCountsLimitA) = NaN;
countsChannel2A(countsChannel2A < lowerCountsLimitA) = NaN;
countsChannel3A(countsChannel3A < lowerCountsLimitA) = NaN;
countsChannel4A(countsChannel4A < lowerCountsLimitA) = NaN;

countsChannel1B(countsChannel1B < lowerCountsLimitB) = NaN;
countsChannel2B(countsChannel2B < lowerCountsLimitB) = NaN;
countsChannel3B(countsChannel3B < lowerCountsLimitB) = NaN;
countsChannel4B(countsChannel4B < lowerCountsLimitB) = NaN;

%Now set any high value to NaN.  We do this because the instrument had a
%12-bit data value which translates to a maximum count value of 4096. 
%If any data values are higher than this
%there is some kind of error(hardware or software).  It is not real.  As
%there appear to be few of these lets just set them to NaNs.
countsChannel1A(countsChannel1A > 16384)  = NaN;
countsChannel2A(countsChannel2A > 16384) = NaN;
countsChannel3A(countsChannel3A > 16384) = NaN;
countsChannel4A(countsChannel4A > 16384) = NaN;

countsChannel1B(countsChannel1B > 16384)  = NaN;
countsChannel2B(countsChannel2B > 16384) = NaN;
countsChannel3B(countsChannel3B > 16384) = NaN;
countsChannel4B(countsChannel4B > 16384) = NaN;

countsChannel1(countsChannel1 > 16384)  = NaN;
countsChannel2(countsChannel2 > 16384) = NaN;
countsChannel3(countsChannel3 > 16384) = NaN;
countsChannel4(countsChannel4 > 16384) = NaN;

%Calculate the differential daily dose.
differentialDoseChannel1A = info.channel1CountsToRads*countsChannel1A;
differentialDoseChannel2A = info.channel2CountsToRads*countsChannel2A;
differentialDoseChannel3A = info.channel3CountsToRads*countsChannel3A;
differentialDoseChannel4A = info.channel4CountsToRads*countsChannel4A;

differentialDoseChannel1B = info.channel1CountsToRads*countsChannel1B;
differentialDoseChannel2B = info.channel2CountsToRads*countsChannel2B;
differentialDoseChannel3B = info.channel3CountsToRads*countsChannel3B;
differentialDoseChannel4B = info.channel4CountsToRads*countsChannel4B;

differentialDoseChannel1 = info.channel1CountsToRads*countsChannel1;
differentialDoseChannel2 = info.channel2CountsToRads*countsChannel2;
differentialDoseChannel3 = info.channel3CountsToRads*countsChannel3;
differentialDoseChannel4 = info.channel4CountsToRads*countsChannel4;

%Calculate the total daily dose.
totalDose1A = sum(differentialDoseChannel1A, 'omitnan');
totalDose2A = sum(differentialDoseChannel2A, 'omitnan');
totalDose3A = sum(differentialDoseChannel3A, 'omitnan');
totalDose4A = sum(differentialDoseChannel4A, 'omitnan');

totalDose1B = sum(differentialDoseChannel1B, 'omitnan');
totalDose2B = sum(differentialDoseChannel2B, 'omitnan');
totalDose3B = sum(differentialDoseChannel3B, 'omitnan');
totalDose4B = sum(differentialDoseChannel4B, 'omitnan');

totalDose1 = sum(differentialDoseChannel1, 'omitnan');
totalDose2 = sum(differentialDoseChannel2, 'omitnan');
totalDose3 = sum(differentialDoseChannel3, 'omitnan');
totalDose4 = sum(differentialDoseChannel4, 'omitnan');

%Set up strings containing the total daily dose.
channel1ATotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitA), ') : ', num2str(totalDose1A, '%6.3f'), ' Rads'];
channel2ATotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitA), ') : ', num2str(totalDose2A, '%6.3f'), ' Rads'];
channel3ATotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitA), ') : ', num2str(totalDose3A, '%6.3f'), ' Rads'];
channel4ATotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitA), ') : ', num2str(totalDose4A, '%6.3f'), ' Rads'];

channel1BTotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitB), ') : ', num2str(totalDose1B, '%6.3f'), ' Rads'];
channel2BTotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitB), ') : ', num2str(totalDose2B, '%6.3f'), ' Rads'];
channel3BTotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitB), ') : ', num2str(totalDose3B, '%6.3f'), ' Rads'];
channel4BTotalDoseStr = ['Total Daily Dose(Counts > ', ...
    num2str(lowerCountsLimitB), ') : ', num2str(totalDose4B, '%6.3f'), ' Rads'];

channel1TotalDoseStr = ['Total Daily Dose(All Counts) : ', ...
    num2str(totalDose1, '%10.8g'), ' Rads'];
channel2TotalDoseStr = ['Total Daily Dose(All Counts) : ', ...
    num2str(totalDose2, '%10.8g'), ' Rads'];
channel3TotalDoseStr = ['Total Daily Dose(All Counts) : ', ...
    num2str(totalDose3, '%10.8g'), ' Rads'];
channel4TotalDoseStr = ['Total Daily Dose(All Counts) : ', ...
    num2str(totalDose4, '%10.8g'), ' Rads'];

%Make a plot of the noise in the signal.
fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];

%Make some plotting strings.
titStr1 = ['Channel 1 Differential Dose Versus Time For : ', info.startDayOfMonthStr, ...
    ' ', info.startMonthName, ' ' , info.startYearStr];
titStr2 = ['Channel 2 Differential Dose Versus Time For : ', info.startDayOfMonthStr, ...
    ' ', info.startMonthName, ' ' , info.startYearStr];

%Make a plot name string.
satellite = 'Falcon';
instrument = 'SEED';
conFactor = 'TimeSeries';
saveName3 = strcat(satellite, instrument, conFactor, info.startYearStr, ...
    '_', info.startDateStr);

fig1FileName = strcat(info.dosimeterPlotDir, 'TimeSeries/', saveName3, '.png');

left = 0.1;
width = 0.8;
height = 0.3;
bottom = [0.54, 0.12];

xtickValues = [1:numEvents/24:numEvents, numEvents];
xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
    ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};

sp1 = subplot(2, 1, 1);
% plot(1:length(differentialDoseChannel1A), 3*differentialDoseChannel1A, 'b-*', ...
%      1:length(differentialDoseChannel1B), 3*differentialDoseChannel1B, 'g', ...
%      1:length(differentialDoseChannel1), differentialDoseChannel1, 'r')
plot(1:length(differentialDoseChannel3A), 3*differentialDoseChannel3A, 'b-*', ...
     1:length(differentialDoseChannel3B), 3*differentialDoseChannel3B, 'g', ...
     1:length(differentialDoseChannel3), differentialDoseChannel3, 'r')
title(titStr1)
%text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', ...
%    'Channel 1', 'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', ...
    'Channel 3', 'FontSize', 11);
%ylabel('Dose (Rad)')
ylabel('Arbitrary Units')
%ylabel('Counts')
xlabel('Time (Hours - UTC)')
ylim([-1 1])
xlim([0 numEvents])
set(sp1, 'Position', [left, bottom(1), width, height]);
sp1.XTick = xtickValues;
sp1.XTickLabel = xtickLabels;
%legend(channel1ATotalDoseStr, channel1BTotalDoseStr, channel1TotalDoseStr, ...
%    'Location', 'southeast') 
legend(channel3ATotalDoseStr, channel3BTotalDoseStr, channel3TotalDoseStr, ...
    'Location', 'southeast')

sp2 = subplot(2, 1, 2);
% plot(1:length(differentialDoseChannel2A), 3*differentialDoseChannel2A, 'b-*', ...
%      1:length(differentialDoseChannel2B), 3*differentialDoseChannel2B, 'g', ...
%      1:length(differentialDoseChannel2), differentialDoseChannel2, 'r')
plot(1:length(differentialDoseChannel4A), 3*differentialDoseChannel4A, 'b-*', ...
     1:length(differentialDoseChannel4B), 3*differentialDoseChannel4B, 'g', ...
     1:length(differentialDoseChannel4), differentialDoseChannel4, 'r')
%text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', ...
%    'Channel 2', 'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', ...
    'Channel 4', 'FontSize', 11);
title(titStr2)
ylabel('Arbitrary Units')
%ylabel('Dose (Rad)')
%ylabel('Counts')
xlabel('Time (Hours - UTC)')
xlim([0 numEvents])
ylim([-150 400])
set(sp2, 'Position', [left, bottom(2), width, height]);
sp2.XTick = xtickValues;
sp2.XTickLabel = xtickLabels;
%legend(channel2ATotalDoseStr, channel2BTotalDoseStr, channel2TotalDoseStr)
legend(channel4ATotalDoseStr, channel4BTotalDoseStr, channel4TotalDoseStr)

%Save the histogram to a file.
saveas(fig1, fig1FileName);

end  %End of the function plotCDFDosimeterData.m
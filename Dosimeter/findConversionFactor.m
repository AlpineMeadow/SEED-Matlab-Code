function newChannel1CountsToRads = findConversionFactor(countDifferenceChannel1, info)


%I am now being asked to do something that I only marginally understand.
%According to my understanding, the count values in the rawDose channels
%will always increase except for two reasons.  The first is when the
%instrument resets every 20 minutes.  Then the counts are set to zero
%(except for channel 1, which is apparently set to an arbitrary value.
% The second reason is that the counters can overflow.  Richard said
%that the counters are 12-bit counters which means they can record up to
%4096 counts.  But he also tells me that I should not worry about 4096 as
%that is somehow not important.  Apparently what happens is that the ADC
%allows a factor of 4 larger then 4096 so counts can legitimately get up to
%16384 before it rolls over.
%In any event I am supposed to subtract the (average highest count
%before rollover) – (average lowest count after rollover).  This is not to 
%be done for the 20 minute reset events but only for the rollover events.
%This procedure yields the delta counts corresponding to 3.6 mRad and that 
%will be the case even during 20 min cycles when it doesn't roll over 
%The problem is distinguishing between rollovers due to high count values
%and resets due to the 20 minute reset events since the way I am finding
%events like this is to look at the results of differencing each value.
%When the diff value is negative then we have had either a rollover or a
%reset event.  The way to do this is to find the counts around -8900 which
%cause a rollover.  The mean of the distribution of those counts gives the
%value around which to calculate the calibration factor.

%This function is called by getDosimeterDose.m.


%First find the indices where the count difference goes negative.
rolloverPlusResetIndex = find(countDifferenceChannel1 < 0);

%Find the indices from the rollover index that correspond to rollover events
%as compared to the reset events.
%rolloverIndex = find(countDifferenceChannel1(rolloverPlusResetIndex) < info.minimumDiffValue);
rolloverIndex = find(countDifferenceChannel1(rolloverPlusResetIndex) < 1);
%Now just create a new index that contains the points that are believed to
%be rollover events.
validRolloverIndex = rolloverPlusResetIndex(rolloverIndex);


%Lets make some plots.
%Set the figure width and height and x position.  
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.71, 0.42, 0.08];

%Set the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];
ax = axes(fig1);

%Make a title for the plot as well as the file.
satellite = "Falcon";
instrument = "SEED";
plotType = "DosimeterRolloverCounts";
dateStr = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
doyStr = info.startDayOfYearStr;


saveName = satellite + instrument + plotType + dateStr + "_" + ...
	info.startDayOfYearStr + '-' + info.endDayOfYearStr;

fig1FileName = strcat(info.dosimeterPlotDir, saveName, '.png');

titStr = ['Plot of Count Difference as a Function of Days : ', info.startDayOfYearStr, ...
    ' - ', info.endDayOfYearStr];

%Now plot all negative values which appear to be due to rollover and not
%resetting.
plot(validRolloverIndex, countDifferenceChannel1(validRolloverIndex), 'ro', ...
    [1:length(countDifferenceChannel1)], countDifferenceChannel1, 'b')
title(titStr)
xlabel('Time (seconds)')
ylim([-15000 5000])
ylabel('Difference in Counts')
yticklabels({'-15000', '-10000', '-5000', '0', '5000'})
legend('Rollover Counts', 'Difference Counts')

%Save the spectra to a file.
saveas(fig1, fig1FileName);


%Now make a histogram of the large negative
conFactor = 'Comparison';
saveName2 = satellite + instrument + conFactor + plotType + info.startYearStr + ...
	'_' + info.startDayOfYearStr + '-' + info.endDayOfYearStr;

fig2FileName = strcat(info.dosimeterPlotDir, saveName2, '.png');

%Lets pick out the count values between -8960 and -8900.
calIndex = find(countDifferenceChannel1 <= -8900 & ...
    countDifferenceChannel1 >= -8960);

%Lets make some plots.
%Set the figure width and height and x position.  
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.71, 0.42, 0.08];

%Set the figure handle.
fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 700];
ax = axes(fig2);

%Fit a normal distribution to the data.
pd = fitdist(countDifferenceChannel1(calIndex), 'Normal');
averageRolloverCounts = pd.mu;
stdRolloverCounts = pd.sigma;

%Create some strings to plotted.
averageRolloverCountsStr = ['Average Rollover Counts : ', ...
	num2str(averageRolloverCounts, '%6.2f')];
stdRolloverCountsStr = ['Standard Deviation of Rollover Counts : ', ...
	num2str(stdRolloverCounts, '%6.3f')];

%Here we generate the old and new conversion factors.
oldChannel1CountsToRads = 1.0/1.0517e6;
newChannel1CountsToRads = 3.6/(1000*abs(averageRolloverCounts));

oldConversionFactorStr = ['Conversion Factor From Paper : ', ...
	num2str(oldChannel1CountsToRads, '%6.2e'), ' Rad/Count'];
newConversionFactorStr = ['Conversion Factor From Data : ', ...
	num2str(newChannel1CountsToRads, '%6.2e'), ' Rad/Count'];


titStr = ['Histogram of Rollover Counts for Day of Year : ', ...
	info.startDayOfYearStr, ' - ', info.endDayOfYearStr];

%Set the bins to catch the data that corresponds to when the counting
%rollover  occurs.
bins = -8960:4:-8900;

%Plot a histogram of the counts.
histfit(countDifferenceChannel1(calIndex), 10)
title(titStr)
xlabel('Counts')
ylabel('Count Frequency')
text('Units', 'Normalized', 'Position', [0.02, 0.9], 'string', ...
	averageRolloverCountsStr, 'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.02, 0.85], 'string', ...
	stdRolloverCountsStr, 'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.02, 0.80], 'string', ...
	oldConversionFactorStr, 'FontSize', 11);
text('Units', 'Normalized', 'Position', [0.02, 0.75], 'string', ...
	newConversionFactorStr, 'FontSize', 11);


%Save the spectra to a file.
saveas(fig2, fig2FileName);




end  %End of function findConversionFactor.m
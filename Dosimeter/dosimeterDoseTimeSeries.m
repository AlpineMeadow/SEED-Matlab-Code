function dosimeterDoseTimeSeries(info, rawTime, xvalues, xdays, rawDose);

%This function is called by get getDosimeterDose.m

%Add the value zero to the xvalues vector so that we can use the
%xValueIndex result to index into the range of events in a given day.
xValueIndex = [0; xvalues];

%Determine the number of days being analyzed.
numXDays = length(xdays);

%Set up some arrays to hold the daily total counts and the daily dose.
dailyTotalCounts1 = zeros(1, numXDays);
dailyTotalCounts2 = zeros(1, numXDays);
dailyDose1 = zeros(1, numXDays);
dailyDose2 = zeros(1, numXDays);

%Set up some variables that will be used in the differencing of the data.
orderOfDifference = 1;
arrayDimension = 1;

%Lets make some plots.  Here we loop over the days to be analyzed.
for i = 1 : length(xvalues) - 1
%for i = 1 : length(xvalues) 
	%Set up a time vector.
	dayTime = rawTime(xValueIndex(i) + 1 : xValueIndex(i + 1));
	time = dayTime - dayTime(1);


	%Now find the difference between the rows.
	orderOfDifference = 1;  %This will always be what we want.
	arrayDimension = 1;  %This will always be what we want.

	%Get the counts for each channel depending on the day in question.
	counts1 = rawDose(xValueIndex(i) + 1 : xValueIndex(i + 1), 1);
	counts2 = rawDose(xValueIndex(i) + 1 : xValueIndex(i + 1), 2);
	counts3 = rawDose(xValueIndex(i) + 1 : xValueIndex(i + 1), 3);
	counts4 = rawDose(xValueIndex(i) + 1 : xValueIndex(i + 1), 4);

	%Difference the counts.
	diffCountsChannel1 = diff(counts1, orderOfDifference, arrayDimension);
	diffCountsChannel2 = diff(counts2, orderOfDifference, arrayDimension);
	diffCountsChannel3 = diff(counts3, orderOfDifference, arrayDimension);
	diffCountsChannel4 = diff(counts4, orderOfDifference, arrayDimension);
	
	%Lets find the index for the counts that indicate either a roll over or a reset.
	rRI1 = find(diffCountsChannel1 <= -10);
	rRI2 = find(diffCountsChannel2 <= -10);
	rRI3 = find(diffCountsChannel3 <= -10);
	rRI4 = find(diffCountsChannel4 <= -10);

	plotTime1 = 1 : length(rRI1);
	plotTime2 = 1 : length(rRI2);
	
	%Find the index just before the rollover or reset.
	rolloverResetIndex1 = rRI1 - 1;
	rolloverResetIndex2 = rRI2 - 1;
	rolloverResetIndex3 = rRI3 - 1;
	rolloverResetIndex4 = rRI4 - 1;

	%Now find the index for the time just after either a roll over or a
	%reset.  Prepend the index 1 onto the array so that we can catch the
	%first interval.
	previousCountRolloverResetIndex1 = [1; rRI1(1 : end - 1) + 1];
	previousCountRolloverResetIndex2 = [1; rRI2(1 : end - 1) + 1];
	previousCountRolloverResetIndex3 = [1; rRI3(1 : end - 1) + 1];
	previousCountRolloverResetIndex4 = [1; rRI4(1 : end - 1) + 1];

	%Now for each section of data that has either a rollover or a reset we
	%want to integrate the dose.  Here we do channel 1.
	[dailyCountValues1, dailyCountRateValues1, deltaT1] = getDailyCountCountRateValues(rolloverResetIndex1, ...
		previousCountRolloverResetIndex1, time, diffCountsChannel1);

	%Now for each section of data that has either a rollover or a reset we
	%want to integrate the dose.  Here we do channel 2.
	[dailyCountValues2, dailyCountRateValues2, deltaT2] = getDailyCountCountRateValues(rolloverResetIndex2, ...
		previousCountRolloverResetIndex2, time, diffCountsChannel2);

	%Calculate the daily total counts from the daily counts.
	dailyTotalCounts1(i) = sum(dailyCountValues1);
	dailyTotalCounts2(i) = sum(dailyCountValues2);

	%Set up the concatenation of the arrays.
	if (i == 1)
		accumulatedCountValues1 = dailyCountValues1;
		accumulatedCountRateValues1 = dailyCountRateValues1;
		deltaTime1 = deltaT1;

		accumulatedCountValues2 = dailyCountValues2;
		accumulatedCountRateValues2 = dailyCountRateValues2;
		deltaTime2 = deltaT2;

	else
		accumulatedCountValues1 = cat(2, accumulatedCountValues1, dailyCountValues1);
		accumulatedCountRateValues1 = cat(2, accumulatedCountRateValues1, dailyCountRateValues1);
		deltaTime1 = cat(2, deltaTime1, deltaT1);

		accumulatedCountValues2 = cat(2, accumulatedCountValues2, dailyCountValues2);
		accumulatedCountRateValues2 = cat(2, accumulatedCountRateValues2, dailyCountRateValues2);
		deltaTime2 = cat(2, deltaTime2, deltaT2);
	end

	%Now calculate the daily dose.
	dailyDose1 = info.channel1CountsToRads*accumulatedCountValues1;
	dailyDose2 = info.channel2CountsToRads*accumulatedCountValues2;

	%Make a plot of the noise in the signal.
	fig1 = figure('DefaultAxesFontSize', 12);
%	fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
	fig1.Position = [750 25 1200 700];

	%Make some plotting strings.
	if xdays == 282
		titStr1 = ['Channel 1 Dose Versus Time For Day of Year : ', num2str(xdays(i)), ' (10/9/2022)'];
		titStr2 = ['Channel 2 Dose Versus Time For Day of Year : ', num2str(xdays(i)), ' (10/9/2022)'];
	else
		titStr1 = ['Channel 1 Dose Versus Time For Day of Year : ', num2str(xdays(i)), ' - ', ...
			datestr([info.startYear, info.startMonth, info.startDayOfMonth + i, 0, 0, 0])];
		titStr2 = ['Channel 2 Dose Versus Time For Day of Year : ', num2str(xdays(i)), ' - ', ...
			datestr([info.startYear, info.startMonth, info.startDayOfMonth + i, 0, 0, 0])];
	end


	titStr3 = ['Count Time Series For Day of Year : ', num2str(xdays(i)), ' Channel 1'];
	titStr4 = ['Count Time Series For Day of Year : ', num2str(xdays(i)), ' Channel 2'];

	%Make a plot name string.
	satellite = 'Falcon';
	instrument = 'SEED';
	conFactor = 'TimeSeries';
	saveName3 = strcat(satellite, instrument, conFactor, info.startYearStr, ...
		'_', num2str(xdays(i), '%03d'));

	fig1FileName = strcat(info.dosimeterPlotDir, 'TimeSeries/', saveName3, '.png');

	left = 0.1;
	width = 0.8;
	height = 0.3;
	bottom = [0.54, 0.12];

	xtickValues = 3*[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
	xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
      ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};


	sp1 = subplot(2, 1, 1);
	plot(plotTime1, info.channel1CountsToRads*dailyCountValues1, 'b')
	title(titStr1)
	text('Units', 'Normalized', 'Position', [0.82, 0.9], 'string', ...
		'Channel 1', 'FontSize', 11);
	ylabel('Dose (Rad)')
	xlabel('Time (Hours - UTC)')
	xlim([0 72])

	if xdays == 282
		hold on
		plot([40, 40], [min(dailyDose1), max(dailyDose1)], 'r', 'LineWidth', 3)
		text('Units', 'Normalized', 'Position', [0.56, 0.85], 'string', ...
		'Gamma Ray Burst', 'FontSize', 11);
	end

	set(sp1, 'Position', [left, bottom(1), width, height]);
	sp1.XTick = xtickValues;
	sp1.XTickLabel = xtickLabels;

	sp2 = subplot(2, 1, 2);
	plot(plotTime2, info.channel2CountsToRads*dailyCountValues2, 'b')
    text('Units', 'Normalized', 'Position', [0.82, 0.9], 'string', ...
		'Channel 2', 'FontSize', 11);
	title(titStr2)
	ylabel('Dose (Rad)')
	xlabel('Time (Hours - UTC)')
	xlim([0 72])

	if xdays == 282
		hold on
		plot([40, 40], [min(dailyDose2), max(dailyDose2)], 'r', 'LineWidth', 3)
		text('Units', 'Normalized', 'Position', [0.56, 0.85], 'string', ...
		'Gamma Ray Burst', 'FontSize', 11);
	end

	set(sp2, 'Position', [left, bottom(2), width, height]);
	sp2.XTick = xtickValues;
	sp2.XTickLabel = xtickLabels;

	%Save the histogram to a file.
	saveas(fig1, fig1FileName);

	%Clear the current figure.
	clf;

end %End of for loop  for i = 1 : length(xvalues) - 1



end  %End of function dosimeterDoseTimeSeries.m.

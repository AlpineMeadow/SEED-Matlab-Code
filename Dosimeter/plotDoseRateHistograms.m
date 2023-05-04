function plotDoseRateHistograms(info, xdays, xvalues, doseRateChannel1, ...
	doseRateChannel2, doseRateChannel3, doseRateChannel4, rawTime)

%This function is called by getDosimeterData.m

%Set up the conversion factors.
channel1ConversionFactor = 4.03e-7;  %Units are rad/count.
channel2ConversionFactor = 1.01e-4;  %Units are rad/count.
channel3ConversionFactor = 2.633e-2;  %Units are rad/count.

%Set up the indices for the days.
%Handle the first instance separately.

%Add the value zero to the xvalues vector so that we can use the
%xValueIndex result to index into the range of events in a given day.
xValueIndex = [0; xvalues];

%Lets make some plots.
for i = 1 : length(xvalues) - 1

	%Get the number of events for each day.
	numEvents = xValueIndex(i + 1) - xValueIndex(i) + 1;

	%Set the figure handle.
	fig2 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
%	fig2 = figure('DefaultAxesFontSize', 12);
	fig2.Position = [750 25 1200 700];

	%Get the dose rates out of the long arrays.
	doseRate1 = doseRateChannel1(xValueIndex(i) + 1 : xValueIndex(i + 1));
	doseRate2 = doseRateChannel2(xValueIndex(i) + 1 : xValueIndex(i + 1));
	doseRate3 = doseRateChannel3(xValueIndex(i) + 1 : xValueIndex(i + 1));
	time = rawTime(xValueIndex(i) + 1 : xValueIndex(i + 1));
	time = time - time(1);

	%Use the index to get the positive dose rate events and convert from 
	%counts to dose.
	goodDoseRate1 = channel1ConversionFactor*doseRate1(doseRate1 >= 0);
    goodDoseRate2 = channel2ConversionFactor*doseRate2(doseRate2 >= 0);
	goodDoseRate3 = channel3ConversionFactor*doseRate3(doseRate3 >= 0);

	%Fit a normal distribution to the data.
	pd1 = fitdist(goodDoseRate1, 'Normal');
	averageDoseRate1 = pd1.mu;
	stdDoseRate1 = pd1.sigma;
	pd2 = fitdist(goodDoseRate2, 'Normal');
	averageDoseRate2 = pd2.mu;
	stdDoseRate2 = pd2.sigma;
	pd3 = fitdist(goodDoseRate3, 'Normal');
	averageDoseRate3 = pd3.mu;
	stdDoseRate3 = pd3.sigma;

		
	%Make some plotting strings.
	titStr1 = ['Average Dose Rate For Day of Year : ', ...
		num2str(xdays(i)), ' Channel 1'];

	titStr2 = ['Average Dose Rate For Day of Year : ', ...
		num2str(xdays(i)), ' Channel 2'];

	titStr3 = ['Average Dose Rate For Day of Year : ', ...
		num2str(xdays(i)), ' Channel 3'];

	averageDoseRate1Str = ['Average Dose Rate : ', ...
		num2str(averageDoseRate1, '%7.3g'), ' Rad/sec'];
	stdDoseRate1Str = ['Stardard Deviation of Dose Rate : ', ...
		num2str(stdDoseRate1, '%7.3g'), ' Rad/sec'];

	averageDoseRate2Str = ['Average Dose Rate : ', ...
		num2str(averageDoseRate2, '%7.3g'), ' Rad/sec'];
	stdDoseRate2Str = ['Stardard Deviation of Dose Rate : ', ...
		num2str(stdDoseRate2, '%7.3g'), ' Rad/sec'];

	averageDoseRate3Str = ['Average Dose Rate : ', ...
		num2str(averageDoseRate3, '%7.3g'), ' Rad/sec'];
	stdDoseRate3Str = ['Stardard Deviation of Dose Rate : ', ...
		num2str(stdDoseRate3, '%7.3g'), ' Rad/sec'];	
	
	numEventsStr = ['Number of Events : ', num2str(numEvents)];

	%Make a plot name string.
	satellite = 'Falcon';
	instrument = 'SEED';
	conFactor = 'DoseRateHistogram';
	saveName2 = strcat(satellite, instrument, conFactor, info.startYearStr, ...
		'_', num2str(xdays(i), '%03d'));

	fig2FileName = strcat(info.dosimeterPlotDir, 'DoseRate/', saveName2, '.png');

	left = 0.1;
	width = 0.8;
	height = 0.18;
	bottom = [0.75, 0.43, 0.14];

	sp1 = subplot(3, 1, 1);
	histfit(goodDoseRate1, 10)
	title(titStr1)
	xlabel('Dose Rate (Rad)')
	ylabel('Frequency')
	set(sp1, 'Position', [left, bottom(1), width, height]);
	text('Units', 'Normalized', 'Position', [0.52, 0.9], 'string', ...
		averageDoseRate1Str, 'FontSize', 11);
	text('Units', 'Normalized', 'Position', [0.52, 0.75], 'string', ...
		stdDoseRate1Str, 'FontSize', 11);

	sp2 = subplot(3, 1, 2);
	histfit(goodDoseRate2, 10)
	title(titStr2)
	ylabel('Frequency')
	xlabel('Dose Rate (Rad)')
	set(sp2, 'Position', [left, bottom(2), width, height]);
	text('Units', 'Normalized', 'Position', [0.52, 0.9], 'string', ...
		averageDoseRate2Str, 'FontSize', 11);
	text('Units', 'Normalized', 'Position', [0.52, 0.75], 'string', ...
		stdDoseRate2Str, 'FontSize', 11);

	sp3 = subplot(3, 1, 3);
	histfit(goodDoseRate3, 10)
	title(titStr3)
	xlabel('Dose Rate (Rad)')
	ylabel('Frequency')
	set(sp3, 'Position', [left, bottom(3), width, height]);
	text('Units', 'Normalized', 'Position', [0.52, 0.9], 'string', ...
		averageDoseRate3Str, 'FontSize', 11);
	text('Units', 'Normalized', 'Position', [0.52, 0.75], 'string', ...
		stdDoseRate3Str, 'FontSize', 11);

	%Save the spectra to a file.
	saveas(fig2, fig2FileName);

	%Clear the current figure.
%	clf;

    %Plot the noise for each of the channels.
    dosimeterPlotSignalNoise(info, xdays, time, doseRate1, doseRate2, ...
		doseRate3, i);


end  %End of for loop - for i = 1 : length(xvalues) - 1

end  %End of the function plotDoseRateHistograms.m
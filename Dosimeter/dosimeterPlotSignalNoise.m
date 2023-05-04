function dosimeterPlotSignalNoise(info, xdays, time, doseRate1, doseRate2, ...
	doseRate3, i);


 %This function is called by plotDoseRateHistograms.m

	%Make a plot of the noise in the signal.
	fig3 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
	fig3.Position = [750 25 1200 700];



	%Make some plotting strings.
	titStr1 = ['Dose Rate For Day of Year : ', ...
		num2str(xdays(i)), ' Channel 1'];

	titStr2 = ['Dose Rate For Day of Year : ', ...
		num2str(xdays(i)), ' Channel 2'];

	titStr3 = ['Dose Rate For Day of Year : ', ...
		num2str(xdays(i)), ' Channel 3'];

	%Make a plot name string.
	satellite = 'Falcon';
	instrument = 'SEED';
	conFactor = 'CountRateTimeSeries';
	saveName3 = strcat(satellite, instrument, conFactor, info.startYearStr, ...
		'_', num2str(xdays(i), '%03d'));

	fig3FileName = strcat(info.dosimeterPlotDir, 'DoseRate/', saveName3, '.png');

	left = 0.1;
	width = 0.8;
	height = 0.18;
	bottom = [0.75, 0.43, 0.14];

	sp1 = subplot(3, 1, 1);
	plot(time, doseRate1)
	title(titStr1)
	ylim([-10 10])
	ylabel('Count Rate (counts/s)')
	xlabel('Event Time (s)')
	set(sp1, 'Position', [left, bottom(1), width, height]);

	sp2 = subplot(3, 1, 2);
	plot(time, doseRate2)
	title(titStr2)
	ylim([-10 10])
	xlabel('Event Time (s)')
	ylabel('Count Rate (counts/s)')
	set(sp2, 'Position', [left, bottom(2), width, height]);

	sp3 = subplot(3, 1, 3);
	plot(time, doseRate3)
	title(titStr3)
	ylim([-10 10])
	ylabel('Count Rate (counts/s)')
	xlabel('Event Time (s)')
	set(sp3, 'Position', [left, bottom(3), width, height]);

	%Save the spectra to a file.
	saveas(fig3, fig3FileName);

	%Clear the current figure.
%	clf;


end  %End of function dosimeterPlotSignalNoise.m
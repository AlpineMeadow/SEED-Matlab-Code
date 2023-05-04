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
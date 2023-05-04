function dosimeterDoseTimeHistogram(info, rawTime, xvalues, xdays)
  %This function is called by getDosimeterDose.m

%Add the value zero to the xvalues vector so that we can use the
%xValueIndex result to index into the range of events in a given day.
xValueIndex = [0; xvalues];

orderOfDifference = 1;
arrayDimension = 1;

%Lets make some plots.
for i = 1 : length(xvalues) - 1

	dayTime = rawTime(xValueIndex(i) + 1 : xValueIndex(i + 1));

	%Take the difference in the time bins.
	diffDayTime = diff(dayTime, orderOfDifference, arrayDimension);
	
	%Make a plot of the noise in the signal.
%	fig1 = figure('DefaultAxesFontSize', 12);
	fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
	fig1.Position = [750 25 1200 700];

	%Make some plotting strings.
	titStr1 = ['Time Difference Histogram For Day of Year : ', num2str(xdays(i))];

	%Make a plot name string.
	satellite = 'Falcon';
	instrument = 'SEED';
	conFactor = 'TimeHistogram';
	saveName3 = strcat(satellite, instrument, conFactor, info.startYearStr, ...
		'_', num2str(xdays(i), '%03d'));

	fig1FileName = strcat(info.dosimeterPlotDir, 'TimeHistogram/', saveName3, '.png');

	left = 0.1;
	width = 0.8;
	height = 0.18;
	bottom = [0.75, 0.43, 0.14];

	%Make a histogram of the time.
	histogram(diffDayTime)
	title(titStr1)
	ylim([0 200])
	ylabel('Frequency')
	xlabel('Time (s)')

	%Save the histogram to a file.
	saveas(fig1, fig1FileName);

	%Clear the current figure.
%	clf;

end %End of for loop  for i = 1 : length(xvalues) - 1



end  %End of the function dosimeterDoseTimeHistogram.m
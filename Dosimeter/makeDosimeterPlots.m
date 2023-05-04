function makeDosimeterPlots(plotDirStr, dataAttributes, rawData)

  %This function is called by FalconSEEDFlux.m.  In principal I would not
  %call this function from FalconSEEDFlux but this is for a quick job and I
  %do not want to spend the time.

  DosimeterCounts = rawData.TYPE1_PKT_DOSIMETER_ARRAY;
  time = rawData.TYPE1_PKT_DATA_TIME_ARRAY;
  temperatureData = rawData.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY;

  %Lets set the time to start from 0 and also be fractions of seconds.
  time = (time - time(1))/86400.0;

  %Determine the number of events.
  numEvents = length(time);

  a = "Falcon";
  b = "STPSat-6";
  c = "Dosimeter";
  d = dataAttributes.date;
  e = dataAttributes.julianday;

  titleStr = a + " " + b + " " + c + " " + d + " " + e;
  saveName = a + b + "_" + c + "_" + d + "_" + e;

  DosimeterFileName = strcat(info.plotDirStr, 'Dosimeter/', saveName, '.png');
  DosimeterFileName1 = strcat(info.plotDirStr, 'Dosimeter/', saveName, '_Compare.png');

  %Set the figure width and height and x position.
  left = 0.1;
  width = 0.8;
  height = 0.15;
  bottom = [0.78, 0.62, 0.46, 0.30, 0.14];

  fig1 = figure('DefaultAxesFontSize', 12);
  fig1.Position = [750 25 1200 700];

  %Set up a vector of values to be used in the xticks plot function.
  xtickSValues = (numEvents/23)*[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23];
  xtickLabels = {' ', '1', ' ', '3', ' ', '5', ' ', '7', ' ', '9', ' ', ...
      '11', ' ', '13', ' ', '15', ' ', '17', ' ', '19', ' ', '21', ' ', '23'};

  sp1 = subplot(5, 1, 1); 
  plot(time, DosimeterCounts(:, 1), 'b.')
  sp1.XTick = xtickSValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
  ylim([min(DosimeterCounts(:, 1)) max(DosimeterCounts(:, 1))])
  set(gca, 'Xticklabel', []);
  set(sp1, 'Position', [left, bottom(1), width, height]); 

  sp2 = subplot(5, 1, 2); 
  plot(time, DosimeterCounts(:, 2), 'g.')
  sp2.XTick = xtickSValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
  ylim([min(DosimeterCounts(:, 2)) max(DosimeterCounts(:, 2))])
  set(gca, 'Xticklabel', []);
  set(sp2, 'Position', [left, bottom(2), width, height]);

  sp3 = subplot(5, 1, 3);  
  plot(time, DosimeterCounts(:, 3), 'r.')
  sp3.XTick = xtickSValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 3', ...
      'FontSize', 15);
  ylim([min(DosimeterCounts(:, 3)) max(DosimeterCounts(:, 3))])
  set(gca, 'Xticklabel', []);
  set(sp3, 'Position', [left, bottom(3), width, height]);

  sp4 = subplot(5, 1, 4);
  plot(time, DosimeterCounts(:, 4), 'cyan.')
  sp4.XTick = xtickSValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 4', ...
      'FontSize', 15);
  ylim([min(DosimeterCounts(:, 4)) max(DosimeterCounts(:, 4))])
  set(gca, 'Xticklabel', []);
  set(sp4, 'Position', [left, bottom(4), width, height]);

  sp5 = subplot(5, 1, 5);
  plot(temperatureData, 'black.')
  ylabel('Counts');
  xlim([0 numEvents]);
  sp5.XTick = xtickSValues;
  sp5.XTickLabel = xtickLabels;
  xlabel('UTC Time (Hours)')
  ylim([min(temperatureData) max(temperatureData)])
  text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Temperature', ...
      'FontSize', 15);
  set(sp5, 'Position', [left, bottom(5), width, height]);

  %Make the plot title for the figure.
  sgtitle(titleStr);

  %Save the spectra to a file.
  saveas(fig1, DosimeterFileName);


  %Now make a comparison of channels 1 and 2.
  fig2 = figure('DefaultAxesFontSize', 12);
  fig2.Position = [750 25 1200 700];

  channel1 = DosimeterCounts(:, 1);
  channel2 = DosimeterCounts(:, 2);
 
  normalizedChannel1 = (channel1 - min(channel1)) / (max(channel1) - min(channel1));
  normalizedChannel2 = (channel2 - min(channel2)) / (max(channel2) - min(channel2));

  sp1 = subplot(2, 1, 1);
  plot(time, normalizedChannel1, 'b.', time, normalizedChannel2, 'g.')
  xlabel('UTC Time (Hours)')
  ylabel('Normalized Counts')
  legend({'Channel 1', 'Channel 2'})
  title(['Dosimeter Channels Versus time ', d, ' ', e])

  sp2 = subplot(2, 1, 2);
  plot(normalizedChannel1, normalizedChannel2, 'b.');
  hold on 
  plot([0, 1], [0, 1], 'black');
  xlabel('Channel 1');
  ylabel('Channel 2');
  title('Normalized Channel 2 Versus Normalized Channel 1');

  %Save the spectra to a file.
  saveas(fig2, DosimeterFileName1);



end
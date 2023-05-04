function makeDoseTempPlots(dataAttributes, rawTempData, rawDoseData, info)
    
%This function is called by FalconDosimeterTemp.m

%Generate the output file name.
OutFilename = [info.plotDir, 'Dosimeter/', 'STPSat-6_Falcon_Dose_Temp', ...
    info.yearStr, info.monthStr, ...
    info.dayOfMonthStr, '_', info.dayOfYearStr, '.png'];
  
OutFileName1 = [info.plotDir, 'Dosimeter/', 'STPSat-6_Falcon_Dose_Temp', ...
    info.yearStr, info.monthStr, ...
    info.dayOfMonthStr, '_', info.dayOfYearStr, '_Compare.png'];

  DosimeterCounts = rawDoseData.DOSEData;
  time = rawDoseData.DOSETime;
  temperatureData = rawTempData.TEMPData;

  %Determine a value for which all data values are greater are not plotted.
  c = -1/(sqrt(2)*erfcinv(3/2));
  dosimeterMaxPlotValue1 =  3.0*c*median(abs(DosimeterCounts(:, 1) - ...
      median(DosimeterCounts(:, 1))));
  dosimeterMaxPlotValue2 =  3.0*c*median(abs(DosimeterCounts(:, 2) - ...
      median(DosimeterCounts(:, 2))));

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

%  DosimeterFileName = strcat(plotDirStr, 'Dosimeter/', saveName, '.png');


  %Set the figure width and height and x position.
  left = 0.1;
  width = 0.8;
  height = 0.15;
  bottom = [0.78, 0.62, 0.46, 0.30, 0.14];

  fig1 = figure('DefaultAxesFontSize', 12);
  fig1.Position = [750 25 1200 700];

  %Set up a vector of values to be used in the xticks plot function.
  xtickValues = (numEvents/24)*[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
  xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
      ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};

  sp1 = subplot(5, 1, 1); 
  plot(time, DosimeterCounts(:, 1), 'b.')
  sp1.XTick = xtickValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
  if(dosimeterMaxPlotValue1 > min(DosimeterCounts(:, 1)))
      ylim([min(DosimeterCounts(:, 1)) dosimeterMaxPlotValue1])
  end
  ylim([min(DosimeterCounts(:, 1)) dosimeterMaxPlotValue1])
  set(gca, 'Xticklabel', []);
  set(sp1, 'Position', [left, bottom(1), width, height]); 

  sp2 = subplot(5, 1, 2); 
  plot(time, DosimeterCounts(:, 2), 'g.')
  sp2.XTick = xtickValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 2', ...
      'FontSize', 15);
  if(dosimeterMaxPlotValue2 > min(DosimeterCounts(:, 2)))
      ylim([min(DosimeterCounts(:, 2)) dosimeterMaxPlotValue2])
  end
  set(gca, 'Xticklabel', []);
  set(sp2, 'Position', [left, bottom(2), width, height]);

  sp3 = subplot(5, 1, 3);  
  plot(time, DosimeterCounts(:, 3), 'r.')
  sp3.XTick = xtickValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 3', ...
      'FontSize', 15);
  if(300 > min(DosimeterCounts(:, 3)))
      ylim([min(DosimeterCounts(:, 3)) 300])
  end
  set(gca, 'Xticklabel', []);
  set(sp3, 'Position', [left, bottom(3), width, height]);

  sp4 = subplot(5, 1, 4);
  plot(time, DosimeterCounts(:, 4), 'cyan.')
  sp4.XTick = xtickValues;
  ylabel('Counts');
  text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Channel 4', ...
      'FontSize', 15);
  if(300 > min(DosimeterCounts(:, 4)))
      ylim([min(DosimeterCounts(:, 4)) 300])
  end
  set(gca, 'Xticklabel', []);
  set(sp4, 'Position', [left, bottom(4), width, height]);

  sp5 = subplot(5, 1, 5);
  plot(temperatureData, 'black.')
  ylabel('Counts');
  xlim([0 numEvents]);
  sp5.XTick = xtickValues;
  sp5.XTickLabel = xtickLabels;
  xlabel('UTC Time (Hours)')
  if (max(temperatureData) > min(temperatureData))
      ylim([min(temperatureData) max(temperatureData)])
  end
  text('Units', 'Normalized', 'Position', [0.1, 0.8], 'string', 'Temperature', ...
      'FontSize', 15);
  set(sp5, 'Position', [left, bottom(5), width, height]);

  %Make the plot title for the figure.
  sgtitle(titleStr);

  %Save the spectra to a file.
  saveas(fig1, OutFilename);


  %Now make a comparison of channels 1 and 2.
  fig2 = figure('DefaultAxesFontSize', 12);
  fig2.Position = [750 25 1200 700];

  channel1 = DosimeterCounts(:, 1);
  channel2 = DosimeterCounts(:, 2);
 
  normalizedChannel1 = (channel1 - min(channel1)) / (max(channel1) - min(channel1));
  normalizedChannel2 = (channel2 - min(channel2)) / (max(channel2) - min(channel2));

  sp1 = subplot(2, 1, 1);
  plot(normalizedChannel1, 'b.')
  hold on
  plot(normalizedChannel2, 'g.')
  xlabel('UTC Time (Hours)')
  ylabel('Normalized Counts')
  legend({'Channel 1', 'Channel 2'})
  title(['Dosimeter Channels Versus time ', d, ' ', e])
  sp1.XTick = xtickValues;
  sp1.XTickLabel = xtickLabels;


  sp2 = subplot(2, 1, 2);
  plot(normalizedChannel1, normalizedChannel2, 'b.');
  hold on 
  plot([0, 1], [0, 1], 'black');
  xlabel('Channel 1');
  ylabel('Channel 2');
  title('Normalized Channel 2 Versus Normalized Channel 1');

  %Save the spectra to a file.
  saveas(fig2, OutFileName1);





end  %End of the function makeDoseTempPlots.m
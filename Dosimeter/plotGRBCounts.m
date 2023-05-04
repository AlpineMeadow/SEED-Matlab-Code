function plotGRBCounts(info, rawTime, rawCounts)


%Set the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];
ax = axes(fig1);

%Generate a plot name.
plotName1 = 'DosimeterSummaryGRBChannel1_';
plotName2 = 'DosimeterDataCoverageGRBChannel1_';


%Create an outfile name.  If the time span is more than a year handle that
%specially.
outFilename1 = [info.dosimeterPlotDir, 'Summary/Channel1/', plotName1, info.startYearStr, ...
	info.startMonthStr, info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_.png'];
outFilename2 = [info.dosimeterPlotDir, 'Summary/Channel1/', plotName2, info.startYearStr, ...
	info.startMonthStr, info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_.png'];

dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr];


%Set up some daily variables.
xtit = 'Time (UTC)';

%Set up some plotting variables.
Spacecraft = " Differenced ";
Instrument = "SEED";
plotType = "Dosimeter Counts";

%Generate a plot title
titStr = Spacecraft + " " + Instrument + " " + plotType + " " + dateStr + " " + info.startDayOfYearStr;
    
titStr2 = "DataCoverage" + " " + Instrument + " " + plotType + " " + dateStr + " " + info.startDayOfYearStr

[UTCTime, UTCCounts] = setUTCTime(info, rawTime, rawCounts);

eventHour = 13;
eventMinute = 21;
eventSecond = 0.0;
eventTimeStart = eventHour*3600 + eventMinute*60 + eventSecond;
eventTimeEnd = eventHour*3600 + eventMinute*60 + eventSecond + 60;

eventIndexMinute = find(UTCTime > eventTimeStart & UTCTime < eventTimeEnd);

diffCountsEventMinute = [0; diff(UTCCounts(eventIndexMinute, 1))];


event5Minutes = eventMinute - 2.5;
event5Second = 0.0;

event5TimeStart = eventHour*3600 + (eventMinute - 2.5)*60 + eventSecond;
event5TimeEnd = eventHour*3600 + (eventMinute + 2.5)*60 + eventSecond;
eventIndex5Minute = find(UTCTime > event5TimeStart & UTCTime < event5TimeEnd);

diffCountsEvent5Minute = [0; diff(UTCCounts(eventIndex5Minute, 1))];


%The locations of starting minutes are not uniformly distributed.  This
%means that I will have to brute force the effort to find the correct x
%tick values.
xtick1Start = eventHour*3600 + 18*60 + eventSecond;
xtick1Index = find(UTCTime > xtick1Start);
xtick1 = UTCTime(xtick1Index(1));

xtick2Start = eventHour*3600 + 19*60 + eventSecond;
xtick2Index = find(UTCTime > xtick2Start);
xtick2 = UTCTime(xtick2Index(1));

xtick3Start = eventHour*3600 + 20*60 + eventSecond;
xtick3Index = find(UTCTime > xtick3Start);
xtick3 = UTCTime(xtick3Index(1));

xtick4Start = eventHour*3600 + 21*60 + eventSecond;
xtick4Index = find(UTCTime > xtick4Start);
xtick4 = UTCTime(xtick4Index(1));

xtick5Start = eventHour*3600 + 22*60 + eventSecond;
xtick5Index = find(UTCTime > xtick5Start);
xtick5 = UTCTime(xtick5Index(1));

xtick6Start = eventHour*3600 + 23*60 + eventSecond;
xtick6Index = find(UTCTime > xtick6Start);
xtick6 = UTCTime(xtick6Index(1));

xtick7Start = eventHour*3600 + 24*60 + eventSecond;
xtick7Index = find(UTCTime > xtick7Start);
xtick7 = UTCTime(xtick7Index(1));

xtickValues = [xtick1, xtick2, xtick3, xtick4, xtick5, xtick6, xtick7];
xtickLabels = {'13:18', '13:19', '13:20', '13:21', '13:22', '13:23', '13:24'};


plot(UTCTime(eventIndex5Minute), diffCountsEvent5Minute, 'b', UTCTime(eventIndexMinute), diffCountsEventMinute, 'g')
title(titStr)
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.5, 0.65], 'string', 'Gamma Ray Burst', ...
      'FontSize', 15);
set(gca, 'XtickLabel', xtickLabels);
set(gca, 'XTick', xtickValues);
ylabel('Counts')
xlabel(xtit)
xlim([UTCTime(eventIndex5Minute(1)) UTCTime(eventIndex5Minute(end))])
	
x = [0.54 0.57];
y = [0.61 0.58];
annotation('textarrow',x,y, 'FontSize',13,'Linewidth',2)

%Plot a horizontal line at zero.
hold on 
plot([UTCTime(eventIndex5Minute(1)), UTCTime(eventIndex5Minute(end))], [0, 0], 'black')

%Save the plot to a file.  
saveas(fig1, outFilename1);




%Set the figure handle.
fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 700];
ax2 = axes(fig2);


plot(1:120, ones(1, 120), 'b', UTCTime(xtick3Index(1:120)) - 13*3600 - 20*60, ones(1, 120), 'ro')
title(titStr2)
text('Units', 'Normalized', 'Position', [0.1, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.05, 0.8], 'string', '13:20 - 13:22 UTC', ...
      'FontSize', 15);

ylabel('Arbitrary Counts')
xlim([0 120])
xlabel('Time (UTC seconds)')
legend('Seconds', 'Data Coverage')	

%Save the plot to a file.  
saveas(fig2, outFilename2);



end
function plotYearToDateDose(info, totalDosePerDay, dailyDose, dailyDoseRate, ...
    UTCTime, numTimeEventsPerDay, includedDays)

%This function will produce plots of the dosimeter data.
%This function is called by Dosimeter2.m.

%The structure dailyDose contains the 4 channels of the dosimeter.  Each
%channel holds a time series of the dose for every reset/rollover.
%Typically there are 72+ of these values per day.

%The structure totalDosePerDay contains the 4 channels of the dosimeter.  
%Each channel contains the total dose of each day.

%We want to find day numbers that correspond to the middle of each month.
%Determine the number of months.
numMonths = 12*(info.endYear - info.startYear) + info.endMonth - info.startMonth + 1;

%Set up the xTickValues array.
xTickValues = zeros(1, numMonths);

%Loop over the months.
for i = info.startMonth : info.endMonth
    if i == 11
        monthNum = datenum(info.startYear, 11, 5, 0, 0, 0);
    else
        monthNum = datenum(info.startYear, i, 15, 0, 0, 0);
    end

    monthIndex = find(dailyDose.dayNumbers1 >= monthNum);
    xTickValues(i) = dailyDose.dayNumbers1(monthIndex(1));
end

plotName = 'DosimeterSummary_';

%Create an outfile name.  If the time span is more than a year handle that
%specially.
if(info.startYear == info.endYear)
    outFilename1 = [info.dosimeterPlotDir, plotName, info.startYearStr, ...
        '_', info.startDayOfYearStr, '-', info.endDayOfYearStr, 'Original_.png'];
    outFilename2 = [info.dosimeterPlotDir, plotName, info.startYearStr, ...
        '_', info.startDayOfYearStr, '-', info.endDayOfYearStr, 'Revised_.png'];


    dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr, ...
        ' - ', info.endYearStr '/', info.endMonthStr, '/', info.endDayOfMonthStr];
else
    outFilename = [info.dosimeterPlotDir, plotName, info.startYearStr, '-', ...
        info.startDayOfYearStr, '_', info.endYearStr, '-', info.endDayOfYearStr, '_.png'];
    dateStr = [info.startYearStr, '/', info.startMonthStr, '/', info.startDayOfMonthStr, ...
        ' - ', info.endYearStr, '/', info.endMonthStr, '/', info.endDayOfMonthStr]
end

%Set up some variables for the number of events in each channel.
numEvents1 = length(dailyDose.channel1);
numEvents2 = length(dailyDose.channel2);
numEvents3 = length(dailyDose.channel3);
numEvents4 = length(dailyDose.channel4);


%Set up some daily variables.
if (info.endDayOfYear - info.startDayOfYear == 0) 
    xtit = 'Time (hours)';

    %Set up a vector of values to be used in the xticks plot function.
%    xtickValues = (numEvents1/24)*[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24];
    xtickLabels = {'0', ' ', '2', ' ', '4', ' ', '6', ' ', '8', ' ', '10', ...
        ' ', '12', ' ', '14', ' ', '16', ' ', '18', ' ', '20', ' ', '22', ' ', '24'};
    JulianDay = info.startDayOfYearStr;
    XTickLabelRotationValue = 0;
end

%Set up some month variables.
if (info.endDayOfYear - info.startDayOfYear <= 31) 
    xtit = 'Time (days)';
    
    %Set up a vector of values to be used in the xticks plot function.
%    xtickValues = (numEvents1/15)*[1 3 5 7 9 11 13 15 17 19 21 23 25 27 29];
    xtickLabels = {'1', '3', '5', '7', '9', '11', '13', '15', '17', '19', '21', ...
        '23', '25', '27', '29'};
    JulianDay = [info.startDayOfYearStr, '-', info.endDayOfYearStr];
    XTickLabelRotationValue = 0;
end

%Set up some year variables.
if (info.endDayOfYear - info.startDayOfYear > 31)
    xtit = 'Time (Months)';
%    xTickValues = zeros(1, 12);

    %Set up a vector of values to be used in the xticks plot function.
    dayOfYearPerMonth = [15 45 75 106 136 167 197 228 259 289 320 350];
%    for i = 1 : 12
%        xTickValues(i) = datenum(info.startYear, 0, i);
%    end

    xTickLabels = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', ...
        'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
    JulianDay = [info.startDayOfYearStr, '-', info.endDayOfYearStr];
    XTickLabelRotationValue = 90;   
end

%Set up some plotting variables.
Spacecraft = " Daily Falcon";
Instrument = "SEED";
plotType = "Dosimeter Dose";

%Generate a plot title
titStr = Spacecraft + " " + Instrument + " " + plotType + " " + dateStr + " " + JulianDay;

    
%Set the figure width and height and x position.  
left = 0.1;
width = 0.8;
height = 0.25;
bottom = [0.71, 0.42, 0.08];

%Set the figure handle.
fig1 = figure('DefaultAxesFontSize', 12);
fig1.Position = [750 25 1200 700];
ax1 = axes(fig1);
ax1.XTickLabelRotation = XTickLabelRotationValue;

%Determine the mean monthly dose for each channel.
[monthlyMeanDose1, monthlyMeanDose2,monthlyMeanDose3, monthlyMeanDose4] = ... 
    getMeanMonthlyDose(info, numMonths, totalDosePerDay, includedDays);


%Lets find the cumulative dose.
cumulativeDose1 = getCumulativeDose(numEvents1, dailyDose.channel1);
cumulativeDose2 = getCumulativeDose(numEvents2, dailyDose.channel2);
cumulativeDose3 = getCumulativeDose(numEvents3, dailyDose.channel3);
cumulativeDose4 = getCumulativeDose(numEvents4, dailyDose.channel4);


dayNum139 = datenum(info.startYear, 0, 130, 0, 0, 0);
dayNum229 = datenum(info.startYear, 0, 229, 0, 0, 0);

%Find the average data that corresponds to the times before and after the
%spacecraft non-reset problems.
goodEarlyIndex = find(dailyDose.dayNumbers1 < dayNum139);
goodLateIndex = find(dailyDose.dayNumbers1 > dayNum229);
badMiddleIndex = find(dailyDose.dayNumbers1 >= dayNum139 & ...
    dailyDose.dayNumbers1 <= dayNum229);
meanEarlyData = mean(dailyDose.channel1(goodEarlyIndex));
meanLateData = mean(dailyDose.channel1(goodLateIndex));

%Now we cannot really replace this data but we can use the average to
%calculate the total cumulative dose.
averageDailyDose1 = dailyDose.channel1;
averageDailyDose1(badMiddleIndex) = meanEarlyData;


%Given that we have replaced the bad data, we can calculate the cumulative
%dose.
cumulativeDose = zeros(1, numEvents1);

for i = 1 : numEvents1
    if (i == 1) 
        cumulativeDose(i) = averageDailyDose1(i);
    else
        cumulativeDose(i) = cumulativeDose(i - 1) + averageDailyDose1(i);
    end
end  %End of for loop - for i = 1 : numEvents

%Now recalculate the monthly mean dose.
monthlyMeanDoseCheck = zeros(1, numMonths);

%We need to get the data into monthly values.
dayMonthStartIndex = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
dayMonthEndIndex = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

for i = info.startMonth : info.startMonth + numMonths - 1
    startMonth = datenum(info.startYear, 0, dayMonthStartIndex(i), 0, 0, 0);
    endMonth = datenum(info.startYear, 0, dayMonthEndIndex(i), 23, 59, 59);
    
    dayIndex = find(dailyDose.dayNumbers1 >= startMonth & ...
        dailyDose.dayNumbers1 <= endMonth);
       
    monthlyMeanDoseCheck(i) = sum(averageDailyDose1(dayIndex));

end  %End of for loop - for i = 1 : numMonths



%Make the plots.
sp1 = subplot(3, 1, 1);
plot(dailyDose.dayNumbers1, dailyDose.channel1, 'b', dailyDose.dayNumbers1, ...
    averageDailyDose1, 'g')
xticks(xTickValues)
datetick('x', 'mmm', 'keepticks')
title(titStr)
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Daily Value', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.25, 0.7], 'string', 'Start No Reset', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.74, 0.7], 'string', 'End No Reset', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.05, 0.8], 'string', 'Original Data', ...
      'FontSize', 15, 'Color', 'b');
text('Units', 'Normalized', 'Position', [0.05, 0.7], 'string', 'Revised Data', ...
      'FontSize', 15, 'Color', 'g');
ylabel('Daily Dose (Rad)')
ylim([0 5])
set(sp1, 'Position', [left, bottom(1), width, height]);
hold on
plot([dayNum139, dayNum139], [0, 20], 'r-', [dayNum229, dayNum229], ...
    [0, 20], 'r-', 'LineWidth', 3)


sp2 = subplot(3, 1, 2);
plot(dailyDose.dayNumbers1, cumulativeDose1, 'b', dailyDose.dayNumbers1, ...
    cumulativeDose, 'g')
xticks(xTickValues)
datetick('x', 'mmm', 'keepticks')
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.15], 'string', 'Cumulative Dose', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.05, 0.8], 'string', 'Original Data', ...
      'FontSize', 15, 'Color', 'b');
text('Units', 'Normalized', 'Position', [0.05, 0.7], 'string', 'Revised Data', ...
      'FontSize', 15, 'Color', 'g');
ylabel('Dose (Rad)')
xlabel(xtit)
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(3, 1, 3);
X = categorical({'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'});
X = reordercats(X, {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'});
bar(X, monthlyMeanDoseCheck, 'g')
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Monthly Average', ...
      'FontSize', 15);
%text('Units', 'Normalized', 'Position', [0.05, 0.8], 'string', 'Original Data', ...
%      'FontSize', 15, 'Color', 'b');
text('Units', 'Normalized', 'Position', [0.05, 0.7], 'string', 'Revised Data', ...
      'FontSize', 15, 'Color', 'g');
ylabel('Average Daily Dose (Rad)')
set(sp3, 'Position', [left, bottom(3), width, height]);

%Save the plot to a file.  
saveas(fig1, outFilename1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set the figure handle.
fig2 = figure('DefaultAxesFontSize', 12);
fig2.Position = [750 25 1200 700];
ax2 = axes(fig2);
ax2.XTickLabelRotation = XTickLabelRotationValue;


sp1 = subplot(3, 1, 1);
plot(dailyDose.dayNumbers1, averageDailyDose1, 'g')
xticks(xTickValues)
datetick('x', 'mmm', 'keepticks')
title(titStr)
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Daily Value', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.25, 0.7], 'string', 'Start No Reset', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.74, 0.7], 'string', 'End No Reset', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.05, 0.7], 'string', 'Revised Data', ...
      'FontSize', 15, 'Color', 'g');
ylabel('Daily Dose (Rad)')
set(sp1, 'Position', [left, bottom(1), width, height]);
hold on
plot([dayNum139, dayNum139], [0, 15], 'r-', [dayNum229, dayNum229], ...
    [0, 15], 'r-', 'LineWidth', 3)

sp2 = subplot(3, 1, 2);
plot(dailyDose.dayNumbers1, cumulativeDose, 'g')
xticks(xTickValues)
datetick('x', 'mmm', 'keepticks')
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.15], 'string', 'Cumulative Dose', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.05, 0.7], 'string', 'Revised Data', ...
      'FontSize', 15, 'Color', 'g');
ylabel('Dose (Rad)')
xlabel(xtit)
set(sp2, 'Position', [left, bottom(2), width, height]);

sp3 = subplot(3, 1, 3);
X = categorical({'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'});
X = reordercats(X, {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'});
bar(X, monthlyMeanDoseCheck, 'g')
text('Units', 'Normalized', 'Position', [0.05, 0.9], 'string', 'Channel 1', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.8, 0.9], 'string', 'Monthly Average', ...
      'FontSize', 15);
text('Units', 'Normalized', 'Position', [0.05, 0.7], 'string', 'Revised Data', ...
      'FontSize', 15, 'Color', 'g');
ylabel('Average Daily Dose (Rad)')
set(sp3, 'Position', [left, bottom(3), width, height]);




%Save the plot to a file.  
saveas(fig2, outFilename2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now save the data to a netcdf file.


%First we get the correct time out of the datenum values.
dd = datetime(dailyDose.dayNumbers1, 'ConvertFrom', 'datenum', 'Format', ...
    'yyyy, MM, d, HH, mm, ss');
years = dd.Year;
months = dd.Month;
days = dd.Day;
hours = dd.Hour;
minutes = dd.Minute;
seconds = dd.Second;

%Get the number of instances for the dosimeter.
numDoseInstances = length(averageDailyDose1);

fname = ['LosAlamos_netcdf_20220305_064.nc'];
       
%Generate the filename of the netcdf file that will be output.
fileName = [info.dosimeterRootDir, fname];

%Get the Level 1 ID.
L1ID = netcdf.create(fileName, 'CLOBBER');

%Define the data dimensions.
DosimeterTimeDimID = netcdf.defDim(L1ID, 'DOSIMETER_TIME', numDoseInstances);
DosimeterMonthDimID = netcdf.defDim(L1ID, 'MONTHLY_VALUES', 11);

%Define the dosimeter data variables.
DosimeterYearDataID = netcdf.defVar(L1ID, 'Dosimeter_Year', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterMonthDataID = netcdf.defVar(L1ID, 'Dosimeter_Month', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterDayDataID = netcdf.defVar(L1ID, 'Dosimeter_Day', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterHourDataID = netcdf.defVar(L1ID, 'Dosimeter_Hour', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterMinuteDataID = netcdf.defVar(L1ID, 'Dosimeter_Minute', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterSecondDataID = netcdf.defVar(L1ID, 'Dosimeter_Second', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterCumulativeDoseID = netcdf.defVar(L1ID, 'Dosimeter_Cumulative_Dose', 'NC_DOUBLE', DosimeterTimeDimID);   
DosimeterAverageDailyDoseID = netcdf.defVar(L1ID, 'Dosimeter_Average_Daily_Dose', 'NC_DOUBLE', DosimeterTimeDimID);
DosimeterMonthlyMeanDoseID = netcdf.defVar(L1ID, 'Dosimeter_Monthly_Mean_Dose', 'NC_DOUBLE', DosimeterMonthDimID);

%Define the various attributes.                    
varid = netcdf.getConstant('GLOBAL');

%Add the various data attributes to the file.   
netcdf.putAtt(L1ID,varid,'Dosimeter_Dose_Units', 'Rads'); 
netcdf.putAtt(L1ID,varid,'Dosimeter_Time_Units', 'UTC');

netcdf.putAtt(L1ID,varid,'Start_Day_Of_Year', num2str(info.startDayOfYear,'%03d'));                    
netcdf.putAtt(L1ID,varid,'End_Day_Of_Year', num2str(info.endDayOfYear,'%03d')); 
netcdf.putAtt(L1ID,varid,'Start_date',datestr(datetime(info.startYear, ...
    info.startMonth, info.startDayOfMonth,'Format', 'yyyy-MM-dd')));                    
netcdf.putAtt(L1ID,varid,'End_date',datestr(datetime(info.endYear, ...
    info.endMonth, info.endDayOfMonth,'Format', 'yyyy-MM-dd')));                    
   
%End definitions.
netcdf.endDef(L1ID);

%Now put the data into the file.
netcdf.putVar(L1ID, DosimeterYearDataID, years);
netcdf.putVar(L1ID, DosimeterMonthDataID, months);
netcdf.putVar(L1ID, DosimeterDayDataID, days);
netcdf.putVar(L1ID, DosimeterHourDataID, hours);
netcdf.putVar(L1ID, DosimeterMinuteDataID, minutes);
netcdf.putVar(L1ID, DosimeterSecondDataID, seconds);

netcdf.putVar(L1ID, DosimeterMonthlyMeanDoseID, monthlyMeanDoseCheck);
netcdf.putVar(L1ID, DosimeterCumulativeDoseID, cumulativeDose);
netcdf.putVar(L1ID, DosimeterAverageDailyDoseID, averageDailyDose1);


%Close the file
netcdf.close(L1ID);

end  %End of the function plotYearToDateDose.m
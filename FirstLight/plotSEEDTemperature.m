function plotSEEDTemperature(info, CDFInfo, CDFData)

%This function will plot the SEED temperature data for the period of
%interest.  This is called by SEEDFirstLight.m

%Join all of the temperature data together.
T = vertcat(CDFData.SEED_Temperature);
Time = vertcat(CDFData.SEED_Dosimeter_Time);

%Get rid of all of the bad data points.
Temperature = T;
Temperature(Temperature > 80 | Temperature < 30) = 50;


%Set up some plotting variables.
satellite = "Falcon";
instrument = "SEED";
plotType = "Instument Temperature ";
dateStr = '2022 - 2023';

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr;

saveName = satellite + instrument + "_TemperatureSummary" + "_2022 - 2023";

tempSummaryFileName = strcat('/SS1/STPSat-6/Plots/Summary/', saveName, '.png');


%Set up a vector of mission day numbers.  This is specific for the first
%450 days of the mission.  Richard wanted this plot.
dayNums = 15:15:465;
dayNumsLength = length(dayNums);

%Set the hours, minutes and seconds.
hh = 0;
mm = 0;
ss = 0;

%Now create a set of x tick values for the plotting.
xTicks = zeros(1, dayNumsLength);
for i = 1 : dayNumsLength

    %Determine the year, month and day of month.
    [year, month, dayOfMonth] = MDNToMonthDay(dayNums(i));

    xTicks(i) = datenum(year, month, dayOfMonth, hh, mm, ss);
end  %End of for loop - for i = 1 : daysNumsLength

%Make the tick labels.
xTickLabels = {xTicks};

%Generate a figure.
fig1 = figure();
fig1.Position = [750 25 1200 500];
dateFormat = 2;

p = plot(Time, Temperature, 'b');
xticks(xTicks)
xticklabels(xTickLabels)
datetick('x', dateFormat, 'keeplimits', 'keepticks')
title(titStr);
ylim([30 100])
xlim([xTicks(1) xTicks(end)])
ylabel('Temperature (^{\circ}C)')
xlabel('Date')

%Save the time series to a file.
saveas(fig1, tempSummaryFileName);

end  %End of the function plotSEEDTemperature.m
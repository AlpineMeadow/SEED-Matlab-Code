%This script will input the temperature data for the entire mission and
%make a histogram of the temperature values.

%Clear all the variables.
clearvars;

%Close any open files.
fclose('all');

%Close any open plot windows.
close all;

%Set the starting and ending day of year as well as the year itself.
startDoy = 16;
endDoy = 220;
year = 2022;

outFilename = ['/SS1/STPSat-6/Plots/Temperature/AllTemp_', num2str(year), ...
    '_', num2str(startDoy, '%03d'), '-' num2str(endDoy, '%03d'), '_.png'];

%Loop through the days of year.
for doy = startDoy : endDoy

    %Generate the file name for the data to be analyzed.
    PathName = ['/SS1/STPSat-6/Temperature/', num2str(year), '/L1/DayOfYear_', num2str(doy, '%03d'), '/'];
    month = datestr(doy2date(doy, year), 'mm');
    day = datestr(doy2date(doy, year), 'dd');
    doyStr = num2str(doy, '%03d');

    %Generate the file names.
    L1File = ['STPSat-6_FalconTEMP_2022', month, day, '_', doyStr, '_L1.nc'];   
    fileName = [PathName, L1File];

    if exist(fileName) == 2
        %Get the data.
        [~, ~, rawData] = getNETCDFData(fileName);

         %Handle the first file separately.
         if (doy == startDoy) 
           % rawData.TEMPTime holds the time and
           % rawData.TEMPData holds the temperature data 
           rawTime = rawData.TEMPTime;
           rawTemp = rawData.TEMPData;
           xvalues = length(rawTime);
           xdays = doy;
         else

           %Append the data onto the arrays.
           rawTime = cat(1, rawTime, rawData.TEMPTime);
           rawTemp = cat(1, rawTemp, rawData.TEMPData);
           xvalues = cat(1, xvalues, length(rawTime) + length(xvalues));
           xdays = cat(1, xdays, doy);
         end %End of if-else clause - if (doy == startDoy)
 
    else
        disp(['The file :', fileName, ' does not exist.  Skipping'])
    end  %End of if-else statement - if exist(fileName) == 2



end  %End of for loop - for doy = startDoy : endDoy

%Generate a histogram of the counts.

%Set the title.
titStr = {'Histogram of Counts For Spacecraft Temperature For', ...
    ['Julian Days ', num2str(startDoy), ' - ', num2str(endDoy) ' ', num2str(year)]};

%Set the number of bins to portion the data into.
nbins = 100;

%There are some anamolous counts, so just set them to 100.  
Temp = rawTemp;
Temp(Temp > 100) = 100;


%Set up a vector of values to be used in the xticks plot function.
numEvents = length(rawTime);


%Lets set the time to start from 0 and also be fractions of seconds.
time = (rawTime - rawTime(1))/86400.0;

timeBins = startDoy : 1 : endDoy;
timeBinsStr = string(xdays);
%xtickValues = 1 : numEvents/length(timeBins) : numEvents;
xtickValues = xvalues';
xtickLabels = cellstr(timeBinsStr);

fig1 = figure('DefaultAxesFontSize', 12);
  fig1.Position = [750 25 1200 700];

%Make the histogram.
sp1 = subplot(2, 1, 1);
histogram(Temp, nbins);
title(titStr)
xlabel('Count Values')
ylabel('Number of Count Values')

sp2 = subplot(2, 1, 2); 
plot(rawTemp, 'b')
title('Temperature Counts Vs. Time')
ylabel('Counts');
xlabel('Time (days)')
sp2.XTick = xtickValues;
sp2.XTickLabel = xtickLabels;


%Save the spectra to a file.
saveas(fig1, outFilename);

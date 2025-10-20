function info = generateCDFInfomation(dayOfYear, year, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond);

%This function will be used to generate the information structure for both
%SEED and the Dosimeter and will be used for getSEEDCDFData.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info.startHour = startHour;
info.startHourStr = num2str(startHour, '%02d');
info.startMinute = startMinute;
info.startMinuteStr = num2str(startMinute, '%02d');
info.startSecond = startSecond;
info.startSecondStr = num2str(startSecond, '%02d');
info.endHour = endHour;
info.endHourStr = num2str(endHour, '%02d');
info.endMinute = endMinute;
info.endMinuteStr = num2str(endMinute, '%02d');
info.endSecond = endSecond;
info.endSecondStr = num2str(endSecond, '%02d');

%Take care of the year and day of year
info.startYear = year;
info.startYearStr = num2str(year);
info.startDayOfYear = dayOfYear;
info.startDayOfYearStr = num2str(dayOfYear, '%03d');

%Determine the month and day of month for each day of year.    
startDateVector = datevec(datenum(year, 0, dayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

info.startMonth = startMonth;
info.startMonthStr = num2str(startMonth, '%02d');
info.startDayOfMonth = startDayOfMonth;
info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');

%Lets write a month string.  Matlab has a way to do this
startMonthName = datestr(datetime(1, startMonth, 1), 'mmmm');
info.startMonthName = startMonthName;

%Generate a date string.
info.startDateStr = [info.startYearStr, info.startMonthStr, ...
    info.startDayOfMonthStr];

%Add in the epoch time data.
epochYear = 1980;
epochMonth = 1;
epochDayOfMonth = 6;
epochHour = 0;
epochMinute = 0;
epochSecond = 0.0;

info.epochYear = epochYear;
info.epochMonth = epochMonth;
info.epochDayOfMonth = epochDayOfMonth;
info.epochHour = epochHour;
info.epochMinute = epochMinute;
info.epochSecond = epochSecond;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%  Directory Information  %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info.dosimeterRootDir = '/SS1/STPSat-6/Dosimeter/';
info.dosimeterPlotDir = '/SS1/STPSat-6/Plots/Dosimeter/';
info.temperatureRootDir = '/SS1/STPSat-6/Temperature/';
info.temperaturePlotDir = '/SS1/STPSat-6/Plots/Temperature/';
info.SEEDRootDir = '/SS1/STPSat-6/SEED/';
info.SEEDPlotDir = '/SS1/STPSat-6/Plots/SEED/';
info.STPSat6RootDir = '/SS1/STPSat-6/';

end

function info = generateSEEDInformation(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber)


%This function is called by all of the analysis programs.

%Set out the starting day of year and year for the mission(that is, the
%time we started getting data).
firstLightYear = 2022;
firstLightDayOfYear = 15;
firstLightMonth = 1;
firstLightDayOfMonth = 15;

info.firstLightYear = firstLightYear;
info.firstLightDayOfYear = firstLightDayOfYear;
info.firstLightMonth = firstLightMonth;
info.firstLightDayOfMonth = firstLightDayOfMonth;

%Handle the CDF version number field.
info.CDFDataVersionNumber = CDFDataVersionNumber;

%The relevant values from the paper are :
%Channel 0(Our channel 1) : 1051.7 Counts/mRad = 1.0517e6 Counts/Rad.
%Channel 1(Our channel 2) : 4206.7 Counts/Rad.
%Channel 2(Our channel 3) : 16.1 Counts/Rad.
%Channel 3(Our channel 4) : 37.9 Counts/kRad = 3.79e-2 Counts/Rad.
%We believe that due to how the instrument was built that these values are
%not correct and have determined others.

%Let's make some conversion factors.  These values convert the counts into
%Rads.  These are determined from the data itself.
Channel1CountsToRads = 1.0/2.47919e6;
Channel2CountsToRads = 1.0/9916.78;
Channel3CountsToRads = 1.0/37.98;
Channel4CountsToRads = 1.0/8.925e-2;  %We will not be using this channel.

info.channel1CountsToRads = Channel1CountsToRads;
info.channel2CountsToRads = Channel2CountsToRads;
info.channel3CountsToRads = Channel3CountsToRads;
info.channel4CountsToRads = Channel4CountsToRads;


info.numEnergyBinsToSum = numEnergyBinsToSum;
info.startEnergyBinNumber = startEnergyBinNumber;

%Lets generate the energy bins.
energyBins = generateSEEDEnergyBins(startEnergyBinNumber, ...
    numEnergyBinsToSum);

%Set the energy bins into the info structure.
info.energyBins = energyBins;
info.deltaE = 0.1465*numEnergyBinsToSum;

%Determine the geometric factor.
g = getSEEDGeometricFactor(energyBins);

%Set the geometric factor into the info structure.
info.g = g;

%Set the sample time.  This is correct for both the SEED data as well as
%the Dosimeter data.
timeBinWidth = 1.0;  %Units are in seconds.
info.timeBinWidth = timeBinWidth;
info.numTimeStepsToSkip = numTimeStepsToSkip;

%Determine the time bin width.
deltaT = 0.5;  %Units are in seconds.
info.deltaT = deltaT;

%Determine the geometric factor width.
deltaG = 0.5e-6;  %Units are in cm^2 ster.
info.deltaG = deltaG;

%Get the starting and ending energies.
info.startEnergy = startEnergy;
info.endEnergy = endEnergy;

%Handle the directories.
info.dosimeterRootDir = '/SS1/STPSat-6/Dosimeter/';
info.dosimeterPlotDir = '/SS1/STPSat-6/Plots/Dosimeter/';
info.temperatureRootDir = '/SS1/STPSat-6/Temperature/';
info.temperaturePlotDir = '/SS1/STPSat-6/Plots/Temperature/';
info.SEEDRootDir = '/SS1/STPSat-6/';
info.SEEDPlotDir = '/SS1/STPSat-6/Plots/SEED/';

%Handle the times.
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
info.startYear = startYear;
info.startYearStr = num2str(startYear);
info.startDayOfYear = startDayOfYear;
info.startDayOfYearStr = num2str(startDayOfYear, '%03d');
info.endYear = endYear;
info.endYearStr = num2str(endYear);
info.endDayOfYear = endDayOfYear;
info.endDayOfYearStr = num2str(endDayOfYear, '%03d');

%Determine the month and day of month for each day of year.    
startDateVector = datevec(datenum(startYear, 0, startDayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);
endDateVector = datevec(datenum(endYear, 0, endDayOfYear));
endMonth = endDateVector(2);
endDayOfMonth = endDateVector(3);

info.startMonth = startMonth;
info.startMonthStr = num2str(startMonth, '%02d');
info.startDayOfMonth = startDayOfMonth;
info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');
info.endMonth = endMonth;
info.endMonthStr = num2str(endMonth, '%02d');
info.endDayOfMonth = endDayOfMonth;
info.endDayOfMonthStr = num2str(endDayOfMonth, '%02d');

%Generate a date string.
info.startDateStr = [info.startYearStr, info.startMonthStr, ...
    info.startDayOfMonthStr];
info.endDateStr = [info.endYearStr, info.endMonthStr, ...
    info.endDayOfMonthStr];

%Generate the starting and ending mission day numbers.
startMissionDayNumber = DNToMDN(startDayOfYear, startYear);
endMissionDayNumber = DNToMDN(endDayOfYear, endYear);
info.startMissionDayNumber = startMissionDayNumber;
info.endMissionDayNumber = endMissionDayNumber;

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

end  %end of function generateSEEDInformation.m
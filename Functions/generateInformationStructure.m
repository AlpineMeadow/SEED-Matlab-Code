function info = generateInformationStructure(startDayOfYear, startYear, ...
    endDayOfYear, endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber)

%This function will be used to generate the information structure for ALL 
%programs. 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%  Instrument Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

info.Instrument = 'FalconSEED';
info.Host = 'STPSat-6';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%  Dosimeter Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%We need to input the counts to rads conversion factors for each channel.
%The relevant values from the paper are :
%Channel 0(Our channel 1) : 1051.7 Counts/mRad = 1.0517e6 Counts/Rad.
%Channel 1(Our channel 2) : 4206.7 Counts/Rad.
%Channel 2(Our channel 3) : 16.1 Counts/Rad.
%Channel 3(Our channel 4) : 37.9 Counts/kRad = 3.79e-2 Counts/Rad.
%We believe that due to how the instrument was built that these values are
%not correct and have determined others.

%Let's make some conversion factors.  These values convert the counts into
%Rads.  These are determined from the data itself.
DosimeterChannel1CountsToRads = 1.0/2.47919e6;
DosimeterChannel2CountsToRads = 1.0/9916.78;
DosimeterChannel3CountsToRads = 1.0/37.98;
DosimeterChannel4CountsToRads = 1.0/8.925e-2;  %We will not be using this channel.

info.DosimeterChannel1CountsToRads = DosimeterChannel1CountsToRads;
info.DosimeterChannel2CountsToRads = DosimeterChannel2CountsToRads;
info.DosimeterChannel3CountsToRads = DosimeterChannel3CountsToRads;
info.DosimeterChannel4CountsToRads = DosimeterChannel4CountsToRads;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%  SEED Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info.numEnergyBinsToSum = numEnergyBinsToSum;
info.startEnergyBinNumber = startEnergyBinNumber;

%Let's generate the energy bins.
energyBins = generateSEEDEnergyBins(startEnergyBinNumber, ...
    numEnergyBinsToSum);

%Set the energy bins into the info structure.
info.energyBins = energyBins;
info.deltaE = 0.1465*numEnergyBinsToSum;

%Get the starting and ending energies.
info.startEnergy = startEnergy;
info.endEnergy = endEnergy;

%Determine the geometric factor.
g = getSEEDGeometricFactor(energyBins);

%Set the geometric factor into the info structure.
info.g = g;

%Determine the geometric factor width.
deltaG = 0.5e-6;  %Units are in cm^2 ster.
info.deltaG = deltaG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%  Time Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set the sample time.  This is correct for both the SEED data as well as
%the Dosimeter data.
timeBinWidth = 15.0;  %Units are in seconds.
info.timeBinWidth = timeBinWidth;
info.numTimeStepsToSkip = numTimeStepsToSkip;

%Determine the time bin width.
deltaT = 0.5;  %Units are in seconds.
info.deltaT = deltaT;

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%  Date Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%Lets write a month string.  Matlab has a way to do this
startMonthName = datestr(datetime(1, startMonth, 1), 'mmmm');
info.startMonthName = startMonthName;
endMonthName = datestr(datetime(1, endMonth, 1), 'mmmm');
info.endMonthName = endMonthName;

%Generate a date string.
info.startDateStr = [info.startYearStr, info.startMonthStr, ...
    info.startDayOfMonthStr];
info.endDateStr = [info.endYearStr, info.endMonthStr, ...
    info.endDayOfMonthStr];

%Set up the Mission day of year information.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%  NASA CDF Information  %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handle the CDF version number field.
info.CDFDataVersionNumber = CDFDataVersionNumber;

CDFMasterFilename = [info.STPSat6RootDir, 'CDF/', 'STPSat-6_SPDF.cdf'];
info.CDFMasterFilename = CDFMasterFilename;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%  Auxilliary Data Info  %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DstFilename = '/SS1/STPSat-6/AncillaryData/Dst/DstData20220101-20230301.txt';
info.DstFilename = DstFilename;

%Get the Dst index for a given set of days.  The inputs are start year,
%start day of year and start hour as well as the end year, end day of year
%and end hour.
DstIndex = getDstIndex(info, startYear, startDayOfYear, startHour, ...
    endYear, endDayOfYear, endHour);

info.DstIndex = DstIndex;


%Get the Kp and Ap indices.
KpApFilename = '/SS1/STPSat-6/AncillaryData/KpAp/KpApIndex20220101-20230404.txt';
info.KpApFilename = KpApFilename;

KpApIndex = getKpApIndex(info, startYear, startDayOfYear, startHour, ...
    endYear, endDayOfYear, endHour);
info.KpApIndex = KpApIndex;

%Get the ACE electron flux data.
%ACEElectronFlux = getACEElectronFlux(info, startYear, startDayOfYear, ...
%    startHour, endYear, endDayOfYear, endHour);
%info.ACEElectronFlux = ACEElectronFlux;

%Get the ACE Magnetic field data.
%ACEB = getACEB(info, startYear, startDayOfYear, startHour, ...
%    endYear, endDayOfYear, endHour);
%info.ACEB = ACEB;

% 
% AEFilename = '/SS1/STPSat-6/AncillaryData/AE/AEData20220101-20230301.txt';
% info.AEFilename = AEFilename;
% 
% %Get the AE index for the given set of days.  The inputs are start year,
% %start day of year and start hour as well as the end year, end day of year
% %and end hour.
% AEIndex = getAEIndex(info, startYear, startDayOfYear, startHour, ...
%     endYear, endDayOfYear, endHour);
% 
% info.AEIndex = AEIndex;


end %End of the function generateInformationStructure.m

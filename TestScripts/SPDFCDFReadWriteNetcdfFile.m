%This script will enable SPDF to read a netcdf file and output it as a cdf
%file.

%This script will experiment with how to write and read Common Data
%Format(CDF) files so that the SEED data can be uploaded to NASA's Space
%Physics Data Facility (SPDF).  There will be two functions, one to generate
%a CDF file and one to read the files.  Eventually these function will be
%used in other matlab code.

dbstop if error;

clearvars;
close all;
%fclose('all');

%Flag to either read or write data.
readWriteData = 'read';
readWriteData = 'write';

%Set the day of year and the year.
startDayOfYear = 139;
endDayOfYear = 139;
startYear = 2022;
endYear = 2022;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%The energy bin number at which to start the data analysis. This will give
%904 energy bins, which is the number of bins in the CDF file.
startEnergyBinNumber = 121;  
numEnergyBinsToSum = 1;  %The number of energy bins to sum.
numTimeBinsToSum = 1;  %The number of time bins to sum. This needs to remain set to 1.

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%We need to generate a variable that will contain the data version number
%for the CDF files.  This will be used for this program but not in others
%that use the info structure.  
CDFDataVersionNumber = 1;

%Generate a structure that holds all of the information needed to do the
%analysis.
info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber);

%Set the CDF filename.
masterFilenameCDF = [info.STPSat6RootDir, 'CDF/', 'STPSat-6_SPDF.cdf'];

%Now read or write the CDF file.
if strcmp(readWriteData, 'write')

    %Write a cdf file.
    [fullFilenameCDF, exportSuccessFlag, CDFVariableNames] = ...
        exportSEEDCDF(info);

    %Check to see if the write operation was successful.
    if exportSuccessFlag == 1
        disp(['The CDF file ', fullFilenameCDF, ...
            ' has successfully been written.'])
    else
        disp(['The CDF file ', fullFilenameCDF, ... 
            'was not successfully written.'])
    end  %End of if else clause - if exportSuccessFlag == 1
else 
    %Read a cdf file.  The times that are read in are converted to Matlab's
    %datenum time automatically.  
    [CDFInfo, CDFData] = importSEEDCDF(info);
end  %End of if statement - if readWriteData == 'write'



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%  generateInformationStructure %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber)

%This function will be used to generate the information structure for ALL 
%programs. 

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

%%%%%%%%%%%%%%%%%%%%%%%%  Auxilliary Data Info  %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DstFilename = '/SS1/STPSat-6/AncillaryData/Dst/DstData20220101-20230301.txt';
% info.DstFilename = DstFilename;
% 
% %Get the Dst index for a given set of days.  The inputs are start year,
% %start day of year and start hour as well as the end year, end day of year
% %and end hour.
% DstIndex = getDstIndex(info, startYear, startDayOfYear, startHour, ...
%     endYear, endDayOfYear, endHour);
% 
% info.DstIndex = DstIndex;
% 
% %Get the Kp and Ap indices.
% KpApFilename = '/SS1/STPSat-6/AncillaryData/KpAp/KpApIndex20220101-20230404.txt';
% info.KpApFilename = KpApFilename;
% 
% KpApIndex = getKpApIndex(info, startYear, startDayOfYear, startHour, ...
%     endYear, endDayOfYear, endHour);
% info.KpApIndex = KpApIndex;

end %End of the function generateInformationStructure.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  exportSEEDCDR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fullFilenameCDF, exportSuccessFlag, CDFVariableNames] = ...
    exportSEEDCDF(info)

%This function is called by SEEDCDF.m.  This function will read in netcdf
%file and output a CDF file.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Get the NASA CDF Data    %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get the master file information.
CDFInfo = spdfcdfinfo(info.CDFMasterFilename);

%Generate the cdf filename.
CDFFileName = ['STPSat-6_Falcon_SEED-L1_', info.startYearStr, ...
    info.startMonthStr, info.startDayOfMonthStr, '_v01.cdf'];

fullFilenameCDF = ['/SS1/STPSat-6/SEED/', info.startYearStr, ...
    '/L1/DayOfYear_', info.startDayOfYearStr, '/', CDFFileName];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Get the SEED Data    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate the file name for the data to be analyzed.
PathName = [info.SEEDRootDir, info.startYearStr, '/L1/DayOfYear_', ...
    info.startDayOfYearStr, '/'];        

%Generate the file name.
L1File = ['STPSat-6_FalconSEED_', info.startYearStr, info.startMonthStr, ...
    info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];
    
fileName = [PathName, L1File];

%First read in the netcdf file.
[SEEDDataAttributes, ~, rawSEEDData] = getNetCDFData(fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Get the Dosimeter Data    %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate the file name for the data to be analyzed.
PathName = [info.dosimeterRootDir, info.startYearStr, '/L1/DayOfYear_', ...
    info.startDayOfYearStr, '/'];

%Generate the file names.
L1File = ['STPSat-6_FalconDOSE_', info.startDateStr, '_', ...
    info.startDayOfYearStr, '_L1.nc'];
fileName = [PathName, L1File];

%Read in the dosimeter data.
[DosimeterDataAttributes, ~, rawDosimeterData] = ...
    getDosimeterNETCDFData(fileName);

%Make plots of the raw data.
%plotRawSEEDDoseData(info, rawSEEDData, rawDosimeterData);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Get the Temperature Data    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Generate the file name for the data to be analyzed.
PathName = [info.temperatureRootDir, info.startYearStr, '/L1/DayOfYear_', ...
    info.startDayOfYearStr, '/'];

%Generate the file names.
L1File = ['STPSat-6_FalconTEMP_', info.startDateStr, '_', ...
    info.startDayOfYearStr, '_L1.nc'];
fileName = [PathName, L1File];

%Read in the dosimeter data.
[TemperatureDataAttributes, ~, rawTemperatureData] = ...
    getNetCDFData(fileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Handle the TT2000 data      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate the TT2000 time intervals and corresponding counts.  The
%TT2000Time variable is valid for both SEED data and Dosimeter data at this
%time.  
[TT2000Time, UTCTime, TT2000SEEDCounts, TT2000DosimeterCounts, ...
    TT2000TempCounts] = generateTT2000(info, rawSEEDData.SEEDTime, ...
    rawSEEDData.SEEDData, rawDosimeterData.DOSEData, ...
    rawTemperatureData.TEMPData);

%Convert the Dosimeter counts to dose values.  This function also ensures
%that both counts and dose do not have negative values.  I also use this
%function to set the number of channels to be three.
[DosimeterCounts, DosimeterDose] = getCDFDosimeterCountsAndDose(info, ...
    TT2000DosimeterCounts);

%Next fix some of the SEED data issues.
[SEEDTime, SEEDCounts, uniqueDeltaTime] = ...
    getCDFUniqueDifferencedSEEDData(info, TT2000Time, TT2000SEEDCounts);

%Determine the flux.  This function will return a structure containing the
%actual flux as well as estimates of the error/uncertainty in the flux.
[fluxAll, flux15] = getCDFFlux(info, SEEDTime, SEEDCounts, uniqueDeltaTime);
%[fluxAll, flux15] = getCDFFlux1(info, SEEDTime, SEEDCounts, uniqueDeltaTime);

%Convert the temperature data to actual physical values.
TemperatureData = convertSEEDTemperature(TT2000TempCounts);

%Make plots of the processed data.
%plotProcessedSEEDDoseData(info, DosimeterCounts, TT2000Time, ...
%    fluxAll, flux15, SEEDTime);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%   Set up for generating the CDF file %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set up the Dosimeter Counts and Dose labels.
SEEDDosimeterCountsLabel = {'SEED Dosimeter Counts Channel 1', ...
    'SEED Dosimeter Counts Channel 2', 'SEED Dosimeter Counts Channel 3'};

SEEDDosimeterDoseLabel = {'SEED Dosimeter Dose Channel 1', ...
    'SEED Dosimeter Dose Channel 2', 'SEED Dosimeter Dose Channel 3'};

%Set up the dosimeter counts to rads conversion factors.
DosimeterCToF = [info.DosimeterChannel1CountsToRads, ...
    info.DosimeterChannel2CountsToRads, info.DosimeterChannel3CountsToRads];

%Convert the Dosimeter structures into arrays.
DosimeterCountsArray = [DosimeterCounts.channel1, DosimeterCounts.channel2, ...
    DosimeterCounts.channel3];
DosimeterDoseArray = [DosimeterDose.channel1, DosimeterDose.channel2, ...
    DosimeterDose.channel3];

%Set up the cell that contains the CDF variables we want to write to file.
CDFVariableNames = {'Epoch', ...
    'SEED_Time_Dt15_Good', ...
    'SEED_Electron_Counts_Total', ...
    'SEED_Electron_Counts_Dt15_Good', ...
    'SEED_Electron_Flux_Total', ...
    'SEED_Electron_Flux_Dt15_Good', ...
    'SEED_Energy_Channels', ...
    'SEED_Geometric_Factor', ...
    'SEED_Dosimeter_Time', ...
    'SEED_Dosimeter_Counts', ...
    'SEED_Dosimeter_Dose', ...
    'SEED_Dosimeter_Counts_To_Dose', ...
    'SEED_Dosimeter_Channels', ...
    'SEED_Dosimeter_Counts_LABEL', ...
    'SEED_Dosimeter_Dose_Label', ...
    'SEED_Temperature'};

CDFVariables = {CDFVariableNames{1}, SEEDTime.TT2000, ...
    CDFVariableNames{2}, SEEDTime.dt15TT2000, ...
    CDFVariableNames{3}, uint32(SEEDCounts.differencedCounts), ...
    CDFVariableNames{4}, uint32(SEEDCounts.differencedDt15Counts), ...
    CDFVariableNames{5}, single(fluxAll), ...
    CDFVariableNames{6}, single(flux15), ...
    CDFVariableNames{7}, single(info.energyBins(:, 2)), ...
    CDFVariableNames{8}, single(info.g), ...
    CDFVariableNames{9}, TT2000Time, ...
    CDFVariableNames{10}, uint32(DosimeterCountsArray), ...
    CDFVariableNames{11}, single(DosimeterDoseArray), ...
    CDFVariableNames{12}, single(DosimeterCToF), ...
    CDFVariableNames{13}, uint32([1, 2, 3]), ...
    CDFVariableNames{14}, SEEDDosimeterCountsLabel, ...
    CDFVariableNames{15}, SEEDDosimeterDoseLabel, ...
    CDFVariableNames{16}, single(TemperatureData)
    };

%Set up some variables to use for the spdfcdfwrite command.  This code is 
%taken directly from the spdfcdfwrite.m examples comments section(line 430).
for p = 1:length(CDFInfo.Variables(:,1))
    varCompress{(2*p)-1} = CDFInfo.Variables{p, 1}; 	% Variable name
    varCompress{2*p} = CDFInfo.Variables{p, 7};	% Variable compression
    blockingFactor{2*p-1} = CDFInfo.Variables{p, 1};		% Variable name
    blockingFactor{2*p} = CDFInfo.Variables{p, 8};		% Variable blocking factor
    varDataTypes{2*p-1} = CDFInfo.Variables{p, 1};	% Variable name
    varDataTypes{2*p} = CDFInfo.Variables{p, 4};	% Variable data type
    pad{2*p-1} = CDFInfo.Variables{p, 1};		% Variable name
    pad{2*p} = CDFInfo.Variables{p, 9};		% Variable pad value
end

%Set up the record bound variable.  This code is taken directly from the
%spdfcdfwrite.m examples comments section(line 442).
rbvars = {CDFInfo.Variables{:, 1}};		% Variable names for recordbound
for p = length(rbvars) : -1 : 1
    if (strncmpi(CDFInfo.Variables{p, 5}, 'f', 1) == 1)	% NRV variable
        rbvars(:, p) = []; 	  		% Remove it
    end
end

%Now write the file.
spdfcdfwrite(fullFilenameCDF, ...
    CDFVariables, ...
    'GlobalAttributes', CDFInfo.GlobalAttributes, ...
    'VariableAttributes', CDFInfo.VariableAttributes, ...
    'RecordBound', rbvars, ...	
    'varcompress', varCompress, ...
    'vardatatypes', varDataTypes, ...
    'blockingfactor', blockingFactor, ...
    'padvalues', pad, ...
    'writemode', 'overwrite');

%Check to see if the file was written.  Does not check to see if the file
%was correctly written, only that it exists.  The spdfcdfwrite function
%does not return any kind of information as to whether or not the command
%was a success.
if isfile(fullFilenameCDF)
     % File exists.
     exportSuccessFlag = 1;
else
     % File does not exist.
     exportSuccessFlag = 0;
end  %End of if-else clause - if isfile(fullFilenameCDF)

end  %End of the function exportSEEDCDF.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% DNToMDN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function missionDayNumber = DNToMDN(doy, year)
%This function will generate the mission day number.
%Mission start was January 15, 2022.  All mission day numbers will be
%calculated from that starting day number.

firstLightYear = 2022;
firstLightDayOfYear = 15;

%Calculate the number of days since the mission started.
%Handle the first year as a special case.
if year == firstLightYear
    missionDayNumber = doy - firstLightDayOfYear + 1;
else
    %First take care of the days in the year for the last year.
    missionDayNumber = doy;

    %Now loop through the remaining years.
    for i = year - 1 : -1 : firstLightYear

        %Check for leap years.
        if leapyear(i)
            numDaysInYear = 366;
        else
            numDaysInYear = 365;
        end %End of if-else clause.

        missionDayNumber = missionDayNumber + numDaysInYear;
    end  %End of for loop - for i = year - 1 : -1 : firstLightYear
    
    %Finally subtract off the 15 days in the first year.
    missionDayNumber = missionDayNumber - firstLightDayOfYear;
end %End of if-else clause 

end  %End of the function DNToMDN.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%  generateSEEDEnergyBins %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function energyBins = generateSEEDEnergyBins(startEnergyBinNumber, ...
    numEnergyBinsToSum)

%This function is called by generateSEEDInformation.m

%Generate the energy bins.  The values are in keV.  The delta E, number of 
%energy bins and offset are determined from the paper.
deltaEnergy = 0.1465;  %In units of keV.
energyBinOffset = -3.837;  %In units of keV.
numEnergyBins = 1024;

%Set up energy bins.
energyBinValues = startEnergyBinNumber : numEnergyBinsToSum : numEnergyBins;
newNumberEnergyBins = length(energyBinValues);

%Allocate memory for the new energy bins.
energyBins = zeros(newNumberEnergyBins, 4);

%Create a counter variable.
j = 1;

%Loop through the energies, combining according to user input.
for i = startEnergyBinNumber : numEnergyBinsToSum : numEnergyBins
    %Determine the center energy.
    ECenter = deltaEnergy*i + energyBinOffset;

    %Determine the low energy boundary.
    ELow = ECenter - numEnergyBinsToSum*deltaEnergy/2.0;

    %Determine the high energy boundary.
    EHigh = ECenter + numEnergyBinsToSum*deltaEnergy/2.0;

    %Determine the energy bin width.
    energyBinWidth = numEnergyBinsToSum*deltaEnergy;

    %Fill the energy bin array.
    energyBins(j, 1) = ELow;
    energyBins(j, 2) = ECenter;
    energyBins(j, 3) = EHigh;
    energyBins(j, 4) = energyBinWidth;

    %Increment the counter.
    j = j + 1;

end  %End of for loop - for i = startEnergyBinNumber : numEnergyBinsToSum : numEnergyBins

end %End of function getnerateSEEDEnergyBins.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%  getSEEDGeometricFactor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function g = getSEEDGeometricFactor(energyBins)

%This function is called by FalconSEEDFlux.m

%Calculate (or set) the geometric factor.   This is an issue that needs to
%be solved.  I believe that the geometric factor taken from the paper is
%not quite correct.  One way to check to to compare these results to the
%GOES satellite data and to also compare to available geophysical models
%such as SPENVIS.  
R1 = 1.14; %Units of millimeters.
R2 = 0.25; %Units of millimeters.
h = 6.35;  %Units of millimeters.
conversionFactor = 0.01;  %Convert from mm^2 to cm^2. 1cm^2 = 100mm^2.
g = conversionFactor*0.5*pi^2*(R2^2 + h^2 + R1^2 - ((h^2 + R1^2 + R2^2)^2 - 4*R1^2*R2^2)^.5);

%We believe that the paper geometric factor is more likely to be correct.
%Let us use the paper values to find the geometric factor.  The paper
%showed the geometric factor to be a linear function of the energy of the
%particles.  This is not theoretically supported, however, it is likely
%that the energy dependence is present due to the inability of the
%instrument electronics to properly separate the electron energies into the
%correct bins. Or something like that. 

%In any event we have the following set of value taken from the paper.
%      Energy (keV) |    Geometric Factor
%   
% 1.       15                  0.8x10^-6
% 2.       20                  1.75x10^-6
% 3.       25                  2.5x10^-6
% 4.       30                  3.4x10^-6
%

%Since the data are linear we will assume that we can write a linear
%function that will fit all of the energies.  I think that this is a bad
%idea.  But here we go.

% y1 = m*x1 + b
% y2 = m*x2 + b
% y2 - y1 = m(x2 - x1)
%  m = (y2 - y1)/(x2 - x1)
%  b = y1 - x1*(y2 - y1)/(x2 - x1)

y1 = 0.8e-6;
y2 = 3.4e-6;
x1 = 15.0;
x2 = 30.0;


m = (y2 - y1)/(x2 - x1);
b = y1 - x1*m;

centerEnergy = energyBins(:, 2);

g = m*centerEnergy + b;

%The values for m and b given above result in a negative geometric factor
%for g(1:97). This is non-physical.  I don't really know what to do since
%it is also %nonsensical.  So  I will simply replace all of the 1 through
%97 values with g(98).  Yay!
%g(1:97) = g(98);

%g = 3.0e-6;  %Units of cm^2 st.  Taken from paper.

end  %End of the function getSEEDGeometricFactor.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  importSEEDCDF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [CDFInfo, CDFData] = importSEEDCDF(info)

%This function is called by SEEDCDF.m  It will read in a CDF file and
%output the results.

%Generate the cdf filename.
CDFFileName = ['STPSat-6_Falcon_SEED-L1_', info.startYearStr, ...
    info.startMonthStr, info.startDayOfMonthStr, '_v01.cdf'];

fullFilenameCDF = ['/SS1/STPSat-6/SEED/', info.startYearStr, ...
    '/L1/DayOfYear_', info.startDayOfYearStr, '/', CDFFileName];

%Get the CDF data.
[data, CDFInfo] = spdfcdfread(fullFilenameCDF);

%Get the data into the appropriate variables.
numVariables = length(data);

for i = 1 : numVariables
    CDFData.(CDFInfo.Variables{i,1}) = data{i};
end

end  %End of the function importSEEDCDF.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  convertSEEDTemperature %%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function temperatureData = convertSEEDTemperature(rawTemperatureData);

%Convert the counts to temperature.  The counts range from -128 to 127. 1
%to 127 are mapped directly to temperature in degrees Celsius.  -127 to 0
%are mapped by taking absolute value and adding to 128.  This converts to
%degrees Celsius.

TData = rawTemperatureData;
TData(TData <= 0) = abs(TData(TData <= 0)) + 128;

temperatureData = TData;

end  %End of the function convertSEEDTemperature.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  getNetCDFData %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Attributes, Dimensions, data] = getNetCDFData(fileName)

    %This function will return the netcdf attributes and dimensions as well as
    %the data.  The input is a string containing the filename and path to where
    %the data file is located.

    %First open the file for reading.
    fileID = netcdf.open(fileName,'NOWRITE');

    % Read the number of dimensions, variables, and attributes to make sure
    % it's not an empty file.
    [ndims, nvars, natts, ~] = netcdf.inq(fileID);

    %Check to see if the file is intact.
    if (ndims == 0) || (natts == 0) || (nvars == 0)
        error('ERROR: L1 file has insufficient fields to proceed.');
    end  %End of if statement.

    % Read in the L1 file attributes 
    for j = 0 : natts - 1
        attname = ['att',num2str(j)];
        attributeName.(attname) = netcdf.inqAttName(fileID,netcdf.getConstant('NC_GLOBAL'), j);
        attributeValue.(attname) = netcdf.getAtt(fileID,netcdf.getConstant('NC_GLOBAL'),attributeName.(attname));
        Attributes.(attributeName.(attname)) = attributeValue.(attname); 
    end  %End of for loop - for j = 0 : natts - 1

    % Read in the L1 file dimensions 
    for j = 0 : ndims - 1
        dimname = ['dim',num2str(j)];
        [Dimensions.(dimname), netcdfDimLength.(dimname)] = netcdf.inqDim(fileID, j);
    end  %End of for loop - for j = 0 : ndims - 1

    % Read in the L1 file variables 
    for j = 0 : nvars - 1
        varname = ['var',num2str(j)];
        variableName.(varname) = netcdf.inqVar(fileID, j);
        varValue.(varname) = netcdf.getVar(fileID, j);
        data.(variableName.(varname)) = varValue.(varname);
    end  %End of for loop - for j = 0 : nvars - 1


end  %End of the function getNetCDFData.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  getDosimeterNETCDFData %%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Attributes, Dimensions, data] = getDosimeterNETCDFData(fileName)


    %This function will return the netcdf attributes and dimensions as well as
    %the data.  The input is a string containing the filename and path to where
    %the data file is located.

    %This function is called by getDosimeterData.m

    %First open the file for reading.
    fileID = netcdf.open(fileName,'NOWRITE');

    % Read the number of dimensions, variables, and attributes to make sure
    % it's not an empty file.
    [ndims, nvars, natts, ~] = netcdf.inq(fileID);

    %Check to see if the file is intact.
    if (ndims == 0) || (natts == 0) || (nvars == 0)
        error('ERROR: L1 file has insufficient fields to proceed.');
    end  %End of if statement.

    % Read in the L1 file attributes 
    for j = 0 : natts - 1
        attname = ['att',num2str(j)];
        attributeName.(attname) = netcdf.inqAttName(fileID,netcdf.getConstant('NC_GLOBAL'), j);
        attributeValue.(attname) = netcdf.getAtt(fileID,netcdf.getConstant('NC_GLOBAL'),attributeName.(attname));
        Attributes.(attributeName.(attname)) = attributeValue.(attname); 
    end  %End of for loop - for j = 0 : natts - 1

    % Read in the L1 file dimensions 
    for j = 0 : ndims - 1
        dimname = ['dim',num2str(j)];
        [Dimensions.(dimname), netcdfDimLength.(dimname)] = netcdf.inqDim(fileID, j);
    end  %End of for loop - for j = 0 : ndims - 1

    % Read in the L1 file variables 
    for j = 0 : nvars - 1
        varname = ['var',num2str(j)];
        variableName.(varname) = netcdf.inqVar(fileID, j);
        varValue.(varname) = netcdf.getVar(fileID, j);
        data.(variableName.(varname)) = varValue.(varname);
    end  %End of for loop - for j = 0 : nvars - 1

end  %End of the function getDosimeterNETCDFFile.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  generateTT2000 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [TT2000Time, UTCTime, TT2000SEEDCounts, TT2000DoseCounts, ...
    TT2000TempCounts] = generateTT2000(info, time, SEEDCounts, ...
    DoseCounts, TempCounts)

%This function will convert the GPS times to UTC time and then from UTC
%times to TT2000 times.

%First step:  convert the integer seconds since Jan. 6, 1980 into
%fractional days since Jan. 6, 1980.
fractionalDays = time/86400.0;

%Second step:  We must anchor the fractional days to matlab
%time.  We do this in order to use Matlab's date and time functions.
%The way to do this is to add the number of fractional days to the Jan. 6,
%1980 epoch time. This places the original time vector into a time 
%measured in the matlab time coordinate frame.
epochTime = [info.epochYear, info.epochMonth, info.epochDayOfMonth, ...
                info.epochHour, info.epochMinute, info.epochSecond];
MatlabCoordinateTimeFractionalDays = fractionalDays + datenum(epochTime);

%Third step:  We now use the datenum function for the actual date being
%analyzed.  By subtracting the time of 0 hours, 0 minutes and 0 seconds 
%from the times values in the original time vector we end up with
%with the fractional days of the data.  Note: we use a month of zero in
%the dataDateTime vector.  This allows us to use day of year in the
%call to datenum.
dataDateTime = [info.startYear, 0, info.startDayOfYear, 0, 0, 0];
FractionalDaysTime = MatlabCoordinateTimeFractionalDays - datenum(dataDateTime);

%Fourth step:  We now convert from fractional days to fractional
%seconds by multiplying by 86400.0.
GPSTime = 86400.0*FractionalDaysTime;

%Fifth step:  We convert from GPS time into UTC time by subtracting 18 
%seconds.
rawTime = GPSTime - 18.0;

%Sixth step : The new rawTime can be less than zero! I am going
%to handle this by finding any negative values and just dropping them.
%This will drop, at most, 18 events.  Otherwise, we will have to move
%the negative events into the previous day.
goodDayIndex = find(rawTime > 0.0);

%Determine the number of events in the day.
numEvents = length(goodDayIndex);

%Finally we have the time in UTC seconds since the start of the day.
UTCTime = rawTime(goodDayIndex)';

%Here we just output the raw counts.
TT2000SEEDCounts = SEEDCounts(goodDayIndex, :);
TT2000DoseCounts = DoseCounts(goodDayIndex, :);
TT2000TempCounts = TempCounts(goodDayIndex);

%Now we want to convert this into the TT time.  In order to do this we need
%vectors of year, month, day, hours, minutes, seconds, milliseconds,
%microseconds and nanoseconds.
year = repmat(info.startYear, 1, numEvents);
month = repmat(info.startMonth, 1, numEvents);
day = repmat(info.startDayOfMonth, 1, numEvents);
hours = floor(UTCTime/3600);
minutes = floor((UTCTime - 3600*hours)./60.0);

realSeconds = UTCTime - 3600*hours - 60*minutes;
seconds = fix(realSeconds);

%First get rid of the stuff to the left of the decimal.
fractionalSeconds = realSeconds - fix(realSeconds);

%Now multiply by 1e9 to get all of the nanoseconds.
numNanoseconds = fix(1.0e9*fractionalSeconds);

%Now get the milliseconds.
milliseconds = fix(fix(numNanoseconds/1000)/1000);

%Now get the microseconds.
microseconds = fix(  (numNanoseconds - milliseconds*1e6)/1000 );

%Now get the nanoseconds
nanoseconds = fix( (numNanoseconds - milliseconds*1e6 - microseconds*1e3));

%Join the values into one large array.
Time = [year; month; day; hours; minutes; ...
    seconds; milliseconds; microseconds; nanoseconds];

%Transpose here because the spdf function expects each event as a single
%row.
Time = Time';

%Calculate the TT2000 times.
TT2000Time = spdfcomputett2000(Time);

end  %End of the function generateTT2000.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% getCDFDosimeterCountsAndDose %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DosimeterCounts, DosimeterDose] = ...
    getCDFDosimeterCountsAndDose(info, TT2000DosimeterCounts)

%This function is called by exportSEEDCDF.m.  This function will use the
%results from plotCDFDosimeterData.m to set the correct count values to be
%exported.  This function will then convert the counts to dose and return
%the results along with the chosen times.

%We need to difference the data.
%Subtract interval (i + 1) from interval (i).
orderOfDifference = 1;  

%The dimension over which the difference will be calculated.
%Here we are working with the rows which has array dimension = 1.
arrayDimension = 1;  

%Get the count difference for channel 1.
countDifference1 = diff(TT2000DosimeterCounts(:, 1), orderOfDifference, ...
    arrayDimension);

%Now lets add the first row of TT2000DosimeterCounts to the differenced data in
%countDifference1.
countDifference1 = [TT2000DosimeterCounts(1, 1); countDifference1];

%Get the count difference for channel 2.
countDifference2 = diff(TT2000DosimeterCounts(:, 2), orderOfDifference, ...
    arrayDimension);

%Now lets add the first row of TT2000DosimeterCounts to the differenced data in
%countDifference1.
countDifference2 = [TT2000DosimeterCounts(1, 2); countDifference2];

%Get the count difference for channel 3.
countDifference3 = diff(TT2000DosimeterCounts(:, 3), orderOfDifference, ...
    arrayDimension);

%Now lets add the first row of TT2000DosimeterCounts to the differenced data in
%countDifference1.
countDifference3 = [TT2000DosimeterCounts(1, 3); countDifference3];

%These count limits were detemined by trial and error.  They may not be
%perfect for any given day.  Do not know what else to do.  It may be a good
%idea to check that these values are okay for days 139-229 as this set of
%days did not have the 20 minute reset procedure operating.
lowerCountsLimitChannel1 = -5;
lowerCountsLimitChannel2 = 1;
lowerCountsLimitChannel3 = 0;

%We have decided to only present channels 1 through 3 of the dosimeter.

%Set the valid minimum and valid maximum values for the dosimeter.  These
%are taken from the CDF master file.
validMin = 0;
%This is 4*2^12.  This is not correct but I cannot seem to get a clear
%answer as to what this size actually is! 
validMax = 16384;  

% %Set out the variables for the different channels.
% countsChannel1 = TT2000DosimeterCounts(:, 1);
% countsChannel2 = TT2000DosimeterCounts(:, 2);
% countsChannel3 = TT2000DosimeterCounts(:, 3);

%Get rid of the negative counts.
countDifference1(countDifference1 < lowerCountsLimitChannel1) = validMin;
countDifference2(countDifference2 < lowerCountsLimitChannel2) = validMin;
countDifference3(countDifference3 < lowerCountsLimitChannel3) = validMin;

%Now set any high value to NaN.  We do this because the instrument had a
%12-bit data value which translates to a maximum count value of 4096. This
%is then multiplied by 4. If any data values are higher than this
%there is some kind of error(hardware or software).  It is not real.  As
%there appear to be few of these let's just set them to NaNs.
countDifference1(countDifference1 > 16384) = validMax;
countDifference2(countDifference2 > 16384) = validMax;
countDifference3(countDifference3 > 16384) = validMax;

%Put the various variables into a structure.
DosimeterCounts.channel1 = countDifference1;
DosimeterCounts.channel2 = countDifference2;
DosimeterCounts.channel3 = countDifference3;

%Now convert from counts to dose.
doseChannel1 = info.DosimeterChannel1CountsToRads*countDifference1;
doseChannel2 = info.DosimeterChannel2CountsToRads*countDifference2;
doseChannel3 = info.DosimeterChannel3CountsToRads*countDifference3;

%Put the various variables into a structure.
DosimeterDose.channel1 = doseChannel1;
DosimeterDose.channel2 = doseChannel2;
DosimeterDose.channel3 = doseChannel3;

end  %End of the function getCDFDosimeterCountsAndDose.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%  getCDFUniqueDifferencedSEEDData %%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [uniqueSEEDTime, uniqueSEEDCounts, uniqueDeltaTime] = ...
    getCDFUniqueDifferencedSEEDData(info, TT2000Time, TT2000SEEDCounts)

%This function is called by exportSEEDCDF.m
%This function will return two structures.  The time structure will hold
%the times in TT2000 time for the unique events as well as unique events
%that have a delta t = 15 seconds.  These will be named
%uniqueSEEDTime.TT2000 and uniqueSEEDTime.dt15TT2000 respectively.
%The counts structure will hold the unique counts and counts that have a
%delta t = 15 seconds.  These will be called
%uniqueSEEDCounts.differencedCounts and
%uniqueSEEDCounts.differencedDt15Counts respectively.

%rawTime is given in nanoseconds since some starting time, which I do not
%know.  I am sure NASA defined it but I cannot find where it is recorded.
%Okay, just checking the values, it looks like TT2000 time is in
%nanoseconds from January 1, 2000.  Presumably midnight but possibly 6 AM.
rawTime = TT2000Time;

%Pull the SEED data out of the data structure.  Here we also limit the
%number of energy channels so as to remove the low energy issues.
rawSEEDData = TT2000SEEDCounts(:, info.startEnergyBinNumber:end);

%We need to get rid of the potentially 15 multiples(in time) of the energy
%spectra.  This next section investigates how choosing a particular energy
%bin value gives out different numbers of unique values.  The lower the
%energy the more unique values we have.  
%Choose some random energy bin values.
energyBin1 = 1;
energyBin2 = 6;
energyBin3 = 9;
uniqueSEEDDataIndex = determineUniqueIndexPerEnergy(rawSEEDData, ...
    energyBin1, energyBin2, energyBin3);

%Use the indices returned by unique to keep only the unique SEED data.
uniqueSEEDData = rawSEEDData(uniqueSEEDDataIndex, :);

%We use the unique SEED Data index to get the unique times.
uniqueTime = rawTime(uniqueSEEDDataIndex);

%We also want the times between data points.  Since the instrument
%integrates we will subtract(diff) the time values.  In order to get
%seconds from nanoseconds we divide by 1e9.
deltaTime = diff(uniqueTime)*1.0e-9;

%We want the delta times to be the same length as the unique data points so
%we need to prepend a delta time onto the diff result.  I will choose 15
%seconds as that time since I have no way of knowing what it actually is
%and it is supposed to be 15 seconds.
uniqueDeltaTime = [15; deltaTime];

%Lets fill in part of the time structure.  These values are in TT2000
%times.
uniqueSEEDTime.TT2000 = uniqueTime;

%Let us also calculate the time intervals associated with the unique times
%determined above.  First lets convert the TT2000 time to seconds.
rawTimeSeconds = 1.0e-9*(rawTime - rawTime(1));

%Now find the difference in time for the counts.
orderOfDifference = 1;  %Subtract interval (i + 1) from interval (i).
arrayDimension = 1;  %The dimension over which the difference will be calculated.
%Here we are working with the rows which has array dimension = 1.
countDifference = diff(uniqueSEEDData, orderOfDifference, arrayDimension);

%Now lets add the first row of uniqueSEEDData to the differenced data in
%countDifference.
countDifference = [uniqueSEEDData(1, :); countDifference];

%Set a lower limit to the differenced counts.
lowerCountsLimit = 0;

%Set the valid minimum and valid maximum values for the SEED instrument.
%These are taken from the CDF master file.
validMin = 0;
validMax = 4294967296;  %This is 2^32

%Get rid of the negative counts.
positiveCountDifference = countDifference;
positiveCountDifference(positiveCountDifference < lowerCountsLimit) = validMin;

%Now we difference the unique times.  We want to look at the 15 second
%intervals.  First we need to get time in seconds from start of the day.
%The factor of 1.0e-9 is due to the fact that TT2000 has time in
%nanoseconds-> 1 second = 1e9 nanoseconds.
timeSeconds = 1.0e-9*(uniqueTime - uniqueTime(1));
timeDifference = diff(timeSeconds, orderOfDifference, arrayDimension);
timeDifference = [15; timeDifference];

%Find indices that have time differences around 15 seconds.
timeDifference15Index = find(timeDifference > 0.0 & timeDifference < 30.0);

%Generate a comparison plot between 15 second time intervals only and for
%all time intervals for the differenced counts.
%timeDifference15Index = showSEEDTimeIntervals(info, countDifference, ...
%   timeDifference, uniqueTime, uniqueDateNumber);

%Now get count difference that corresponds to the delta t = 15.
dt15 = positiveCountDifference(timeDifference15Index, :);

%Fill the counts structure.
uniqueSEEDCounts.differencedCounts = countDifference;
uniqueSEEDCounts.differencedDt15Counts = dt15;

%Do the same for the time structure.
eventSeconds15 = uniqueTime(timeDifference15Index)';

%Fill the time structure.
uniqueSEEDTime.dt15TT2000 = eventSeconds15;

end  %End of the function getCDFUniqueDifferencedSEEDData.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%  getCDFFlux %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fluxAll, flux15] = getCDFFlux(info, time, Counts, deltaTime) 

%This function is called by exportSEEDCDF.m  It will convert SEED counts to
%SEED flux.

energyBins = info.energyBins;

%Get the geometric factor.
geometricFactor = info.g;

%Determine the energy bin width.
deltaE = info.deltaE;  %Units are in keV.

%Get the counts out of the Count structure.
differencedCounts = Counts.differencedCounts;
differencedDt15Counts = Counts.differencedDt15Counts;

%In order to calculate the error estimate we need to divide by the counts.
%This will cause a NaN result if the counts are ever zero.  Lets set all
%negative valued count differences to the value prior to going negative.

%First find the negative counts.  Choose energy bin 100 although it does
%not seem to matter which bin I choose since all of the energy channels go
%negative at the same time.
negCountsIndex = find(differencedCounts(:, 100) < 0);

%Next get the time index of the count difference just before it goes
%negative.
negCountsIndexPrior = negCountsIndex - 1;

%Finally replace the negative count differences with the count differences
%from just prior to going negative.
differencedCounts(negCountsIndex, :) = ...
    differencedCounts(negCountsIndexPrior, :);

%Determine the size of the counts array.
[numEventsAll, numEnergyBins] = size(differencedCounts);
[numEvents15, numEnergyBins] = size(differencedDt15Counts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Allocate an array for the fluxes. 
fluxAll = zeros(numEventsAll, numEnergyBins);
flux15 = zeros(numEvents15, numEnergyBins);

%Set up the variable for delta time = 15 seconds.
deltaT = 15.0;

%Now calculate the uncertainties.
for e = 1 : numEnergyBins

    %Loop over the events for the unique data points.
    for t = 1 : numEventsAll
        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  The deltaTime values are 64
        %bit integers and so we need to convert them to doubles.
        countsToFluxAll = 1.0/(deltaE*geometricFactor(e)*double(deltaTime(t)));
        fluxAll(t, e) = countsToFluxAll*differencedCounts(t, e);

    end  %End of for loop - for t = 1 : rawNumEvents.       

    %Loop over the events for the delta t = 15 data points.
    
    for t = 1 : numEvents15
        %The flux is detemined from the counts by dividing the counts by the
        %energy, time and geometric factor.  
        countsToFlux = 1.0/(deltaE*geometricFactor(e)*deltaT);
%        disp(['Conversion Factor : ', num2str(countsToFlux)])
        flux15(t, e) = countsToFlux*differencedDt15Counts(t, e);

    end  %End of for loop - for t = 1 : rawNumEvents.       
end  %End of for loop - for e = 1 : numEnergyBins

end  %End of the function getSEEDFlux.m



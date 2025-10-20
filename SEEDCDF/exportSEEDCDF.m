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
TemperaturePathName = [info.temperatureRootDir, info.startYearStr, ...
    '/L1/DayOfYear_', info.startDayOfYearStr, '/'];

%Generate the file names.
TemperatureL1File = ['STPSat-6_FalconTEMP_', info.startDateStr, '_', ...
    info.startDayOfYearStr, '_L1.nc'];
TemperatureFileName = [TemperaturePathName, TemperatureL1File];

%Read in the dosimeter data.
[TemperatureDataAttributes, ~, rawTemperatureData] = ...
    getNetCDFData(TemperatureFileName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Handle the TT2000 data      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate the TT2000 time intervals and corresponding counts.  The
%TT2000Time variable is valid for both SEED data and Dosimeter data at this
%time.  
[TT2000Time, UTCTime, TT2000SEEDCounts, TT2000DosimeterCounts, ...
    TT2000TempCounts] = generateTT2000(info, rawSEEDData.Time, ...
    rawSEEDData.Data, rawDosimeterData.Data, ...
    rawTemperatureData.Data);

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
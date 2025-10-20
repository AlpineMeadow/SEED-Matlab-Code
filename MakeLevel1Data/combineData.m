function combineData(info, missionDayNumber)

%This function will combine the data from various L1 files and output a new
%file which contains as many unique data points as are available.  
%This function will then output the results into the NASA CDF file format.

%This function is called by JoinL1Data.m

%Load the STPSat-6 parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
ParameterPath = '/SS1/Matlab/';
run([ParameterPath, ParameterFile]);

%Lets get the day of year.
dayOfYearStr = num2str(MDNToDN(missionDayNumber), '%03d');

%Lets get the month and day of month.
[year, month, dayOfMonth] = MDNToMonthDay(missionDayNumber);

%Generate a date string.
dateStr = [num2str(year), num2str(month, '%02d'), ...
    num2str(dayOfMonth, '%02d')];

%Set up the various file names.
SEEDInFilenames = strcat(info.SEEDRootDir, info.startYearStr, ...
    '/L1/DayOfYear_', dayOfYearStr, '/', ...
    'STPSat-6_FalconSEED_', dateStr, '_', dayOfYearStr, ...
    '_*_L1.nc');

SEEDOutFilenameV1 = strcat(info.SEEDRootDir, info.startYearStr, ...
    '/L1/DayOfYear_', dayOfYearStr, '/', ...
    'STPSat-6_Falcon_SEED-L1_', dateStr, '_v01');

SEEDOutFilenameV2 = strcat(info.SEEDRootDir, info.startYearStr, ...
    '/L1/DayOfYear_', dayOfYearStr, '/', ...
    'STPSat-6_Falcon_SEED-L1_', dateStr, '_v02');

disp(' ')
disp(['Infilenames : ', SEEDInFilenames])
disp(['Outfilename 1 : ', SEEDOutFilenameV1])
disp(['Outfilename 2 : ', SEEDOutFilenameV2])

%Get the directory structure of the file names for the day in question.
fileNames = dir(SEEDInFilenames);
    
%Determine the number of files.
numFiles = length(fileNames);
        
disp(['Number of files : ', num2str(numFiles)])
disp(' ')

%Some days do not have any data so check first.
if(numFiles ~= 0)

    %Loop through the number of files.
    for j = 1 : numFiles

      %Generate a file name.
      filename = [fileNames(j).folder, '/', fileNames(j).name];

      %Get the data.  It is in the netCDF data file format.
      [Attributes, Dimensions, rawData] = getNetCDFData(filename);

      %Handle the first file separately.
      if j == 1
 
        % rawData.var1 holds the time, L1VarVal.var2 holds the dosimeter data,
        % rawData.var3 holds the temperature data and L1VarVal.var7 holds the
        % SEED data.
        if isfield(rawData, 'TYPE1_PKT_DATA_TIME_ARRAY')
            rawTime = rawData.TYPE1_PKT_DATA_TIME_ARRAY;
        end
        if isfield(rawData, 'TYPE1_PKT_DOSIMETER_ARRAY')
            rawDose = rawData.TYPE1_PKT_DOSIMETER_ARRAY;
        end
        if isfield(rawData, 'TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY')
            rawTemp = rawData.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY;
        end
        if isfield(rawData, 'TYPE1_PKT_SPECTRA_ARRAY')
            rawSeed = rawData.TYPE1_PKT_SPECTRA_ARRAY;
        end
      else

        %Append the data onto the arrays.
        if isfield(rawData, 'TYPE1_PKT_DATA_TIME_ARRAY')
            rawTime = cat(1, rawTime, rawData.TYPE1_PKT_DATA_TIME_ARRAY);
        end
        if isfield(rawData, 'TYPE1_PKT_DOSIMETER_ARRAY')
            rawDose = cat(1, rawDose, rawData.TYPE1_PKT_DOSIMETER_ARRAY);            
        end
        if isfield(rawData, 'TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY')
            rawTemp = cat(1, rawTemp, rawData.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY);
        end
        if isfield(rawData, 'TYPE1_PKT_SPECTRA_ARRAY')
            rawSeed = cat(1, rawSeed, rawData.TYPE1_PKT_SPECTRA_ARRAY);
        end

      end  %End if if/else statement - if j == 1
 
    end  %End of for loop - for j = 1 : numFiles
     
    %Now find the unique values of the time vector.
    [uniqueTime, lastInstanceIndex, firstInstanceIndex] = unique(rawTime);
 
    %Use those unique values to pick out the same unique values for the SEED
    %data, the Dosimeter data and the Temperature data.
    DoseData = rawDose(lastInstanceIndex, :);
    TempData = rawTemp(lastInstanceIndex);
    time = rawTime(lastInstanceIndex);

    %We generate version 1 and version 2 SEED data values.
    SEEDDataV1 = rawSeed(lastInstanceIndex, :);
    SEEDDataV2 = info.SEEDCorrectionFactor*rawSeed(lastInstanceIndex, :);

    %Write the data to the CDF files.

    %Write a cdf files.
    [fullFilenameCDFV1, exportSuccessFlagV1, CDFVariableNames] = ...
        generateSEEDCDF(info, SEEDOutFilenameV1, missionDayNumber, ...
        SEEDDataV1, DoseData, TempData, time);

    [fullFilenameCDFV2, exportSuccessFlagV2, CDFVariableNames] = ...
        generateSEEDCDF(info, SEEDOutFilenameV2, missionDayNumber, ...
        SEEDDataV2, DoseData, TempData, time);

    %Check to see if the write operation was successful.
    if exportSuccessFlagV1 == 1
        disp(['The CDF file ', fullFilenameCDFV1, ...
            ' has successfully been written.'])
    else
        disp(['The CDF file ', fullFilenameCDFV1, ... 
            ' was not successfully written.'])
    end  %End of if else clause - if exportSuccessFlag == 1

    %Check to see if the write operation was successful.
    if exportSuccessFlagV2 == 1
        disp(['The CDF file ', fullFilenameCDFV2, ...
            ' has successfully been written.'])
    else
        disp(['The CDF file ', fullFilenameCDFV2, ... 
            ' was not successfully written.'])
    end  %End of if else clause - if exportSuccessFlag == 1


end %End of if statement - if(numFiles ~= 0)

end  %End of the function combineData1.m
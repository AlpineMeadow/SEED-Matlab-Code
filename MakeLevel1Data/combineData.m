function combineData(info, missionDayOfYear)

%This function will combine the data from various L1 files and output a new
%netcdf file which contains as much, unique data points as is available.  
%This function will then output the results into the NASA CDF file format.
 
%Convert the mission day of year into calendar day of year and year.
[dayOfYear, year] = MDNToDN(info, missionDayOfYear);
yearStr = num2str(year);
dayOfYearStr = num2str(dayOfYear, '%03d');

%Convert day of year and year to month and day of month.
dateVector = datevec(datenum(year, 0, dayOfYear));
month = dateVector(2);
dayOfMonth = dateVector(3);
monthStr = num2str(month, '%02d');
dayOfMonthStr = num2str(dayOfMonth, '%02d');

%Generate a date string.
dateStr = [yearStr, monthStr, dayOfMonthStr];

%Load the STPSat-6 parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
ParameterPath = [info.STPSat6RootDir, 'MatlabCode/Functions/'];
run([ParameterPath, ParameterFile]);

%Set up the various file names.
SEEDInFilenames = strcat(info.SEEDRootDir, yearStr, '/L1/DayOfYear_', ...
    dayOfYearStr, '/', 'STPSat-6_FalconSEED_', dateStr, '_', ...
    dayOfYearStr, '_*_L1.nc');

SEEDOutFilename = strcat(info.SEEDRootDir, yearStr, '/L1/DayOfYear_', ...
    dayOfYearStr, '/', 'STPSat-6_Falcon_SEED-L1_', dateStr, '_v01');

%Get the directory structure of the file names for the day in question.
fileNames = dir(SEEDInFilenames);
    
%Determine the number of files.
numFiles = length(fileNames);
        
%Some days do not have any data so check first.
if(numFiles ~= 0)

    %Loop through the number of files.
    for j = 1 : numFiles

      %Generate a file name.
      filename = [fileNames(j).folder, '/', fileNames(j).name];

      %Get the data.
      [Attributes, Dimensions, rawData] = getNetCDFData(filename);

      %Handle the first file separately.
      if (j == 1) 
 
        % rawData.var1 holds the time, L1VarVal.var2 holds the dosimeter data,
        % rawData.var3 holds the temperature data and L1VarVal.var7 holds the
        % SEED data.
        rawTime = rawData.TYPE1_PKT_DATA_TIME_ARRAY;
        rawDose = rawData.TYPE1_PKT_DOSIMETER_ARRAY;
        rawTemp = rawData.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY;
        rawSeed = rawData.TYPE1_PKT_SPECTRA_ARRAY;

      else

        %Append the data onto the arrays.
        rawTime = cat(1, rawTime, rawData.TYPE1_PKT_DATA_TIME_ARRAY);
        rawDose = cat(1, rawDose, rawData.TYPE1_PKT_DOSIMETER_ARRAY);
        rawTemp = cat(1, rawTemp, rawData.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY);
        rawSeed = cat(1, rawSeed, rawData.TYPE1_PKT_SPECTRA_ARRAY);
      end
 
    end  %End of for loop - for j = 1 : numFiles
     
    %Now find the unique values of the time vector.
    [uniqueTime, lastInstanceIndex, firstInstanceIndex] = unique(rawTime);
 
    %Use those unique values to pick out the same unique values for the SEED
    %data, the Dosimeter data and the Temperature data.
    SEEDData = rawSeed(lastInstanceIndex, :);
    DoseData = rawDose(lastInstanceIndex, :);
    TempData = rawTemp(lastInstanceIndex);
    time = rawTime(lastInstanceIndex);
 
    %Write the data to the CDF files.
    
    %Write a cdf file.
    [fullFilenameCDF, exportSuccessFlag, CDFVariableNames] = ...
        generateSEEDCDF(info, SEEDOutFilename, missionDayOfYear, ...
        SEEDData, DoseData, TempData, time);

    %Check to see if the write operation was successful.
    if exportSuccessFlag == 1
        disp(['The CDF file ', fullFilenameCDF, ...
            ' has successfully been written.'])
    else
        disp(['The CDF file ', fullFilenameCDF, ... 
            ' was not successfully written.'])
    end  %End of if else clause - if exportSuccessFlag == 1



end %End of if statement - if(numFiles ~= 0)

end  %End of the function combineData1.m
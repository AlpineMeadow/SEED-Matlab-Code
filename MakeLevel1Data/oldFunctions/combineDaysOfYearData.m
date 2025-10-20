function combineDaysOfYearData(info, missionDayOfYear)

%This function will combine the data from various L1 files and output a new
%netcdf file which contains as much, unique data points as is available.
%This function will also split the L1 files into three different instrument
%files.
 
%Load the STPSat-6 parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
ParameterPath = '/SS1/Matlab/';
run([ParameterPath, ParameterFile]);

%Convert mission Day of year to calendar day of year and year.
[dayOfYear, year] = MDNToDN(missionDayOfYear);

%Find the month and day of month.
dateVector = datevec(datenum(year, 0, dayOfYear));
month = dateVector(2);
dayOfMonth = dateVector(3);

%Generate strings for all of the days and years.
yearStr = num2str(year);
dayOfYearStr =  num2str(dayOfYear, '%03d');
monthStr = num2str(month, '%02d');
dayOfMonthStr = num2str(dayOfMonth, '%02d');
dateStr = [yearStr, monthStr, dayOfMonthStr];

%Set up the various file names.
SEEDInFilenames = strcat(info.SEEDRootDir, yearStr, '/L1/DayOfYear_', ...
			dayOfYearStr, '/STPSat-6_FalconSEED_*');

SEEDRootFileName = strcat(info.SEEDRootDir, yearStr, '/L1/DayOfYear_', ...
			dayOfYearStr, '/STPSat-6_FalconSEED_', yearStr, monthStr, ...
            dayOfMonthStr, '_', dayOfYearStr, '_L1.nc');

SEEDOutFilename = strcat(info.SEEDRootDir, yearStr, '/L1/DayOfYear_', ...
    dayOfYearStr, '/STPSat-6_FalconSEED_', yearStr, monthStr, dayOfMonthStr, '_', ...
    dayOfYearStr, '_L1.nc');

DoseOutFilename = strcat(info.dosimeterRootDir, yearStr, '/L1/DayOfYear_', ...
    dayOfYearStr, '/STPSat-6_FalconDOSE_', yearStr, monthStr, ...
    dayOfMonthStr, '_', dayOfYearStr, '_L1.nc');

TempOutFilename = strcat(info.temperatureRootDir, yearStr, '/L1/DayOfYear_', ...
    dayOfYearStr, '/STPSat-6_FalconTEMP_', yearStr, monthStr, ...
    dayOfMonthStr, '_', dayOfYearStr, '_L1.nc');


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

      %Check to see if the root file is there.  If so, just continue.
      if strcmp(filename, SEEDRootFileName)
          continue          
      else
          %Get the data.
          [Attributes, Dimensions, rawData] = getNetCDFData(filename);

          %Handle the first file separately.
          if (j == 1) 
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
          end %End of if statement - if (j == 1)
      end  %End of if statement - if strcmp(filename, SEEDRootFileName)
    end  %End of for loop - for j = 1 : numFiles
     
    %Now find the unique values of the time vector.
    [uniqueTime, lastInstanceIndex, firstInstanceIndex] = unique(rawTime);
 
    %Use those unique values to pick out the same unique values for the SEED
    %data, the Dosimeter data and the Temperature data.
    SEEDData = rawSeed(lastInstanceIndex, :);
    DoseData = rawDose(lastInstanceIndex, :);
    TempData = rawTemp(lastInstanceIndex);
    time = rawTime(lastInstanceIndex);
 
    %Now generate the netcdf files and write the data into it.  We keep the
    %various attributes, dimensions and other bits of information.

    %Generate the SEED netcdf file.
    InstrumentName = 'SEED';
    generateNetCDFFile(info, SEEDOutFilename, time, SEEDData, ...
    InstrumentName, dateStr, dayOfYearStr);

    %Generate the Dosimeter netcdf file.
    InstrumentName = 'Dosimeter';
    generateNetCDFFile(info, DoseOutFilename, time, DoseData, ...
    InstrumentName, dateStr, dayOfYearStr);

    %Generate the Temperature netcdf filename.
    InstrumentName = 'Temperature';
    generateNetCDFFile(info, TempOutFilename, time, TempData, ...
    InstrumentName, dateStr, dayOfYearStr);

end %End of if statement - if(numFiles ~= 0)

end  %End of function combineDaysOfYearData.m
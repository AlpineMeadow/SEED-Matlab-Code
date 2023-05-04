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
doy = 64;
startDayOfYear = doy;
endDayOfYear = doy;
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
info = generateInformationStructure(startDayOfYear, startYear, endDayOfYear, ...
	endYear, startEnergyBinNumber, startEnergy, endEnergy, ...
    numEnergyBinsToSum, numTimeBinsToSum, numTimeStepsToSkip, ...
    startHour, startMinute, startSecond, endHour, endMinute, endSecond, ...
    CDFDataVersionNumber);

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











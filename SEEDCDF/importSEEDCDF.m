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
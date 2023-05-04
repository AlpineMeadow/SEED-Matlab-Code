function  [CDFInfo, CDFData] = importSEEDCDF1(info, varargin)

%This function is called by SEEDCDF.m  It will read in a CDF file and
%output the results.

%We want to have the option to input the mission day of year.  
%Start with declaring an input parser handle.
p = inputParser;


%Add the required info strcture and the optional mission day of year to the
%input parser.
addRequired(p, 'info', @isstruct);
addOptional(p, 'missionDayOfYear', 1);

%Now parse the input arguments.
parse(p, info, varargin{:});
%disp(p.Results)

%Now check to see if the mission day of year is present.
numArgs = length(varargin);

if numArgs == 1
    %Get the mission day number out of the argument parser.
    missionDayOfYear = p.Results.missionDayOfYear;

    %Convert mission day of year into year, month and day of month.
    [year, month, dayOfMonth] = MDNToMonthDay(info, missionDayOfYear);
    [dayOfYear, year] = MDNToDN(info, missionDayOfYear);

    %Generate some strings.
    yearStr = num2str(year);
    monthStr = num2str(month, '%02d');
    dayOfMonthStr = num2str(dayOfMonth, '%02d');
    dayOfYearStr = num2str(dayOfYear, '%03d');

    %Generate the cdf filename.
    CDFFileName = ['STPSat-6_Falcon_SEED-L1_', yearStr, ...
    monthStr, dayOfMonthStr, '_v01.cdf'];

    fullFilenameCDF = ['/SS1/STPSat-6/SEED/', info.startYearStr, ...
    '/L1/DayOfYear_', dayOfYearStr, '/', CDFFileName];
else
    %Generate the cdf filename.
    CDFFileName = ['STPSat-6_Falcon_SEED-L1_', info.startYearStr, ...
    info.startMonthStr, info.startDayOfMonthStr, '_v01.cdf'];

    fullFilenameCDF = ['/SS1/STPSat-6/SEED/', info.startYearStr, ...
    '/L1/DayOfYear_', info.startDayOfYearStr, '/', CDFFileName];
end  %End of if statement - if numArgs == 1


%disp(fullFilenameCDF)
%Get the CDF data.
[data, CDFInfo] = spdfcdfread(fullFilenameCDF);

%Get the data into the appropriate variables.
numVariables = length(data);

for i = 1 : numVariables
    CDFData.(CDFInfo.Variables{i,1}) = data{i};
end

end  %End of the function importSEEDCDF1.m
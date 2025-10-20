function  [CDFInfo, CDFData] = importSEEDCDF1(info, varargin)

%This function is called by SEEDCDF.m  It will read in a CDF file and
%output the results.

%We want to have the option to input the mission day of year.  
%Start with declaring an input parser handle.
p = inputParser;

%Add the required info structure and the optional mission day of year to the
%input parser.
addRequired(p, 'info', @isstruct);
addOptional(p, 'missionDayOfYear', 1);

%Now parse the input arguments.
parse(p, info, varargin{:});

%Now check to see if the mission day of year is present.  This allows us to
%use just one day(numArgs = 0) or many days(numArgs > 0).
numArgs = length(varargin);

if numArgs == 1
    %Get the mission day number out of the argument parser.
    missionDayOfYear = p.Results.missionDayOfYear;

    %Convert mission day of year into year, month and day of month.
    [year, month, dayOfMonth] = MDNToMonthDay(missionDayOfYear);
    [dayOfYear, year] = MDNToDN(missionDayOfYear);

    %Generate some strings.
    yearStr = num2str(year);
    monthStr = num2str(month, '%02d');
    dayOfMonthStr = num2str(dayOfMonth, '%02d');
    dayOfYearStr = num2str(dayOfYear, '%03d');

    %Generate the cdf filename.
    CDFFileName = ['STPSat-6_Falcon_SEED-L1_', yearStr, ...
    monthStr, dayOfMonthStr, '_v01.cdf'];

    fullFilenameCDF = ['/SS1/STPSat-6/SEED/', yearStr, ...
    '/L1/DayOfYear_', dayOfYearStr, '/', CDFFileName];
else
    %Generate the cdf filename.
    CDFFileName = ['STPSat-6_Falcon_SEED-L1_', info.startYearStr, ...
    info.startMonthStr, info.startDayOfMonthStr, '_v01.cdf'];

    fullFilenameCDF = ['/SS1/STPSat-6/SEED/', info.startYearStr, ...
    '/L1/DayOfYear_', info.startDayOfYearStr, '/', CDFFileName];
end  %End of if statement - if numArgs == 1

%Let the user see what day they are accessing.
%disp(fullFilenameCDF)

%Get the CDF data.
[data, CDFInfo] = spdfcdfread(fullFilenameCDF);

%Get the data into the appropriate variables.
numVariables = length(data);

%Read the data into the CDF data structure.  
for numVar = 1 : numVariables
    CDFData.(CDFInfo.Variables{numVar, 1}) = data{numVar};
end

%I am going to convert the output times(given in datenums) into Matlab's
%datetime objects.
epochTime = datetime(CDFData.Epoch, 'ConvertFrom', 'datenum');
SEEDGoodTime = datetime(CDFData.SEED_Time_Dt15_Good, 'ConvertFrom', ...
    'datenum');
dosimeterTime = datetime(CDFData.SEED_Dosimeter_Time, 'ConvertFrom', ...
    'datenum');

%Now replace them in the data structure.
CDFData.Epoch = epochTime;
CDFData.SEED_Time_Dt15_Good = SEEDGoodTime;
CDFData.SEED_Dosimeter_Time = dosimeterTime;


end  %End of the function importSEEDCDF1.m
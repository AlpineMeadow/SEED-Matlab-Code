%This script will move CDF files to a central location so that I can more
%easily load them into teams.

%Set up the year and its corresponding string.
year = 2023;
yearStr = num2str(year);

%Set up the starting and ending days of year.
startDayOfYear = 201;
endDayOfYear = 365;

%Set up the starting directory and file names.
startDirName = '/SS1/STP-H9/EPEE/';
startFileName = ['STP-H9_EPEE_', num2str(year), '*_'];

%Set the target directory.
targetDirectory = '/SS1/STP-H9/EPEE/';

%Loop through the day of year values.
for i = startDayOfYear : endDayOfYear

%    targetDirectory = [startDirName, num2str(year), '/L1/DayOfYear_', ...
%        num2str(i, '%03d')];
    %Create the day of year string.
%    dayOfYearStr = num2str(i, '%03d');

    %Find the month and day of month values for the day of year.
%    dateVector = datevec(datenum(year, 0, i));
%    month = dateVector(2);
%    dayOfMonth = dateVector(3);

    %Generate a date string.
%    dateStr = [yearStr, num2str(month, '%02d'), num2str(dayOfMonth, '%02d')];

    %Generate the filename corresponding to the day of year.
    fName = [startDirName, num2str(year), '/L2/DayOfYear_', ...
        num2str(i, '%03d'), '/*_L2.nc'];

    %Generate the directory name for the file to be moved.
%    dirName = [startDirName, dayOfYearStr, '/'];

    %Set the command.
    command = ['cp ', fName, ' ', targetDirectory];

    %Get Matlab to execute the command.
    status = system(command);

end  %End of for loop - for i = startDayOfYear : endDayOfYear

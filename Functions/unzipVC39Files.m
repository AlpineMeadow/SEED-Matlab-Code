%This script will unzip SEED files to a central location so that I do not
%have to do all 300+ of them by hand.

dbstop if error;

clearvars;
close all;
fclose('all');


%Set up the year and its corresponding string.
year = 2023;
yearStr = num2str(year);

%Set up the starting and ending days of year.
startDayOfYear = 1;
endDayOfYear = 135;

%Set up the starting directory and file names.
startDirName = '/SS1/STPSat-6/SEED/zips/';


%Get the file names using the dir command.
dirStruct = dir(startDirName);


%Loop through the files in the directory.
for fname = 3 : length(dirStruct) 
    filename = [dirStruct(fname). folder, '/', dirStruct(fname).name];
    command = ['gunzip ', filename];

    %Get Matlab to execute the command.
     status = system(command);
end
%Set the target directory.
%targetDirectory = '/SS1/STPSat-6/SEED/';

%Loop through the day of year values.
% for i = startDayOfYear : endDayOfYear
% 
%     %Create the day of year string.
%     dayOfYearStr = num2str(i, '%03d');
% 
%     %Find the month and day of month values for the day of year.
%     dateVector = datevec(datenum(year, 0, i));
%     month = dateVector(2);
%     dayOfMonth = dateVector(3);
% 
%     %Generate a date string.
%     dateStr = [yearStr, num2str(month, '%02d'), num2str(dayOfMonth, '%02d')];
% 
%     %Generate the filename corresponding to the day of year.
%     fName = [startFileName, dateStr, '_v01.cdf'];
% 
%     %Generate the directory name for the file to be moved.
%     dirName = [startDirName, dayOfYearStr, '/'];
% 
%     %Set the command.
%     command = ['cp ', dirName, fName, ' ', targetDirectory];
% 
%     %Get Matlab to execute the command.
%     status = system(command);
% 
% end  %End of for loop - for i = startDayOfYear : endDayOfYear

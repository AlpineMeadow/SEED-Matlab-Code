function info = generateLosAlamosInformation(dayOfYear, startYear, inputSEEDDataDir, ...
	inputDosimeterDataDir, outputDataDir);

%This function will fill the information structure.
%This function is called by LosAlamosNetCDFFiles.m

%Let's make some conversion factors.  These values convert the counts into
%Rads.  These are determined from the data itself.
Channel1CountsToRads = 1.0/2.47919e6;

info.channel1CountsToRads = Channel1CountsToRads;

%Handle the directories.
info.LosAlamosInputSEEDDataDir = inputSEEDDataDir;
info.LosAlamosInputDosimeterDataDir = inputDosimeterDataDir;
info.LosAlamosOutputDataDir = outputDataDir;

%Take care of the year and day of year
info.startYear = startYear;
info.startYearStr = num2str(startYear);
info.startDayOfYear = dayOfYear;
info.startDayOfYearStr = num2str(dayOfYear, '%03d');

%Determine the month and day of month for each day of year.    
startDateVector = datevec(datenum(startYear, 0, dayOfYear));
startMonth = startDateVector(2);
startDayOfMonth = startDateVector(3);

info.startMonth = startMonth;
info.startMonthStr = num2str(startMonth, '%02d');
info.startDayOfMonth = startDayOfMonth;
info.startDayOfMonthStr = num2str(startDayOfMonth, '%02d');

end  %End of the function generateDosimeterInformation.m

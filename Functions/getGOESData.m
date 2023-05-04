function GOESData = getGOESData(info, missionDayNum)

%This function is called by SEEDGOESSpaceWeatherMeeting.m
%This function will get the GOES-17 data for the day of interest.

%Convert mission day of year into year, month and day of month.
[year, month, dayOfMonth] = MDNToMonthDay(info, missionDayNum);
[dayOfYear, year] = MDNToDN(info, missionDayNum);

%Generate year, month, dayOfMonth and dayOfYear strings.
yearStr = num2str(year);
monthStr = num2str(month, '%02d');
dayOfMonthStr = num2str(dayOfMonth, '%02d');
dayOfYearStr = num2str(dayOfYear, '%03d');

GOESData.year = year;
GOESData.yearStr = yearStr;
GOESData.month = month;
GOESData.monthStr = monthStr;
GOESData.dayOfMonth = dayOfMonth;
GOESData.dayOfMonthStr = dayOfMonthStr;
GOESData.dayOfYear = dayOfYear;
GOESData.dayOfYearStr = dayOfYearStr;




%Set the filename for the data to be accessed.
fname = ['sci_mpsh-l2-avg1m_g17_d', yearStr, monthStr, ...
    dayOfMonthStr, '_v2-0-0.nc'];
filename = [info.STPSat6RootDir, 'AncillaryData/GOES17/', fname];

%Call the getNetCDFData function.  This returns the data attributes, the
%data dimensions and the data itself.
[Attributes, Dimensions, data] = getNetCDFData(filename);

%Fill the GOES data structure.

%The time for the data.  I do not know what this time is so the way to
%handle this is to subtract the first data point from all of the data
%points.
GOESData.time = data.time;  

%The averaged differential electron flux.  This is an array of 1440 times
%by 10 energy channels by 5 pitch angles.
GOESData.ElectronFlux = data.AvgDiffElectronFlux;

%The uncertainty in the averaged differential electron flux.  This is an
%array of 1440 times by 10 energy channels by 5 pitch angles.
GOESData.ElectronFluxUncertainty = data.AvgDiffElectronFluxUncert;

%The energy channel values for each of the 10 energy channels and 5 pitch
%angles.
GOESData.ElectronEnergy = data.DiffElectronEffectiveEnergy;

%The average integrated electron flux.  This contains 1440 time values and
%5 pitch angle values.
GOESData.AvgIntElectronFlux = data.AvgIntElectronFlux;

%The uncertainty of the average integrated electron flux.  This contains
%1440 time values and 5 pitch angle values.
GOESData.AvgIntElectronFluxUncertainty = data.AvgIntElectronFluxUncert;

end  %End of the function readGOESdata.m
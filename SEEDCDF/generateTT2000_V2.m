function [TT2000Time, UTCTime, TT2000SEEDCounts, TT2000DoseCounts, ...
    TT2000TempCounts] = generateTT2000_V2(info, time, SEEDCounts, ...
    DoseCounts, TempCounts, missionDayNumber)

%This function is called by exportSEEDCDF.m and generateSEEDCDF.m.
%This function will convert the GPS times to UTC time and then from UTC
%times to TT2000 times.

%Convert the mission day number into day, month and year.
[year, month, dayOfMonth] = MDNToMonthDay(missionDayNumber);

%I am trying to do this more simply.  The following command will give me an
%array of datetimes in UTC time for the data being analyzed.
UTCTime = datetime(1980, 1, 6, 'TimeZone', 'UTCLeapSeconds') + ...
    seconds(time);

%Lets check to see if the conversion from GPS to UTC gives us event times
%in the day before the actual day of interest.  This can happen because UTC
%is 18 seconds behind GPS.  If we have any of these then lets just get rid
%of them.  We do so by only keeping the dates with the correct day.
goodDayIndex = find(UTCTime.Day == dayOfMonth);

%Just take the data in the day being analyzed.
UTCTime = UTCTime(goodDayIndex);

%Here we just output the raw counts.
TT2000SEEDCounts = SEEDCounts(goodDayIndex, :);
TT2000DoseCounts = DoseCounts(goodDayIndex, :);
TT2000TempCounts = TempCounts(goodDayIndex);

%Calculate the TT2000 times.
%TT2000Time = convertTo(UTCTime, 'tt2000');
TT2000Time = spdfparsett2000(cellstr(UTCTime));

end  %End of the function generateTT2000_V2.m
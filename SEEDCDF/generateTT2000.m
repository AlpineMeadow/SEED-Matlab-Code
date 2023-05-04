function [TT2000Time, UTCTime, TT2000SEEDCounts, TT2000DoseCounts, ...
    TT2000TempCounts] = generateTT2000(info, time, SEEDCounts, ...
    DoseCounts, TempCounts)

%This function will convert the GPS times to UTC time and then from UTC
%times to TT2000 times.

%First step:  convert the integer seconds since Jan. 6, 1980 into
%fractional days since Jan. 6, 1980.
fractionalDays = time/86400.0;

%Second step:  We must anchor the fractional days to matlab
%time.  We do this in order to use Matlab's date and time functions.
%The way to do this is to add the number of fractional days to the Jan. 6,
%1980 epoch time. This places the original time vector into a time 
%measured in the matlab time coordinate frame.
epochTime = [info.epochYear, info.epochMonth, info.epochDayOfMonth, ...
                info.epochHour, info.epochMinute, info.epochSecond];
MatlabCoordinateTimeFractionalDays = fractionalDays + datenum(epochTime);

%Third step:  We now use the datenum function for the actual date being
%analyzed.  By subtracting the time of 0 hours, 0 minutes and 0 seconds 
%from the times values in the original time vector we end up with
%with the fractional days of the data.  Note: we use a month of zero in
%the dataDateTime vector.  This allows us to use day of year in the
%call to datenum.
dataDateTime = [info.startYear, 0, info.startDayOfYear, 0, 0, 0];
FractionalDaysTime = MatlabCoordinateTimeFractionalDays - datenum(dataDateTime);

%Fourth step:  We now convert from fractional days to fractional
%seconds by multiplying by 86400.0.
GPSTime = 86400.0*FractionalDaysTime;

%Fifth step:  We convert from GPS time into UTC time by subtracting 18 
%seconds.
rawTime = GPSTime - 18.0;

%Sixth step : The new rawTime can be less than zero! I am going
%to handle this by finding any negative values and just dropping them.
%This will drop, at most, 18 events.  Otherwise, we will have to move
%the negative events into the previous day.
goodDayIndex = find(rawTime > 0.0);

%Determine the number of events in the day.
numEvents = length(goodDayIndex);

%Finally we have the time in UTC seconds since the start of the day.
UTCTime = rawTime(goodDayIndex)';

%Here we just output the raw counts.
TT2000SEEDCounts = SEEDCounts(goodDayIndex, :);
TT2000DoseCounts = DoseCounts(goodDayIndex, :);
TT2000TempCounts = TempCounts(goodDayIndex);

%Now we want to convert this into the TT time.  In order to do this we need
%vectors of year, month, day, hours, minutes, seconds, milliseconds,
%microseconds and nanoseconds.
year = repmat(info.startYear, 1, numEvents);
month = repmat(info.startMonth, 1, numEvents);
day = repmat(info.startDayOfMonth, 1, numEvents);
hours = floor(UTCTime/3600);
minutes = floor((UTCTime - 3600*hours)./60.0);

realSeconds = UTCTime - 3600*hours - 60*minutes;
seconds = fix(realSeconds);

%First get rid of the stuff to the left of the decimal.
fractionalSeconds = realSeconds - fix(realSeconds);

%Now multiply by 1e9 to get all of the nanoseconds.
numNanoseconds = fix(1.0e9*fractionalSeconds);

%Now get the milliseconds.
milliseconds = fix(fix(numNanoseconds/1000)/1000);

%Now get the microseconds.
microseconds = fix(  (numNanoseconds - milliseconds*1e6)/1000 );

%Now get the nanoseconds
nanoseconds = fix( (numNanoseconds - milliseconds*1e6 - microseconds*1e3));

%Join the values into one large array.
Time = [year; month; day; hours; minutes; ...
    seconds; milliseconds; microseconds; nanoseconds];

%Transpose here because the spdf function expects each event as a single
%row.
Time = Time';

%Calculate the TT2000 times.
TT2000Time = spdfcomputett2000(Time);

end  %End of the function generateTT2000.m
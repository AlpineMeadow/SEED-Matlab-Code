function  [UTCTime, UTCDateNum, UTCCounts] = setDosimeterUTCTime(info, ...
                counts, time)

    %This function is called by dosimeterDoseTimeSeries.m
	
	%Return the data.
	%We need to deal with the times.  The time is given in integer seconds
	%since January 6, 1980 at 0:0:0.0.  This is GPS time.  It is not UTC
	%time.  These differ by 18 seconds.  GPS time is 18 seconds ahead of
	%UTC time.  This means that in order to get to UTC time I must subtract
	%18 seconds from GPS time.

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

	%Fifth step:  We convert from GPS time into UTC time by
	%subtracting 18 seconds.
	rawTime = GPSTime - 18.0;

	%Sixth step : The new rawTime can be less than zero! I am going
	%to handle this by finding any negative values and just dropping them.
	%This will drop, at most, 18 events.  Otherwise, we will have to move
	%the negative events into the previous day.  For this data set we are
    %interested in combining all of the data from all of the days and so
    %the whole argument above does not matter since I will not be
    %differentiating between days.  In the case where we are just looking
    %at a day's worth of data then this next command will get rid of
    %negative values(i.e. the data points coming from the previous day).
	goodDayIndex = find(rawTime > 0.0);

	%Finally we have the time we are interested in using.
	UTCTime = rawTime(goodDayIndex);

    %Here we just output the raw counts.
    UTCCounts = counts(goodDayIndex, :);

    %Now we generate the date numbers for the UTC times we have just
    %calculated.
    numEvents = length(goodDayIndex);
    year = repmat(info.startYear, 1, numEvents);
    month = repmat(info.startMonth, 1, numEvents);
    day = repmat(info.startDayOfMonth, 1, numEvents);
    hours = floor(UTCTime/3600);
    minutes = floor((UTCTime - 3600*hours)/60.0);
    seconds = UTCTime - 3600*hours - 60*minutes;

    UTCDateNum = datenum(year, month, day, hours', minutes', seconds');
    UTCDateNum = UTCDateNum';

end  %End of the function setDosimeterUTCTime.m



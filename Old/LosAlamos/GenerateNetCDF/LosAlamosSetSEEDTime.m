function [SEEDTime, SEEDCounts] = LosAlamosSetTime(info, data);

    %This function is called by getLosAlamosSEEDData.m
	
	%Return the data.
	%We need to deal with the times.  The time is given in integer seconds
	%since January 6, 1980 at 0:0:0.0.  This is GPS time.  It is not UTC
	%time.  These differ by 18 seconds.  GPS time is 18 seconds ahead of
	%UTC time.  This means that in order to get to UTC time I must subtract
	%18 seconds from GPS time.

	%First step:  convert the integer seconds since Jan. 6, 1980 into
	%fractional seconds since Jan. 6, 1980.
	FractionalSEEDTime = data.SEEDTime/86400.0;

	%Second step:  We must anchor the fractional SEED time to matlab
	%time.  We do this in order to use Matlab's date and time functions.
	%The way to do this is to add the number of days to the Jan. 6, 1980
	%epoch time to the fractional SEED time.  
	epochTime = [1980, 1, 6, 0, 0, 0];
	AnchoredFractionalSEEDTime = FractionalSEEDTime + datenum(epochTime);

	%Third step:  We now use the datenum function for the actual date being
	%analyzed.  By subtracting the datenum of the day in question we end up
	%with the fractional days of the data.  Note: we use a month of zero in
	%the dataDateTime vector.  This allows us to use day of year in the
	%call to datenum.
	dataDateTime = [info.startYear, 0, info.startDayOfYear, 0, 0, 0];
	FractionalDaysSEEDTime = AnchoredFractionalSEEDTime - datenum(dataDateTime);

	%Fourth step:  We now convert from fractional days to fractional
	%seconds by multiplying by 86400.0.
	GPSSEEDTime = 86400.0*FractionalDaysSEEDTime;

	%Fifth step:  We convert from GPS time into UTC time by
	%subtracting 18 seconds.
	rawSEEDTime = GPSSEEDTime - 18.0;

	%Sixth step : The new SEEDTime can be less than zero! I am going
	%to handle this by finding any negative values and just dropping them.
	%This will drop, at most, 18 events.  Otherwise, we will have to move
	%the negative events into the previous day.
	goodDayIndex = find(rawSEEDTime > 0.0);

	%Finally we have the time we are interested in using.
	SEEDTime = rawSEEDTime(goodDayIndex);

	%Here we just output the raw counts.
	SEEDCounts = data.SEEDData(goodDayIndex, :);

	

end  %End of the function LosAlamosSetTime.m
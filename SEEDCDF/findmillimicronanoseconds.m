%This script will figure out to strip off milliseconds, microseconds and
%nanoseconds from a given time in seconds

t = 1.987654321456;

%First get rid of the stuff to the left of the decimal.
fractionalSeconds = t - fix(t);

%Now multiply by 1e9 to get all of the nanoseconds.
IntegerSeconds = fix(1.0e9*fractionalSeconds)

%Now get the milliseconds.
milliseconds = fix(fix(IntegerSeconds/1000)/1000)

%Now get the microseconds.
microseconds = fix(  (IntegerSeconds - milliseconds*1e6)/1000 )

%Now get the nanoseconds
nanoseconds = fix( (IntegerSeconds - milliseconds*1e6 - microseconds*1e3))



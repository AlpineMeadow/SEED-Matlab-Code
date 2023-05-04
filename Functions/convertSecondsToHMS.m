function [hours, minutes, seconds] = convertSecondsToHMS(seconds)

%Convert seconds from a starting point to hours, minutes and seconds from
%the same starting point.

hours = floor(seconds/3600);
minutes = floor((seconds - 3600*hours)/60.0);
seconds = seconds - 3600*hours - 60*minutes;

end
function [hinsttime] = itime2htime(input, EPOCH, TICKSPERSEC)

SECS_PER_DAY = 86400;

dayspastepoch = input/(TICKSPERSEC * SECS_PER_DAY);
daysofepoch = datenum(EPOCH);

hinsttime = dayspastepoch + daysofepoch;

end


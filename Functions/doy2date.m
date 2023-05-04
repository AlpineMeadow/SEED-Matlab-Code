function [dateV] = doy2date(doyV, yearV)
z = zeros(length(yearV), 5);
dv = horzcat(yearV, z);
dateV = doyV + datenum(dv);
function value = isLeapYear(year)

%if year is a leap year return True
%        else return False """

firstTest = mod(year, 100);
if firstTest == 0 
    value = ~mod(year, 400);
else
    value = ~mod(year, 4);
end

end %End of function isLeapYear.m
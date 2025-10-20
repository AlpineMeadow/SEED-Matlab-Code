%Test the mission day number algorithm.

year = 2022;
for i = 15 : 365
    mdn = DNToMDN(i, year);
    [Year, month, day] = MDNToMonthDay(mdn);
    disp(['Day Number : ', num2str(i, '%03d'), ...
        ' Mission Day Number : ', num2str(mdn), ...
        ' Month : ', num2str(month, '%02d'), ' Day Of Month : ', ...
        num2str(day, '%02d')])
end
function stormDays = getStormDays(info)

%This function will output the storm dates for the duration of the SEED
%mission.  I have chosen only the top 10 storms for each year.  
%This function will be called by agu2025.m

%Set the months of the storms for each year.
stormMonth2022 = [11, 1, 3, 3, 4, 7, 10, 7, 1, 9];
stormMonth2023 = [4, 11, 4, 3, 2, 11, 3, 12, 12, 2];
stormMonth2024 = [5, 5, 10, 10, 8, 5, 10, 3, 8, 4];
stormMonth2025 = [1, 4, 6, 1, 6, 6, 6, 6, 1, 6];

%Set the days of month of the storms for each year.
stormDayOfMonth2022 = [7, 14, 14, 13, 14, 7, 22, 8, 15, 4];
stormDayOfMonth2023 = [24, 5, 23, 24, 27, 6, 23, 1, 2, 28];
stormDayOfMonth2024 = [11, 10, 11, 10, 12, 12, 8, 24, 13, 19];
stormDayOfMonth2025 = [1, 16, 1, 2, 2, 3, 13, 12, 4, 14];

%Set the day of year of the storms for each year.
stormDayOfYear2022 = [311, 14, 73, 72, 104, 188, 295, 189, 15, 247];
stormDayOfYear2023 = [114, 309, 113, 83, 58, 310, 82, 335, 336, 59];
stormDayOfYear2024 = [132, 131, 286, 285, 225, 133, 283, 84, 226, 110];
stormDayOfYear2025 = [1, 106, 152, 2, 153, 154, 164, 163, 4, 165];



%
MDN2022 = ones(10, 1);
MDN2023 = ones(10, 1);
MDN2024 = ones(10, 1);
MDN2025 = ones(10, 1);

for mdn = 1 : 10
    MDN2022(mdn) = DNToMDN(stormDayOfYear2022(mdn), 2022);
    MDN2023(mdn) = DNToMDN(stormDayOfYear2023(mdn), 2023);
    MDN2024(mdn) = DNToMDN(stormDayOfYear2024(mdn), 2024);
    MDN2025(mdn) = DNToMDN(stormDayOfYear2025(mdn), 2025);
end  %End of for loop - for mdn = 1 : 10

%Place the data into the structure.
stormDays.dayOfYear2022 = stormDayOfYear2022;
stormDays.dayOfYear2023 = stormDayOfYear2023;
stormDays.dayOfYear2024 = stormDayOfYear2024;
stormDays.dayOfYear2025 = stormDayOfYear2025;
stormDays.dayOfMonth2022 = stormDayOfMonth2022;
stormDays.dayOfMonth2023 = stormDayOfMonth2023;
stormDays.dayOfMonth2024 = stormDayOfMonth2024;
stormDays.dayOfMonth2025 = stormDayOfMonth2025;
stormDays.month2022 = stormMonth2022;
stormDays.month2023 = stormMonth2023;
stormDays.month2024 = stormMonth2024;
stormDays.month2025 = stormMonth2025;
stormDays.MDN2022 = MDN2022;
stormDays.MDN2023 = MDN2023;
stormDays.MDN2024 = MDN2024;
stormDays.MDN2025 = MDN2025;


end  %End of the function getStormDays.m
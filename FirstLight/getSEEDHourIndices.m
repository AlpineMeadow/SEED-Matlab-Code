function hourIndices = getSEEDHourIndices(info, timeStructure, numMissionDays)

%This function is called by plotSEEDLocalTimeEnergySpectra.m  It will
%generate a cell array of indicies that correspond to each hour (out of 24)
%concatenated together for each day being analyzed.

%Generate an array of size [number of days*24, 4] containing the following
%quantities.  First column contains day of year.  Second column contains
%the hour of the day for that day of year.  Third column contains the
%starting index in the dt vector corresponding to the day of year and hour
%of day in question and the fourth column contains the ending index in the
%dt vector corresponding to the day of year and hour of day.
hourIndex = zeros(numMissionDays*24, 4);

for i = info.startDayOfYear : info.endDayOfYear
    for j = 1 : 24
        firstIndex = 24*(i - info.startDayOfYear) + j;
        index = find(timeStructure.hour == (j - 1) & timeStructure.dayOfYear == i);

        if length(index) ~= 0
            hourIndex(firstIndex, 1) = i;
            hourIndex(firstIndex, 2) = j;
            hourIndex(firstIndex, 3) = index(1);
            hourIndex(firstIndex, 4) = index(end);
        else
            continue
        end
    end  %End of for loop - for j = 0 : 23
end  %End of for loop - for i = 1 : MissionDays

%Create a cell array that will hold all of the indices for a given hour.
hourIndices = cell(24);

%Loop through the data to find the indices for each hour.
for j = 1 : 24
    hIndex = find(hourIndex(:, 2) == j);

    if length(hIndex) ~= 0
        %Loop through all of the mission days.
        for i = 1 : length(hIndex)
        
            %Handle the first day separately.
            if i == 1
                if length(hourIndices{i}) ~= 0
                    hourIndices{j} = hourIndex(hIndex(i), 3) : hourIndex(hIndex(i), 4);
                else
                    hourIndices{j} = 1;
                end
            else
                hourIndices{j} = [hourIndices{j}, ...
                    hourIndex(hIndex(i), 3) : hourIndex(hIndex(i), 4) ];
           
            end  %End of if-else clause - if i == 1
        end  %End of for loop - for i = 1 : numMissionDays
    else
        hourIndices{j} = 1;
    end %End of if-else statement - if length(hIndex) ~= 0
end  %End of for loop - for j = 1 : 24

end  %End of the function getSEEDHourIndices.m
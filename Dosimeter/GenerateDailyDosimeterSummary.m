%This script will run through all of the days and plot the summary
%dosimeter data.


startDoy = 286;
endDoy = 289;

for doyIndex = startDoy : endDoy
    disp(['Day of Year : ', num2str(doyIndex)]);
    everyL1DailyDosimeter(doyIndex);

end  %End of for loop - for doyIndex = startDoy : endDoy

function [timeStart, timeEnd, xTickValues, xLimValues, additionalAxisTicks, ...
	yTickValues, yLimValues] = getPlottingParameters(info, numHoursToPlot)



if(numHoursToPlot < 6)
    timeStart = info.startHour;
    timeEnd = info.endHour + 1;

    xTickValues = [info.startHour, info.startHour + [1, 2, 3, 4, 5, 6]]; 
    xLimValues = [timeStart, timeEnd]; 
    
    additionalAxisTicks = {[xTickValues + 18]};
    highIndex = find(cell2mat(additionalAxisTicks) > 24);
%    additionalAxisTicks(highIndex) = cell2mat(additionalAxisTicks) - 24; 
end



if(numHoursToPlot > 6 & numHoursToPlot <= 12)
    timeStart = info.startHour;
    timeEnd = info.endHour + 1;

    xTickValues = [info.startHour, info.startHour + [2, 4, 6, 8, 10, 12]]; 
    xLimValues = [timeStart, timeEnd]; 
    
    additionalAxisTicks = {[xTickValues + 18]};
    highIndex = find(additionalAxisTicks > 24)
    additionalAxisTicks(highIndex) = additionalAxisTicks - 24; 
end

if(numHoursToPlot > 12)
    timeStart = info.startHour;
    timeEnd = info.endHour + 1;

    xTickValues = [1 3 5 7 9 11 13 15 17 19 21 23]; 
    xLimValues = [0, 24]; 

    additionalAxisTicks = {[19 21 23 1 3 5 7 9 11 13 15 17]};
end

energyRange = info.endEnergy - info.startEnergy;   
if energyRange > 125
	yTickValues = [20, 40, 60, 80, 100, 120, 140];
else
	yTickValues = [info.startEnergy + 1 : fix(energyRange/8) : info.endEnergy];
end

yLimValues = [info.startEnergy, info.endEnergy];


end %End of the function getPlottingParameters.m
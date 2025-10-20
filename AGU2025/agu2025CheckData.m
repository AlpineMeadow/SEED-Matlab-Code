function agu2025CheckData(info, data)

visibleFlag = 1;

if visibleFlag == 1
    fig1 = figure('DefaultAxesFontSize', 12);
else
    fig1 = figure('DefaultAxesFontSize', 12, 'visible', 'off');
end

%Set up a set of axes for the plot.  Also, set the positions for both the
%figure and the axes.
ax = axes();
fig1.Position = [750 25 1200 500];

position = [0.01, 0.9];
position1 = [0.6, 0.9];
position2 = [0.6, 0.85];
position3 = [0.6, 0.8];

fontsize = 15;

dayNum1 = 2;
dayNum2 = 3;
dayNum3 = 4;

dateStr1 = string(data(dayNum1).Time(1));
dateStr2 = string(data(dayNum2).Time(1));
dateStr3 = string(data(dayNum3).Time(1));

color1 = 'red';
color2 = 'blue';
color3 = 'green'; 
color = 'black';

energyIndex = 150;
energyBin = info.energyBins(energyIndex);
energyBinStr = ['Energy : ', num2str(energyBin, '%5.2f'), ' keV'];
titStr = ['Plot of SEED Counts Versus Time '];

Counts1 = data(dayNum1).Counts(:, energyIndex);
Counts2 = data(dayNum2).Counts(:, energyIndex);
Counts3 = data(dayNum3).Counts(:, energyIndex);

%Now check to see if we have absurdly large counts.
Counts1(Counts1 > 500) = 0;
Counts2(Counts2 > 500) = 0;
Counts3(Counts3 > 500) = 0;

time1 = data(dayNum1).Time;
time2 = data(dayNum2).Time - hours(24*(dayNum2 - dayNum1));
time3 = data(dayNum3).Time - hours(24*(dayNum3 - dayNum1));

plot(time1, Counts1, 'r-*', time2, Counts2, 'b', time3, Counts3, 'g')
xlabel('Time (UTC)')
ylabel('Counts')
title(titStr)
plotText(ax, position1, dateStr1, color1, fontsize)
plotText(ax, position2, dateStr2, color2, fontsize)
plotText(ax, position3, dateStr3, color3, fontsize)
plotText(ax, position, energyBinStr, color, fontsize)

end  %End of the function agu2025CheckData.m
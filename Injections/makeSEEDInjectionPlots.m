function makeSEEDInjectionPlots(missionDayNumber, info, visibleFlag)


%This function is called by Injection.m.

%Set the figure position information.
left = 750;
bottom = 25;
width = 1200;
height = 500;

%Set up the figure handle.
fig1 = figure();
fig1.Position = [left bottom width height];
ax1 = gca();
    
%Read a cdf file.  The times that are read in are converted to Matlab's
%datenum time automatically.
[CDFInfo, CDFData] = importSEEDCDF1(info, missionDayNumber);

%Pull the counts and time out of the structure.
time = CDFData.SEED_Time_Dt15_Good;
counts = CDFData.SEED_Electron_Counts_Dt15_Good;

ttDatetime = datetime(time,'ConvertFrom','datenum');

timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
    ttDatetime.Second;

%Convert from the datetime structure into seconds from start of the day.
%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;

numEnergyBins = 904;

%Set up an interpolated flux array of size [5760,904]
interpCounts = zeros(length(tt), 904);

smoothConstant = 50;

%Now we loop through the energy channels.
for e = 1 : 904
    y = double(counts(:, e));
    interpCounts(:, e) = smoothdata(interp1(timeSeconds, y, tt, 'linear'), ...
        'gaussian', smoothConstant);
end

SEEDEnergyBins = generateSEEDEnergyBins(121, 1);


%Let us make a spectrogram of the counts.
dateFormat = "HH:MM:SS";

%Choose a time to plot.
timeIndex = 366;

%Set up a string for that time.
timeStr = datestr(time(timeIndex));

sp1 = subplot(3, 1, 1);
imagesc(time, info.energyBins(:, 2), counts')
set(gca,'YDir','normal')
datetick('x', dateFormat, 'keeplimits', 'keepticks')
hold on
plot([time(362), time(362)], [0, 150], 'r', [time(368), time(368)], ...
    [0, 150], 'r')

sp2 = subplot(3, 1, 2);
imagesc(time(360:370), info.energyBins(:, 2), counts(360:370, :)')
set(gca,'YDir','normal')
datetick('x', dateFormat, 'keeplimits', 'keepticks')

counts = double(counts);
sp3 = subplot(3, 1, 3);
% for e = 1 : numEnergyBins
%     sigmaCounts = sqrt(counts(366, e));
% 
%     yyy = semilogy(ax, [SEEDEnergyBins(e, 1), SEEDEnergyBins(e, 3)], ...
%         [counts(366, e), counts(366, e)], 'black', ...
%         [SEEDEnergyBins(e, 2), SEEDEnergyBins(e, 2)], ...
%         [counts(366, e) - sigmaCounts, ...
%         counts(366, 3) + sigmaCounts], 'black');
% end
plot(SEEDEnergyBins(:,2), counts(366, :))
title('Flux Versus Energy')
xlabel('Energy (keV)')
ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
ylim([0 200])
%yticks([3 4 5 6 7 8])
%yticklabels({'3' '4', '5', '6', '7', '8'})
xlim([10 150])
xticks(linspace(10, 150, 15))
xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
    '100', '110', '120', '130', '140', '150'})
text('Units', 'Normalized', 'Position', [0.65, 0.9], 'string', timeStr, ...
    'FontSize', 15);


%Convert the counts for 904 energies to counts for 91 energies.
newSEEDCounts = getSEEDEnergy(info, counts);

%Convert the counts to flux.  
flux = getSEEDInjectionFlux(info, time, newSEEDCounts);

%Determine the number of events and energy bins.
[numEvents, numEnergyBins] = size(flux.fluxActual);

%Choose a time to plot.
timeIndex = 366;

%Set up a string for that time.
timeStr = datestr(time(timeIndex));

%Plot the energy spectra for specific times.



%Set up the figure handle.
fig2 = figure();
fig2.Position = [left bottom width height];
ax2 = gca();
   
%Set the y axis limits.
yMin = 4;
yMax = 9;

satellite = "Falcon";
instrument = "SEED";
plotType = "EnergySpectra";
startDate = [info.startYearStr, info.startMonthStr, info.startDayOfMonthStr];
startDayOfYear = info.startDayOfYearStr;

titleStr = satellite + " " + instrument + " " + "Energy Spectra" + " " + ...
    startDate + " " + startDayOfYear;
    
saveName = satellite + instrument + plotType + startDate + "_" + startDayOfYear;

outFileName = strcat('/SS1/STPSat-6/Plots/Injection/', saveName, '.png');

hold on

showMovie = 1;

if showMovie == 1
    for t = 300 : 700
        fl = log10(flux.fluxLow(t, :));
        f = log10(flux.fluxActual(t, :));
        fh = log10(flux.fluxHigh(t, :));
        timeStr = ['Index : ', num2str(t), ' ', datestr(time(t))];
        for e = 1 : numEnergyBins
            yyy = semilogy(ax2, [info.energyBins(e, 1), ...
                info.energyBins(e, 3)], [f(e), f(e)], 'black', ...
                [info.energyBins(e, 2), info.energyBins(e, 2)], ...
                [fh(e), fl(e)], 'black');

        end
        title(titleStr)
        xlabel('Energy (keV)')
        ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
        ylim(ax2, [3 9])
        yticks([3 4 5 6 7 8])
        yticklabels({'3', '4', '5', '6', '7', '8'})
        xlim([10 150])
        xticks(linspace(10, 150, 15))
        xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
            '100', '110', '120', '130', '140', '150'})
        text('Units', 'Normalized', 'Position', [0.65, 0.9], 'string', timeStr, ...
        'FontSize', 15);

        j = 23;

        %Clear the current axes.
        cla();
    end
end

%Set the upper and lower flux values.
fl = log10(flux.fluxLow(timeIndex, :));
f = log10(flux.fluxActual(timeIndex, :));
fh = log10(flux.fluxHigh(timeIndex, :));

for e = 1 : numEnergyBins
    yyy = semilogy(ax, [info.energyBins(e, 1), info.energyBins(e, 3)], ...
        [f(e), f(e)], 'black', [info.energyBins(e, 2), info.energyBins(e, 2)], ...
        [fh(e), fl(e)], 'black');
end
title(titleStr)
xlabel('Energy (keV)')
ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
ylim(ax, [yMin yMax])
yticks([4 5 6 7 8])
yticklabels({'4', '5', '6', '7', '8'})
xlim([10 150])
xticks(linspace(10, 150, 15))
xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
    '100', '110', '120', '130', '140', '150'})
text('Units', 'Normalized', 'Position', [0.65, 0.9], 'string', timeStr, ...
    'FontSize', 15);

%Save the spectra to a file.
saveas(fig1, outFileName);

end  %End of the function makeSEEDInjectionPlots.m
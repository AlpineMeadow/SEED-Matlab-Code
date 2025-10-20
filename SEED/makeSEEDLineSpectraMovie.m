function makeSEEDLineSpectraMovie(info, CDFData, dataTypeFlag)


%This function is called by SEEDCDFDataAnalysis.m

%We want to look at the delta t = 15 seconds data.  Recall that the time is
%in matlab datenums.
if strcmp(dataTypeFlag, 'dt15Data')
    t = CDFData.SEED_Time_Dt15_Good;
    counts = CDFData.SEED_Electron_Counts_Dt15_Good;
else
    t = CDFData.Epoch;
    counts = CDFData.SEED_Electron_Counts_Total;
end

%Generate new counts depending on the number of energy channels to sum.
newCounts = getSEEDEnergy(info, counts);

%Determine the number of energy channels and the number of events.
[numEvents, numEnergyBins] = size(newCounts);

%Convert from datenums to matlab's datetime.
time = datetime(t, 'ConvertFrom', 'datenum');

%Convert the datetime into seconds from the start of the day.
timeSeconds = time.Hour*3600 + time.Minute*60 + time.Second;

%Convert from counts to flux.  
flux = getCDFSEEDFlux1(info, timeSeconds, newCounts, dataTypeFlag); 

%Now make a movie of the energy spectra for a whole day.
saveMovieName = ['SEEDEnergySpectraPerTime_', info.startDayOfYearStr, '_', ...
	num2str(info.startHour, '%02d'), '_', num2str(info.endHour, '%02d')];

fig2FileName = strcat(info.SEEDPlotDir, 'Movies/', saveMovieName, '.avi');

%Set the figure position information.
left = 750;
bottom = 25;
width = 1200;
height = 500;

%Set up the figure handle.
fig2 = figure();
fig2.Position = [left bottom width height];
ax = gca();
    
%Set the gcf position.
set(gcf, 'Position', [left bottom width height]);

%Hold the figure handle parameters for all of the frames to UTCTime be plotted.
%This is because the video writer needs to have the same size for each
%frame to be saved. Not sure why matlab is changing the sizes.
hold on;

%Check to see if the file already exists.  If it does then delete it.
%Otherwise Matlab cannot handle the video writing.
if exist(fig2FileName, 'file') == 2
    %First delete the file if it exists.
    delete(fig2FileName);
end

%Let's find the energy channels of interest.
energyIndex = find(info.energyBins(:, 2) >= info.startEnergy & ...
    info.energyBins(:, 2) <= info.endEnergy);

%Set up the x-axis labels and limits.
xTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
xLimValues = [info.energyBins(energyIndex(1), 1), info.energyBins(energyIndex(end), 3)];
xTickValues = [20, 40, 60, 80, 100, 120, 140];

%Set out the high and low fluxes.
measuredFlux = log10(flux.fluxActual);
lowFlux = log10(flux.fluxLow);
highFlux = log10(flux.fluxHigh);

%Find the starting and ending times.
startDateNum = datenum([info.startYear, info.startMonth, info.startDayOfMonth, ...
                      info.startHour, info.startMinute, info.startSecond]);

endDateNum = datenum([info.startYear, info.startMonth, info.startDayOfMonth, ...
                      info.endHour, info.endMinute, info.endSecond]);

%Set up starting and stopping indices depending on the time specified by
%the user.CDFData.SEED_Time_Dt15_Good
goodTimeIndex = find(CDFData.SEED_Time_Dt15_Good >= startDateNum & ...
    CDFData.SEED_Time_Dt15_Good <= endDateNum);

%Set the y axis limits.
yMin = 4;
yMax = 9;

%Set up a number of times to skip.
step = info.numTimeStepsToSkip;

%Generate a videoWriter object.
v = VideoWriter(fig2FileName);

%Open the videoWriter object.
open(v);

%Loop through all of the time samples.
for tIndex = goodTimeIndex(1) : step : goodTimeIndex(end)

    %Generate a time string.
    dt = datetime(CDFData.SEED_Time_Dt15_Good(tIndex), 'ConvertFrom', 'datenum');
    timeStr = [num2str(dt.Hour, '%02d'), ':', num2str(dt.Minute, '%02d'), ...
         ':', num2str(dt.Second, '%4.2f')];

    %Generate a title string.
    titStr = ['SEED Energy Spectra DOY : ', info.startDayOfYearStr, ' Time - ', ...
        timeStr, ' (UTC)'];

    %Calculate the log of the flux.
    f = measuredFlux(tIndex, :);
    lF = lowFlux(tIndex, :);
    hF = highFlux(tIndex, :);

    for e = 1 : numEnergyBins 
        yyy = semilogy(ax, [info.energyBins(e, 1), info.energyBins(e, 3)], ...
            [f(e), f(e)], 'black', [info.energyBins(e, 2), info.energyBins(e, 2)], ...
            [hF(e), lF(e)], 'black');

    end

    title(titStr)
    xlabel('Energy (keV)')
    ylabel('Log_{10} Flux (Counts  s^{-1} keV^{-1} st^{-1})')
    ylim(ax, [yMin yMax])
    yticks([4 5 6 7 8])
    yticklabels({'4', '5', '6', '7', '8'})
    xlim([10 150])
    xticks(linspace(10, 150, 15))
    xticklabels({'10', '20', '30', '40', '50', '60', '70', '80', '90',...
        '100', '110', '120', '130', '140', '150'})

    %drawnow;

    %Write the frame to the movie file.
    writeVideo(v, getframe(gcf));

    %Clear the current axes.
    cla();


end  %end of for loop - for tIndex = 1 : step : m

%Close the current axes.
close(gcf)

%Close the videoWriter.
close(v);

end  %End of the function makeLineSpectraMovies.m


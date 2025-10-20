%This script will do the analysis for the Fall 2025 AGU Meeting, if I ever
%actually go to it.

%I will read in all of the data for the first 1300 days of the mission and
%then rebin them into bins of 1 minute time intervals and various energy
%intervals.  I will then correlate these data with SuperMag data.

dbstop if error;

clearvars;
close all;
fclose('all');

%Set the day of year and the year.
startDayOfYear = 198;
endDayOfYear = 223;
startYear = 2024;
endYear = 2024;

%Set up a starting time and ending time for the data analysis.
startHour = 0;
startMinute = 0;
startSecond = 0.0;
endHour = 23;
endMinute = 59;
endSecond = 59.0;

%The energy bin number at which to start the data analysis. This will give
%904 energy bins, which is the number of bins in the CDF file.
startEnergyBinNumber = 121;  

%The number of energy bins to sum.
numEnergyBinsToSum = 1;  

%The number of time bins to sum. This needs to remain set to 1.
numTimeBinsToSum = 1;  

%We will skip time steps in the makeLineSpectraMovie function.  Let us
%decide how many steps to skip.
numTimeStepsToSkip = 1;

%Pick the energy range of interest.  The values will be in keV.
startEnergy = 20.0;
endEnergy = 150.0;

%We need to generate a variable that will contain the data version number
%for the CDF files.  This will be used for this program but not in others
%that use the info structure.  
CDFDataVersionNumber = 2;

%Generate a structure that holds all of the information needed to do the
%analysis.
instrument = 'SEED';
info = generateInformationStructure(instrument, startDayOfYear, ...
    startYear, startHour, startMinute, startSecond, endDayOfYear, ...
    endYear, endHour, endMinute, endSecond, startEnergyBinNumber, ...
    startEnergy, endEnergy, numEnergyBinsToSum, numTimeBinsToSum, ...
    numTimeStepsToSkip, CDFDataVersionNumber);

%Loop through the day of interest.
for missionDayNumber = info.startMissionDayNumber : info.endMissionDayNumber
    
    %Check to see if the mission day number is in the list of bad mission
    %day numbers.
    badDayIndex = find(missionDayNumber == info.SEEDBadDays);

    dayIndex = missionDayNumber - info.startMissionDayNumber + 1;

    %If the mission day number is bad, skip it and move on to the next one.
    if length(badDayIndex) >= 1
        continue
    else
        %Read a cdf file.  The times that are read in are converted to
        %Matlab's datenum time automatically.
        [CDFInfo, CDFData] = importSEEDCDF1(info, missionDayNumber);

        %Get the SuperMag data.
        SMData = getSuperMagData(info, missionDayNumber);

        %Fill the electron data into the data structure.
        data(dayIndex).electronCounts = CDFData.SEED_Electron_Counts_Dt15_Good;
        data(dayIndex).electronTime = CDFData.SEED_Time_Dt15_Good;
    
        %Fill the SuperMag data into the data structure.
        data(dayIndex).SMTime = SMData.time;
        data(dayIndex).SMR = SMData.SMR;
        data(dayIndex).SMR00 = SMData.SMR00;
        data(dayIndex).SMR06 = SMData.SMR06;
        data(dayIndex).SMR12 = SMData.SMR12;
        data(dayIndex).SMR18 = SMData.SMR18;
        data(dayIndex).GSEBx = SMData.GSEBx;
        data(dayIndex).GSEBy = SMData.GSEBy;
        data(dayIndex).GSEBz = SMData.GSEBz;
        data(dayIndex).GSEVx = SMData.GSEVx;
        data(dayIndex).GSEVy = SMData.GSEVy;
        data(dayIndex).GSEVz = SMData.GSEVz;
        data(dayIndex).density = SMData.density;
        data(dayIndex).dynamicPressure = SMData.dynamicPressure;

    end %End of if-else clause - if length(badDayIndex) >= 1

end  %End of for loop - for missionDayNumber = 
%              info.startMissionDayNumber : info.endMissionDayNumber

%Make a plot to see that we are doing what we want.
%agu2025CheckData(info, data)

%Now lets add the data in energy.  Because these are in counts we can
%simply add them together.  We will make 4 separate energies.  This is
%determined by using the energy bin width of a single energy channel which
%is 0.1465 keV.  
% Number of energy Bins to Add = round((1.0/0.1465)*Energy Bin width)  
% Energy Bin width |  Number of Energy Bins to Add
%     1 keV        |    7 energy  bins - With 1 left over. 
%     5 keV        |    34 energy bins - With 20 left over.
%     10 keV       |    68 energy bins - With 20 left over.
%     25 keV       |    170 energy bins - With 54 left over.
%I think that it is slightly better to not add in the left over counts so I
%will just ignore them.

lowEnergy1 = 1 : 7 : 903;
highEnergy1 = 7 : 7 : 904;

lowEnergy5 = 1 : 34 : 903;
highEnergy5 = 34 : 34 : 904;
%Remove the last entry in the lowEnergy5 array.
lowEnergy5 = lowEnergy5(1 : end - 1);

lowEnergy10 = 1 : 68 : 903;
highEnergy10 = 68 : 68 : 904;
%Remove the last entry in the lowEnergy10 array.
lowEnergy10 = lowEnergy10(1 : end - 1);

lowEnergy25 = 1 : 170 : 903; 
highEnergy25 = 170 : 170 : 903;
%Remove the last entry in the lowEnergy25 array.
lowEnergy25 = lowEnergy25(1 : end - 1);


%Next we do the time.  This is much trickier.  Optimally we would like to
%simply add all of the time intervals into a single 1 minute bin.  This
%means that we would get 1440 time intervals per day.  However, there are
%definitely times when we do not have counts over more than the length of a
%minute.  My feeling is that the best thing to do is to skip any 1 minute
%intervals that do not have any counts.  The other option is to set any 1
%minute intervals that do not have any counts to zero.  This is technically
%true but we are missing counts due to instrumental issues not because
%there are not actually any counts.  However, since I am going to do a
%correlation integral to compare to SuperMag data which does definitely
%have 1440 data points per day I will need to do something or else I will
%not be able to do the correlation.  In talking with Geoff, we have decided
%to first try to put in NaN's for the missing data points.  The second
%possibility is to try to interpolate the points that are missing.  This is
%do-able but it suffers if the missing points are sequential.  Another less
%liked option is to replace the missing data points with the average of the
%present data points but this is really not okay to do.

tLow = 1 : 60 : 1440;
tHigh = 60 : 60 : 1440;
lowHourIndex = zeros(24, 1);
highHourIndex = zeros(24, 1);

lowMinuteIndex = zeros(1440, 1);
highMinuteIndex = zeros(1440, 1);
counts = nan(1440, 904);
tVec = NaT(1440, 1);

%We need two indices here, one for looping up to 1440 and the other for
%looping up to the number of time intervals that contain data.
masterIndex = 0;
timeIndex = 0;

% for h = 1 : 24
%     for m = 1 : 60
%         masterIndex = masterIndex + 1;
%         hourMinuteIndex = find( data(1).Time.Hour == h - 1 & ...
%                                 data(1).Time.Minute == m - 1);
% 
%         if length(hourMinuteIndex) ~= 0
%             timeIndex = timeIndex + 1;
%             for e = 1 : 904
%                 counts(timeIndex, e) = sum(data(1).Counts(hourMinuteIndex(1) : ...
%                     hourMinuteIndex(end), e));
%             end 
% %            disp(['Index : ', num2str(masterIndex)])
% %            disp(['Number of Data Points : ', num2str(length(hourMinuteIndex))])
%             lowMinuteIndex(masterIndex) = hourMinuteIndex(1);
%             highMinuteIndex(masterIndex) = hourMinuteIndex(end);
%             tVec(masterIndex) = data(1).Time(timeIndex);
%         end
%     end
% end
    

%Lets check the nanxcov function.
x1 = data(1).SMR00;
x2 = data(1).SMR00;

x1(100) = NaN;
covSMR1 = nanxcov(x1, x2);
covSMR2 = nanxcov(data(1).SMR00, data(1).SMR00);


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

l = length(data(1).SMR00);
lags = -(l - 1) : l - 1;

plot(lags(2:end - 1), covSMR1, 'b-*', lags, covSMR2, 'r')
xlabel('Time (UTC)')
ylabel('Cross Correlation')
xlim([lags(1) lags(end)])
title('Cross Correlation')
xlabel('Lag Time (minutes)')
ylabel('Cross Correlation Value')


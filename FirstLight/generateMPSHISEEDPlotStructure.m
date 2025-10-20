function plotStructure = generateMPSHISEEDPlotStructure(info, TimeStructure, ...
    numDaysMPSHI, dt, MPSHIData, MPSHIEnergyBins, CDFData)

%Generate a structure to hold some plotting information.
plotStructure.satellite = "GOES";
plotStructure.instrument = "MPS-HI";

dateStr = [num2str(TimeStructure.year(1)), ...
    num2str(TimeStructure.month(1), '%02d'), ...
    num2str(TimeStructure.dayOfMonth(1), '%02d'), '-', ...
    num2str(TimeStructure.year(end)), ...
    num2str(TimeStructure.month(end), '%02d'), ...
    num2str(TimeStructure.dayOfMonth(end), '%02d')];

plotStructure.dateStr = dateStr;

doyStr = [num2str(TimeStructure.dayOfYear(1), '%03d'), '-', ...
    num2str(TimeStructure.dayOfYear(end), '%03d')];

plotStructure.doyStr = doyStr;

%Now set the time axis labels for the SEED data.
xTickValuesSEED = zeros(1, numDaysMPSHI);
xTickLabelsSEED = cell(1, numDaysMPSHI);

for i = 1 : numDaysMPSHI
    xTickValuesSEED(i) = datenum(datetime(TimeStructure.year(i), ...
        TimeStructure.month(i), TimeStructure.dayOfMonth(i), ...
        0, 0, 0));
    xTickLabelsSEED(i) = cellstr(char(datetime(xTickValuesSEED(i), ...
        'ConvertFrom', 'datenum')));
end

xLimValuesSEED = [dt(1), dt(end)];

plotStructure.xTickValuesSEED = xTickValuesSEED;
plotStructure.xTickLabelsSEED = xTickLabelsSEED;
plotStructure.xLimValuesSEED = xLimValuesSEED;

dateFormat = 'dd/mm/yyyy';
plotStructure.dataFormat = dateFormat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  GOES x and y tick labels and values  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yTickLabelsMPSHI = {num2str(MPSHIData(1).ElectronEnergy(:, 1), '%5.1f')};

%Set the y limit values such that the first and last tickmarks are not
%exactly at the vertical edges.  Since we are doing log plotting we are not
%symmetrical.
yLimValuesMPSHI = [0.95*MPSHIEnergyBins(1), 1.01*MPSHIEnergyBins(end)];

yTickValuesMPSHI = MPSHIEnergyBins;

%Now set the time axis labels for the GOES data.
xTMPSHI = {[40:1:58]};
xTickValuesMPSHI = zeros(1, numDaysMPSHI);
xTickLabelsMPSHI = cell(1, numDaysMPSHI);

for i = 1 : numDaysMPSHI
    xTickValuesMSPHI(i) = datenum(datetime(TimeStructure.year(i), ...
        TimeStructure.month(i), TimeStructure.dayOfMonth(i), ...
        0, 0, 0));
    xTickLabelsMSPHI(i) = cellstr(char(datetime(xTickValuesMPSHI(i), ...
        'ConvertFrom', 'datenum')));
end

xLimValuesMPSHI = [dt(1), dt(end)];

plotStructure.xTickLabelsMPSHI = xTickLabelsMPSHI;
plotStructure.xTickValuesMPSHI = xTickValuesMPSHI;
plotStructure.xLimValuesMPSHI = xLimValuesMPSHI;
plotStructure.yTickLabelsMPSHI = yTickLabelsMPSHI;
plotStructure.yTickValuesMPSHI = yTickValuesMPSHI;
plotStructure.yLimValuesMPSHI = yLimValuesMPSHI;

MPSHIEnergy1Str = ['MPS-HI Energy : ', ...
    num2str(MPSHIData(1).ElectronEnergy(1, 1), '%3.1f'), ' keV'];
MPSHIEnergy2Str = ['MPS-HI Energy : ', ...
    num2str(MPSHIData(1).ElectronEnergy(2, 1), '%3.1f'), ' keV'];
SEEDEnergy1Str = ['SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(407), '%3.1f'), ' keV'];
SEEDEnergy2Str = ['SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(782), '%3.1f'), ' keV'];

weightedSEEDEnergy1Str = ['Weighted SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(407), '%3.1f'), ' keV'];
weightedSEEDEnergy2Str = ['Weighted SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(782), '%3.1f'), ' keV'];
averageSEEDEnergy1Str = ['Average SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(407), '%3.1f'), ' keV'];
averageSEEDEnergy2Str = ['Average SEED Energy : ', ...
    num2str(CDFData(1).SEED_Energy_Channels(782), '%3.1f'), ' keV'];

plotStructure.MPSHIEnergy1Str = MPSHIEnergy1Str;
plotStructure.MPSHIEnergy2Str = MPSHIEnergy2Str;
plotStructure.SEEDEnergy1Str = SEEDEnergy1Str;
plotStructure.SEEDEnergy2Str = SEEDEnergy2Str;
plotStructure.weightedSEEDEnergy1Str = weightedSEEDEnergy1Str;
plotStructure.weightedSEEDEnergy2Str = weightedSEEDEnergy2Str;
plotStructure.averageSEEDEnergy1Str = averageSEEDEnergy1Str;
plotStructure.averageSEEDEnergy2Str = averageSEEDEnergy2Str;

end  %End of the function generateMPSHISEEDPlotStructure.m
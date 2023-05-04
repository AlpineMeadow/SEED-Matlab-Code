%% MATLAB housekeeping
clear all;
close all;
fclose('all');

doy = 124;
year = 2022;

toptimestamp = now;
nctimestamp = datestr(toptimestamp);

 
all_source_files = {};
SECS_PER_DAY = 86400;
NUM_ENERGY_BINS = 1024;
NUM_DOSIMETER_ADC_BINS = 16384;

% Select L1 files.
PathName = ['/SS1/STPSat-6/L1/DayOfYear_', num2str(doy, '%03d')];
month = datestr(doy2date(doy, year), 'mm');
day = datestr(doy2date(doy, year), 'dd');
doyStr = num2str(doy, '%03d');

L1files = ['STPSat-6_FalconSEED_2022', month, day, '_', doyStr, '_L1.nc'];

% Write the filepath/names to a cell array.
%cd(PathName);

% Extract, plot, and save the plot for the radiation detector energy-time spectrogram
% Open each file in turn.
fpn = fullfile(PathName,L1files);
ncid_L1 = netcdf.open(fpn,'NOWRITE');

%disp(['STATUS: Opened ',L1files,' for reading.']);
% Read the number of dimensions, variables, and attributes to make sure
% it's not an empty file.
[ndims,nvars,natts,unlimdimID] = netcdf.inq(ncid_L1);
if (ndims == 0) || (natts == 0) || (nvars == 0)
    error('ERROR: L1 file has insufficient fields to proceed.');
end

% Read in the L1 file attributes into a temporary structure and extract.
for j=0:natts-1
    attname = ['att',num2str(j)];
    L1_att_name.(attname) = netcdf.inqAttName(ncid_L1,netcdf.getConstant('NC_GLOBAL'),j);
    L1_att_val.(attname) = netcdf.getAtt(ncid_L1,netcdf.getConstant('NC_GLOBAL'), ...
					 L1_att_name.(attname));
    QDVatt.(L1_att_name.(attname)) = L1_att_val.(attname); 
end

% Read in the L1 file dimensions into a temporary structure
for j=0:ndims-1
    dimname = ['dim',num2str(j)];
    [L1_dim_name.(dimname),L1_dim_len.(dimname)] = netcdf.inqDim(ncid_L1,j);
end

% Read in the L1 file variables into a temporary structure
for j=0:nvars-1
    varname = ['var',num2str(j)];
    L1_var_name.(varname) = netcdf.inqVar(ncid_L1,j);
    L1_var_val.(varname) = netcdf.getVar(ncid_L1,j);
    QDVvar.(L1_var_name.(varname)) = L1_var_val.(varname);
end


%% Plot telemetry points of interest
% Start and stop times of data as "seconds of day"
tstart = QDVvar.TYPE1_PKT_DATA_TIME_ARRAY(1)/86400 + datenum(QDVatt.epoch);
tend = QDVvar.TYPE1_PKT_DATA_TIME_ARRAY(end)/86400 + datenum(QDVatt.epoch);
taxis=QDVvar.TYPE1_PKT_DATA_TIME_ARRAY/86400 + datenum(QDVatt.epoch);

binaxis = 1:NUM_ENERGY_BINS;
energyaxis = binaxis*0.1465 - 3.837; % in keV % This is what the published
%paper has for energy.


dosadcaxis = 1:NUM_DOSIMETER_ADC_BINS;
t0 = [QDVatt.instrument,' QDV Radiation Spectrogram'];
t1=' ';
t4 = ['L1 Filename: ',L1files];
t2 = [''];
t3 = ['Real Time: ',datestr(now)];


%% Data Conversion

data1=QDVvar.TYPE1_PKT_SPECTRA_ARRAY;

delE=0.0001465;
delT=1.0;

R1=0.112; 
R2=0.025;
h=1.25;
g=0.5*pi^2*(R2^2+h^2+R1^2-((h^2+R1^2+R2^2)^2-4*R1^2*R2^2)^.5); %Energy independent geometric factor
g = 3.0e-6;

data1mod=data1(1:15:length(data1),:);
data1mod2=data1mod;

[m,n] = size(data1mod2);
sigmaf2=data1mod;
for i=1:1024
    for j=2:m
        data1mod2(j,i)=data1mod(j,i)-data1mod(j-1,i);
        if data1mod2(j,i)<=0
            data1mod2(j,i)=NaN;
        end
        if data1mod2(j,i)==data1mod(j,i)
            data1mod2(j,i)=NaN;
        end
    sigmaf2(j,i)=(data1mod2(j,i)/(delE*delT*g))^2*((sqrt(data1mod(j,i))/data1mod(j,i)^2)+(0.0001465^2/(energyaxis(i)/1000)^2)+0.1^2/15+((4*pi^3*.05^2*.01^2)/(pi*.05^2)^2)+.1/20.4^2);
    end
end



data1mod2=data1mod2./(delE*delT*g);
data1=data1./(delE*delT*g);


%flux=data1./(delE*delT*g);
flux=data1;

%Determine the size of the data array.
[m, n] = size(flux);


startE = 100;
newFlux = flux(:, startE : end);
newEnergyAxis = energyaxis(startE : end);

%Pick the times to be plotted.

startHour = 1;
endHour = 24;
numHours = endHour - startHour + 1;

timeStartIndex = fix(m/24)*startHour;
timeEndIndex = fix(m/24)*endHour;

year = repmat(str2num(L1_att_val.att5(1:4)), 1, numHours);
month = repmat(str2num(L1_att_val.att5(6:7)), 1, numHours);
day = repmat(str2num(L1_att_val.att5(9:10)), 1, numHours);
hours = startHour : endHour;
minutes = zeros(1, numHours);
seconds = zeros(1, numHours);
sdate = datenum(year, month, day, hours, minutes, seconds);

a = "Falcon";
b = "SEED";
c = "Spectrogram";
d = L1_att_val.att5;
e = L1_att_val.att4;

plotName = a + " " + b + " " + c + " " + d + " " + e;
saveName = a + b + c + d + "_" + e;


fig1 = figure('DefaultAxesFontSize', 14);
fig1.Position = [750 25 1200 500];
%ax = gca;
%ax.XTick = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];
%imagesc(taxis,energyaxis,log10(data1'))
%imagesc(sdate,energyaxis,log10(flux(timeStartIndex:timeEndIndex, :)'))
imagesc(sdate,newEnergyAxis,log10(newFlux(timeStartIndex:timeEndIndex, :)'))
set(gca,'YDir','normal');
caxis('auto');
caxis([10 13])
datetick('x','HH:MM','keepticks', 'keeplimits');
xlabel('Host Time (UTC)');
ylabel('Energy (keV)');
title(plotName);
cb=colorbar;
ylabel(cb,'Log10(Counts)') 


dirName = '/SS1/STPSat-6/Plots/';
plotFileName = strcat(dirName, saveName, '.png');
saveas(fig1, plotFileName);


%Pick a time index.
tIndex = 3300;
flux = log10(newFlux(tIndex,1:length(newEnergyAxis)));
energy = newEnergyAxis;

fig2 = figure('DefaultAxesFontSize', 14);
plot(energy, flux)
xlabel('Energy (keV)')
ylabel('Log Flux')



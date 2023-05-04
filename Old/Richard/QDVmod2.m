% MATLAB housekeeping
clear all;
close all;
fclose('all');

% Script housekeeping
thispath = fileparts(mfilename('fullpath'));
toptimestamp = datenum(now);
logtimestamp = datestr(toptimestamp,'yyyymmdd_hhMMss');
nctimestamp = datestr(toptimestamp);
perca = 1 + (0:99); % Percentage array
datesecs = 0:86399; % Seconds per day incrementing
disp(['STATUS: Running ',mfilename]);   
all_source_files = {};
SECS_PER_DAY = 86400;
NUM_ENERGY_BINS = 1024;
NUM_DOSIMETER_ADC_BINS = 16384;

% Select L1 files.
[L1files,PathName,FilterIndex] = uigetfile('*_L1.nc','Select L1 file');
% Write the filepath/names to a cell array.
cd(PathName);

% Extract, plot, and save the plot for the radiation detector energy-time spectrogram
% Open each file in turn.
fpn = fullfile(PathName,L1files);
ncid_L1 = netcdf.open(fpn,'NOWRITE');
disp(['STATUS: Opened ',L1files,' for reading.']);
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
    L1_att_val.(attname) = netcdf.getAtt(ncid_L1,netcdf.getConstant('NC_GLOBAL'),L1_att_name.(attname));
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

% Plot telemetry points of interest
% Start and stop times of data as "seconds of day"
tstart = QDVvar.TYPE1_PKT_INST_TIME_ARRAY(1)/86400 + datenum(QDVatt.epoch);
tend = QDVvar.TYPE1_PKT_INST_TIME_ARRAY(end)/86400 + datenum(QDVatt.epoch);
taxis=QDVvar.TYPE1_PKT_INST_TIME_ARRAY/86400 + datenum(QDVatt.epoch);
dtoday=QDVatt.data_earliest_today(1:11);
binaxis = 1:NUM_ENERGY_BINS;
energyaxis = binaxis*0.1392 - 0.6919; % in keV
%energyaxis = binaxis*0.1465 - 3.837; % in keV % This is what the published
%paper has for energy.
dosadcaxis = 1:NUM_DOSIMETER_ADC_BINS;
t0 = [QDVatt.instrument,' QDV Radiation Spectrogram'];
t1=' ';
t4 = ['L1 Filename: ',L1files];
t2 = ['Host Time: ',QDVatt.data_earliest_today(1:11),' ',QDVatt.data_earliest_today(13:end),' to ',QDVatt.data_latest_today(13:end),' UTC'];
t3 = ['Real Time: ',datestr(now)];

% Data Conversion
close all;
picname = 'QDV_Radiation_Spectogram.png';
data1=QDVvar.TYPE1_PKT_SPECTRA_ARRAY;
delE=0.0001465;
delT=15;
R1=0.112; 
R2=0.025;
h=1.25;
g=0.5*pi^2*(R2^2+h^2+R1^2-((h^2+R1^2+R2^2)^2-4*R1^2*R2^2)^.5); %Energy independent geometric factor
format long
data1mod=data1(1:15:length(data1),:);
i=1;
j=1;
data1mod2=data1mod;
sigmaf2=data1mod;


for i=1:1024
    for j=2:length(data1mod')
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


% Old Incorrect spectra plot
figure()
imagesc(taxis,energyaxis,log10(data1'))
set(gca,'YDir','normal');
datetick('x','HH:MM','keepticks','keeplimits');
xlabel('Host Time (UTC)');
ylabel('Energy (keV)');
title({t0,t1,t4,t2},'Interpreter','None');
cb=colorbar;
ylabel(cb,'Log10( Not Flux) Log10(Electrons/cm*cm*sec*MeV*Ster)') 
print('-dpng', picname);


% New Spectra Correct Plot
figure()
imagesc(taxis(1:15:length(taxis)),energyaxis,abs(log10(data1mod2')))
set(gca,'YDir','normal');
caxis([7 9])
%caxis('auto')
cb=colorbar;
ylabel('Energy (keV)');
ylabel(cb,'Log10(FLUX) Log10(Electrons/cm*cm*sec*MeV*Ster)')
xlabel('Host Time (UTC)');
title({t0,t1,t4,t2},'Interpreter','None');
datetick('x','keeplimits')
%%
figure()
imagesc(taxis(1:15:length(taxis)),energyaxis,abs(log10(data1mod2')))
set(gca,'YDir','normal');
caxis([7 9])
%caxis('auto')
cb=colorbar;
ylabel('Energy (keV)');
ylabel(cb,'Log10(FLUX) Log10(Electrons/cm*cm*sec*MeV*Ster)')
xlabel('Host Time (UTC)');
title({t0,t1,t4,t2},'Interpreter','None');
datetick('x','keeplimits')
yline(40,'LineWidth',4)
yline(100,'LineWidth',4)
%% 40 keV spectra
figure()
binchoice=293;
plot(taxis(1:15:length(taxis)),data1mod2(:,binchoice),'.')
yline(4.0281e7,"b")
yline(5.498e7,"r")
yline(5.989e7,"k")
print('-dpng', picname);
legend("SEED Data","SPENVIS","AE-8 Min","AE-8 Max")
datetick('x','keeplimits')
title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
ylabel('Flux (Electrons/cm*cm*sec*MeV*Ster)')
removeoutliers=rmoutliers(data1mod2(:,binchoice));
% format short
avg=nanmean(removeoutliers);
annotation('textbox',[.15,.80,.2,.1],'String',['SEED avg: ', num2str(avg)])
annotation('textbox',[.15,.70,.2,.1],'String',"SPENVIS avg: 4.0281e7")
annotation('textbox',[.15,.60,.2,.1],'String',"AE-8 Min: 5.498e7")
annotation('textbox',[.15,.50,.2,.1],'String',"AE-8 Max: 5.989e7")
format long
%% 100 keV spectra
figure()
binchoice=724;
plot(taxis(1:15:length(taxis)),data1mod2(:,binchoice),'.')
yline(2.656e7,"b")
yline(3.743e7,"r")
yline(4.294e7,"k")
print('-dpng', picname);
legend("SEED Data","SPENVIS","AE-8 Min","AE-8 Max")
datetick('x','keeplimits')
title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
xlabel('Host Time (UTC)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
removeoutliers=rmoutliers(data1mod2(:,binchoice));
format short
avg=nanmean(removeoutliers);
annotation('textbox',[.15,.80,.2,.1],'String',['SEED avg: ', num2str(avg)])
annotation('textbox',[.15,.70,.2,.1],'String',"SPENVIS avg: 2.656e7")
annotation('textbox',[.15,.60,.2,.1],'String',"AE-8 Min: 3.743e7")
annotation('textbox',[.15,.50,.2,.1],'String',"AE-8 Max: 4.294e7")
format long
%%
figure()
binchoice1=293;
binchoice2=450;
binchoice3=600;
binchoice4=724;
t=taxis(1:15:length(taxis));
semilogy(t,data1mod2(:,binchoice1),'.',t,data1mod2(:,binchoice2),'.',t,data1mod2(:,binchoice3),'.',t,data1mod2(:,binchoice4),'.')
grid on
print('-dpng', picname);
legend(num2str(energyaxis(binchoice1)),num2str(energyaxis(binchoice2)),num2str(energyaxis(binchoice3)),num2str(energyaxis(binchoice4)))
datetick('x','keeplimits')
%title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
xlabel('Host Time (UTC)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
%% Multi Bin Flux vs Time
figure()
binchoice1=293;
binchoice2=450;
binchoice3=600;
binchoice4=724;
t=taxis(1:15:length(taxis));
plot(t,data1mod2(:,binchoice1),'.',t,data1mod2(:,binchoice2),'.',t,data1mod2(:,binchoice3),'.',t,data1mod2(:,binchoice4),'.')
grid on
print('-dpng', picname);
legend(num2str(energyaxis(binchoice1)),num2str(energyaxis(binchoice2)),num2str(energyaxis(binchoice3)),num2str(energyaxis(binchoice4)))
datetick('x','keeplimits')
%title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
xlabel('Host Time (UTC)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
%% Multi Bin Flux vs Time
figure()
binchoice1=293;
binchoice2=450;
binchoice3=600;
binchoice4=724;
t=taxis(1:15:length(taxis));
data1smooth=smoothdata(data1mod2(:,binchoice1));
data2smooth=smoothdata(data1mod2(:,binchoice2));
data3smooth=smoothdata(data1mod2(:,binchoice3));
data4smooth=smoothdata(data1mod2(:,binchoice4));
data1smooth=smoothdata(data1smooth);
data2smooth=smoothdata(data2smooth);
data3smooth=smoothdata(data3smooth);
data4smooth=smoothdata(data4smooth);
% data1smooth=smoothdata(data1smooth);
% data2smooth=smoothdata(data2smooth);
% data3smooth=smoothdata(data3smooth);
% data4smooth=smoothdata(data4smooth);
% data3smooth=smoothdata(data3smooth);
% data4smooth=smoothdata(data4smooth);
% data3smooth=smoothdata(data3smooth);
% data4smooth=smoothdata(data4smooth);
% data3smooth=smoothdata(data3smooth);
% data4smooth=smoothdata(data4smooth);
% data3smooth=smoothdata(data3smooth);
% data4smooth=smoothdata(data4smooth);
% data3smooth=smoothdata(data3smooth);
% data4smooth=smoothdata(data4smooth);
semilogy(t,data1smooth,t,data2smooth,t,data3smooth,t,data4smooth)
grid on
print('-dpng', picname);
legend(num2str(energyaxis(binchoice1)),num2str(energyaxis(binchoice2)),num2str(energyaxis(binchoice3)),num2str(energyaxis(binchoice4)))
datetick('x','keeplimits')
%title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
xlabel('Host Time (UTC)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
%% One Cycle Error for 1 energy bin
figure()
binchoice=724;
t=38:117;
errorbar(t,data1mod2(38:117,binchoice),sqrt(sigmaf2(38:117,binchoice)),sqrt(sigmaf2(38:117,binchoice)),'o')
%yline(2.656e7,"b")
%yline(3.743e7,"r")
%yline(4.294e7,"k")
%legend("SEED Data","SPENVIS","AE-8 Min","AE-8 Max")
% datetick('x','keeplimits')
% title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
% xlabel('Host Time (UTC)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
%% Whole day error for one energy bin
figure()
binchoice=724;
errorbar(taxis(1:15:length(taxis)),data1mod2(:,binchoice),sqrt(sigmaf2(:,binchoice)),sqrt(sigmaf2(:,binchoice)),'o')
datetick('x','keeplimits')
title(['Energy bin ',num2str(energyaxis(binchoice)),' keV'])
xlabel('Host Time (UTC)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
%% Whole energy range error for one time
figure()
timechoice=724;
errorbar(energyaxis(1:8:1024)',data1mod2(timechoice,1:8:1024),sqrt(sigmaf2(timechoice,1:8:1024)),sqrt(sigmaf2(timechoice,1:8:1024)),'o')
title(['Error plot vs Energy'])
xlabel('Energy Axis (keV)');
ylabel('FLUX(Electrons/cm*cm*sec*MeV*Ster)')
set(gca,'YScale','log');
%% MATLAB housekeeping

clear all;
close all;
fclose('all');

%% Script housekeeping

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

disp('1/26/22: Original Copy');
disp('1/26/22: ADDED using original base filename.')

%% Select L1 files.
[L1files,PathName,FilterIndex] = uigetfile('*_L1.nc','Select L1 file');
% Write the filepath/names to a cell array.
cd(PathName);
% % If you only select one file, turn it into a cell array anyway.
% if ~iscell(L1files)
%     L1files = {L1files};
% end
% L1files = sort(L1files);
% numL1files = length(L1files);
% disp(['STATUS: Selected ',num2str(numL1files),' L1 file.']);

%% Create an output directory to put the new QDV files in.

% Create a new folder with today's datestamp to put the new QDV files in.
timestamp = datestr(now,'yyyymmddHHMM');
outputdir = ['QDV_',timestamp];
disp(['STATUS: Creating output directory .\',outputdir]);
mkdir (outputdir);
cd(outputdir);

%% Extract, plot, and save the plot for the radiation detector energy-time spectrogram

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

%% Plot telemetry points of interest

% Start and stop times of data as "seconds of day"

tstart = QDVvar.TYPE1_PKT_INST_TIME_ARRAY(1)/86400 + datenum(QDVatt.epoch);
tend = QDVvar.TYPE1_PKT_INST_TIME_ARRAY(end)/86400 + datenum(QDVatt.epoch);
taxis=QDVvar.TYPE1_PKT_INST_TIME_ARRAY/86400 + datenum(QDVatt.epoch);
xlims=[floor(tstart) ceil(tend)];
hours=0:3:24;
% tstart = 1 + floor(SECS_PER_DAY * (datenum(QDVatt.data_earliest_today)  - fix(datenum(QDVatt.data_earliest_today))));
% tend = floor(SECS_PER_DAY * (datenum(QDVatt.data_latest_today)  - fix(datenum(QDVatt.data_latest_today))));
% taxis = (tstart:tend)/SECS_PER_DAY;



dtoday=QDVatt.data_earliest_today(1:11);
binaxis = 1:NUM_ENERGY_BINS;
energyaxis = binaxis*0.1392 - 0.6919; % in keV
dosadcaxis = 1:NUM_DOSIMETER_ADC_BINS;
t0 = [QDVatt.instrument,' Radiation Spectrogram'];
%t1 = ['Raw Filename: ',QDVatt.raw_source_filename];
t1=' ';
t4 = ['L1 File: ',L1files];
t2 = ['Data Available: ',QDVatt.data_earliest_today(1:11),' ',QDVatt.data_earliest_today(13:end),' to ',QDVatt.data_latest_today(13:end),' UTC'];
t3 = ['Real Time: ',datestr(now)];

rootpicname=['SEED_',datestr(dtoday,'yyyy-mm-dd'),'_']

%% Energy-time spectrogram
close all;
figure()
picname = [rootpicname,'Radiation_Spectogram.png'];
% data1 = squeeze(QDVvar.TYPE1_PKT_SPECTRA_ARRAY(tstart:tend,:));
data1=QDVvar.TYPE1_PKT_SPECTRA_ARRAY;
imagesc(taxis,energyaxis,data1')
set(gca,'YDir','normal');
xlabel('Host Time (UTC)');
ylabel('Energy (keV)');
title({t0,t1,t4,t2},'Interpreter','None');
cb=colorbar;
ylabel(cb,'Bin Counts')
xlim(xlims);
datetick('x','HH:MM','keeplimits');

%xticklabels({hours});
disp(['STATUS: Printing ',fullfile(PathName,outputdir,picname)]);
print('-dpng', picname);

%%
figure()
picname = [rootpicname,'Radiation_Spectogram_Log10.png'];
clims=([0 4]);
imagesc(taxis,energyaxis,log10(data1'),clims)

set(gca,'YDir','normal');
xlabel('Host Time (UTC)');
ylabel('Energy (keV)');
title({t0,t1,t4,t2},'Interpreter','None');
cb=colorbar;
ylabel(cb,'Log10(Bin Counts)')
xlim(xlims);
datetick('x','HH:MM','keeplimits');

disp(['STATUS: Printing ',fullfile(PathName,outputdir,picname)]);
print('-dpng', picname);

%%
figure();
hold on;
for i=1:5
    binchoice=80*i;
    plot(taxis,log10(data1(:,binchoice)),'.')
    legendt{i}=[num2str(energyaxis(binchoice)),' keV'];
end
legend;
xlabel('UTC')
ylabel('Bin Count')
xlim(xlims);
datetick('x','HH:MM','keeplimits');

%% 2 min
[a,b,c]=fileparts(L1files);

%
% f=figure;
% 
% subplot(2,1,1);
% semilogy(data1(j,:));
% 
% title(['Elapsed time ',num2str(j),' seconds']);
% xlim([1 1024]);
% xlabel('Spectra bin (all)');
% topy = 2*max(data1(j,1:200));
% ylim([0 topy]);
% ylabel('Histogram Count');
% 
% subplot(2,1,2);
% semilogy(data1(j,:));
% xlim([1 200]);
% xlabel('Spectra bin (1:200)');
% topy = 2*max(data1(j,1:200));
% ylim([0 topy]);
% ylabel('Histogram Count');
% 
% 
% fname=['seed_histogram_',b,'_',num2str(i),'logy.png'];
% print(fname,'-dpng');


%% Dosimeter

figure()
picname = [rootpicname,'Dosimeter.png'];
%data1 = squeeze(QDVvar.TYPE1_PKT_DOSIMETER_ARRAY(tstart:tend,:));
data1 = QDVvar.TYPE1_PKT_DOSIMETER_ARRAY;
plot(taxis,data1(:,1),'.r');
hold on;
plot(taxis,data1(:,2),'.b');
plot(taxis,data1(:,3),'.g');
plot(taxis,data1(:,4),'.');
legend('Ch0 (3.6 mRad)','Ch1 (0.9 Rad)','Ch2 (235 Rad)','Ch3 (log 40 kRad)');
set(gca,'YDir','normal');
ylim([0 16383]);
xlabel('Host Time (HH:MM)');
ylabel('ADC counts (#)');
xlim(xlims);
datetick('x','HH:MM','keeplimits');


t0 = [QDVatt.instrument,' QDV Dosimeter'];
title({t0,t1,t4,t2,t3},'Interpreter','None');
disp(['STATUS: Printing ',fullfile(PathName,outputdir,picname)]);
hold off;
print('-dpng', picname);

%% Board Temperature

figure()
picname = [rootpicname,'Temperature.png'];
%data0 = uint8(squeeze(QDVvar.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY(tstart:tend)));
%data1 = typecast(data0,'int8');
data0 = QDVvar.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY;
data1 = data0;
plot(taxis,data1,'.r');

%set(gca,'YDir','normal');
ylim([min(data1)-1 max(data1)+1]);
xlabel('Host Time (HH:MM)');
ylabel('DP5 Temperature (deg C)');
xlim(xlims);
datetick('x','HH:MM','keeplimits');

t0 = [QDVatt.instrument,' QDV DP5 Temperature'];
title({t0,t1,t4,t2,t3},'Interpreter','None');
disp(['STATUS: Printing ',fullfile(PathName,outputdir,picname)]);
print('-dpng', picname);
%%
figure()
picname = [rootpicname,'Command_Counter.png'];
%data0 = uint8(squeeze(QDVvar.TYPE1_PKT_TEMPERATURE_BRAINS_ARRAY(tstart:tend)));
%data1 = typecast(data0,'int8');
data0 = QDVvar.TYPE1_PKT_RECDCMDS_ARRAY;
data1 = data0;
plot(data1,'.r');

%set(gca,'YDir','normal');
ylim([min(data1)-1 max(data1)+1]);
xlabel('Host Time (HH:MM)');
ylabel('#Commands');
xlim(xlims);
datetick('x','HH:MM','keeplimits');

t0 = [QDVatt.instrument,' QDV Received Commands'];
title({t0,t1,t4,t2,t3},'Interpreter','None');
disp(['STATUS: Printing ',fullfile(PathName,outputdir,picname)]);
print('-dpng', picname);


% %% CSV of ERROR',flags
% errfilename = strrep(L1files,'.nc','.txt');
% ErrorBitField=QDVvar.TYPE1_PKT_ERRORS_ARRAY;
% Time=datestr(taxis,'hh:MM:ss');
% T=table(Time,ErrorBitField);
% disp(['STATUS: Writing ',fullfile(PathName,outputdir,errfilename),' ERROR csv file.']);
% writetable(T,errfilename);
% 
% ErrorNames=...
% ["ERR_MSC_SPI_ERROR",...
% "ERR_MSC_UART0_ERROR",...
% "ERR_MSC_UART1_ERROR",...
% "ERR_MSC_DOSIMETER", ...
% "ERR_MSC_RESERVED5", ...
% "ERR_MSC_RESERVED6", ...
% "ERR_MSC_NOT_HERE", ... 
% "ERR_MSC_GENERAL",...
% "ERR_PKT_BAD_SYNC",...
% "ERR_PKT_BAD_CRC",...
% "ERR_PKT_RESERVED3",...
% "ERR_PKT_RESERVED4",...
% "ERR_PKT_RESERVED5",...
% "ERR_PKT_RESERVED6",...
% "ERR_PKT_BADTIME",...
% "ERR_PKT_GENERAL",...
% "ERR_CMD_NOT_YET_CODED",...
% "ERR_CMD_RESERVED",...
% "ERR_CMD_BAD_CMD",...
% "ERR_CMD_BAD_ARG",...
% "ERR_CMD_RESERVED5",...
% "ERR_CMD_RESERVED6",...
% "ERR_CMD_UNK_CMD",...
% "ERR_CMD_GENERAL",...
% "ERR_DP5_NO_RESPONSE",...
% "ERR_DP5_BAD_RESPONSE",...
% "ERR_DP5_ACK_ERROR",...
% "ERR_DP5_BADLOOKUP",...
% "ERR_DP5_RESPONSE_NOT_CODED",...
% "ERR_DP5_NOINIT",...
% "ERR_DP5_LOCKED",...
% "ERR_DP5_GENERAL"];
% %%
% sa = find(ErrorBitField>0);
% sb = length(sa);
% disp(['INFO: Found ',num2str(sb),' packets with error flags raised.']);
% T2 = datestr(taxis(sa),'hh:MM:ss');
% E2 = ErrorBitField(sa);
% 
% for i=1:sb
%     N0 = bitget(E2(i),32:-1:1,'uint32');
%     T0 = T2(i,:);
%     N1 = ErrorNames([N0>0]);
%     %disp(strjoin(string(['INFO:',dtoday,T0,N1])));
% end
% 
% disp('ACTION: Consult the embedded code(r) for in-depth error investigations.');
%%
disp('STATUS: Done.');

%% Functions go below here.

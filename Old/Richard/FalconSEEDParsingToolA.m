%% Edit only this section!!!
clear all;
close all;
fclose('all');
thispath = fileparts(mfilename('fullpath'));
% Edit the path/wildcard for the instrument-specific parameter files.  This
% will likely be in **your local** SVN copy.
INC_FILTER = [thispath,'\INC_PARAMS_*'];

%% Housekeeping
disp(['INFO: Running ',mfilename]);
BINFILE_PREFIX = 'STP6_';
BINFILE_SUFFIX = '_VC39';
BINFILE_EXTENSION = '.0';

%% Read instrument-specific parameters from config file.
[ParameterFile,ParameterPath]=uigetfile(INC_FILTER,'Select the instrument-specific parameters include file.');
% Running the file populates the variables.
run(fullfile(ParameterPath,ParameterFile));
disp(['INFO: Searching for ',HOST,' ',INSTRUMENT,' data.']);

%% Select binary flatfiles FILE BY FILE
[binfiles,PathName,FilterIndex] = uigetfile(['*',BINFILE_EXTENSION],'Select binary flatfiles','Multiselect','on');
% Write the filepath/names to a cell array.
cd(PathName);
% If you only select one file, turn it into a cell array anyway.
if ~iscell(binfiles)
    binfiles = {binfiles};
end
numbinfiles = length(binfiles);
disp(['Selected ',num2str(numbinfiles),' ',INSTRUMENT,' binary flatfile(s).']);

%% Look for missing files by filename
binfiles = sort(binfiles);

fyear = zeros(1,numbinfiles);
fdoy = zeros(1,numbinfiles);
fhour = zeros(1,numbinfiles);

% for i=1:numbinfiles %% NG bin format
%     f1 = binfiles{i};
%     fyear(i) = str2num(f1(15:18));
%     fdoy(i) = 1+datenum(f1(15:24),'yyyy-mm-dd')-datenum('1/1/20');
%     fhour(i) = str2num(f1(26:27));
% end

for i=1:numbinfiles %% VCID format
    f1 = binfiles{i};
    fyear(i) = str2num(f1(6:9));
    fdoy(i) = str2num(f1(10:12));
    fhour(i) = str2num(f1(13:14));
end

% for i=1:numbinfiles %% USAFA Python GUI format
%     f1 = binfiles{i};
%     fyear(i) = str2num(f1(20:23));
%     fdoy(i) = 1+datenum(f1(20:27),'yyyymmdd')-datenum('1/1/20')
%     fhour(i) = str2num(f1(24:25));
% end

% Find earliest and latest days
f1 = binfiles(1);
f2 = binfiles(end);
f1d = fdoy(1);
f2d = fdoy(end);

d2=datenum(num2str(fyear(1)),'yyyy')+f1d-1;
disp(['First day found = ',datestr(d2),' (day ',num2str(f1d),')']);
d2=datenum(num2str(fyear(end)),'yyyy')+f1d-1;
disp(['Last day found = ',datestr(d2),' (day ',num2str(f1d),')']);

% Work out expected file names assuming no gaps
xd = f1d:f2d;
num_xd=length(xd);
if (num_xd * 24) ~= numbinfiles
    disp(['WARNING: Possible missing files from these days.']);
end
for i=1:num_xd
    for j=0:23
        dfn1 = [BINFILE_PREFIX,num2str(fyear(1)),num2str(xd(i),'%03i'),num2str(j,'%02i')];
        if ~startsWith(binfiles,dfn1)
            disp(['> Expected to find file ',dfn1,'xxxx',BINFILE_SUFFIX,BINFILE_EXTENSION,' but it was not in selection.']);
        end
    end
end


%% Create an output directory to put the L0 files in.
% Create a new folder with today's datestamp to put the new L0 files in.
timestamp = datestr(now,'yyyymmddHHMM');
outputdir = ['Raw_to_L0_',timestamp];
% disp(['INFO: Creating output directory .\',outputdir]);
% mkdir (outputdir);

%% Iterate through each file in turn.

for kk=1:numbinfiles
    close all;
    BinFileName = binfiles{kk};
    %BinPathName = binfiles{1}(kk).folder;
    FileName = BinFileName;
    BinPathName = PathName;
    disp('===================================================================');
    disp(['INFO: Opening file ',num2str(kk),'/',num2str(numbinfiles),' ',BinFileName]);
    %fid = fopen(fullfile(BinPathName,BinFileName),'r');
    fid = fopen(BinFileName,'r');
    clear data;
    data = fread(fid);
    fclose(fid);
    numbytes = length(data);
    disp(['INFO: Read in ',num2str(numbytes),' bytes.']);
    [fnd,fnb,fne]=fileparts(FileName);
    
    fng=[fnb,'_summary_graphs'];
    mkdir(fng);
    % If we are STPSat-6 (FalconSEED), we need to get rid of the interleaved CADUs.
    if strcmp(HOST,'STPSat-6')
         STPSat6_CADU_Extractor;
    end
    
 
    % Search through the current file to look for packet types.
    % If we find a packet, check its CRC.  If the CRC is bad, NaN the
    % packet.
    totpackets = 0;
    FalconSEED_L0_Type_Finder2;
    
    if totpackets == 0
        disp('ERROR: No instrument packets found in this file.');
        disp('ERROR: Skipping this file.');
        %error('erk4');
        continue;
    end
    %% NaN anything weird
    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,31:32),2)); 
    x1a=find(x1==hex2dec('4444')); 

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,27:30),2)); 
    x1b=find(x1==hex2dec('53535353'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,41:42),2)); 
    x1c=find(x1==hex2dec('4141'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,47:49),2)); 
    x1d=find(x1==hex2dec('f5faff'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,151:152),2)); 
    x1e=find(x1==hex2dec('4343'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,4081:4082),2)); 
    x1f=find(x1==hex2dec('FFFF'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,61:62),2)); 
    x1g=find(x1==hex2dec('4242'));


    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,157:158),2)); 
    x1h=find(x1==hex2dec('f5fa'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,159:162),2)); 
    x1i=find(x1==hex2dec('81060c40'));

    x1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,13),2)); 
    x1j=find(x1==hex2dec('00'));    

    x2=intersect(x1a,x1b,'stable');
    x2=intersect(x2,x1c,'stable');
    x2=intersect(x2,x1d,'stable');
    x2=intersect(x2,x1e,'stable');
    x2=intersect(x2,x1f,'stable');
    x2=intersect(x2,x1g,'stable');
    x2=intersect(x2,x1h,'stable');
    x2=intersect(x2,x1i,'stable');
    x2=intersect(x2,x1j,'stable');

    x3=1:size(data_packets.data_packet_type_1,1);
    x4=setdiff(x3,x2);

    data4=double(data_packets.data_packet_type_1);
    data4(x4,:)=NaN;

%     %% Turn CCSDS packets into NaNs
%     ccsdssync='1acffc1d';
%     sync_pattern_ra = sscanf(ccsdssync,'%2x')';
%     
%     ddd1=double(temp_packet_array);
%     for i=1:size(temp_packet_array,1)
%         %disp(num2str(i))
%         dddrow=double(ddd1(i,:));
%         j=strfind(dddrow,sync_pattern_ra);
%         %disp(num2str(j))
%         for k=1:length(j)
%             disp(['Found CCSDS header in packet ',num2str(i),' at position ',num2str(j(k))]);
%             z1=j(k)-12;
%             z2=j(k)+20;
%             if z1<1
%                 z1=1;
%             end
%             if z2>4096
%                 z2=4096;
%             end
%             dddrow(z1:z2)=NaN;
%             %dddrow=NaN;
%         end
%         ddd1(i,:)=dddrow;
%     end
%     temp_packet_array=ddd1;

%     %% Turn all ACK packets into NaNs
% 
%     ccsdssync='f5faff';
%     sync_pattern_ra = sscanf(ccsdssync,'%2x')';
% 
%     ddd1=double(temp_packet_array);
%     for i=1:size(temp_packet_array,1)
%         %disp(num2str(i))
%         dddrow=double(ddd1(i,:));
%         j=strfind(dddrow,sync_pattern_ra);
%         %disp(num2str(j))
%         for k=1:length(j)
%             z1=j(k);
%             z2=j(k)+7;
%             if z1<1
%                 z1=1;
%             end
%             if z2>4096
%                 z2=4096;
%             end
%             dddrow(z1:z2)=NaN;
%             %dddrow=NaN;
%         end
%         ddd1(i,:)=dddrow;
%     end
%     temp_packet_array=ddd1;
% 
%     %% Turn status packets into NaNs
%     ccsdssync='f5fa80'; % status packet
%     sync_pattern_ra = sscanf(ccsdssync,'%2x')';
% 
%     ddd1=double(temp_packet_array);
%     for i=1:size(temp_packet_array,1)
%         %disp(num2str(i))
%         dddrow=double(ddd1(i,:));
%         j=strfind(dddrow,sync_pattern_ra);
%         %disp(num2str(j))
%         for k=1:length(j)
%             z1=j(k);
%             z2=j(k)+71;
%             if z1<1
%                 z1=1;
%             end
%             if z2>4096
%                 z2=4096;
%             end
%             dddrow(z1:z2)=NaN;
%             %dddrow=NaN;
%         end
%         ddd1(i,:)=dddrow;
%     end
%     temp_packet_array=ddd1;
%%

    
    t1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,5:8),2)); % seconds since epoch
    t2=double(t1)/SECS_PER_DAY;
    t3=datenum(EPOCH)+t2;
    if (min(t3)~=t3(1))|| ...
            (max(t3)~=t3(end))
        disp(['**WARNING** times are not increasing monotonically']);
    end
    disp(['First timestamp = ',datestr(t3(1)),' SV time.']);
    disp(['Last timestamp = ',datestr(t3(end)),' SV time']);
    disp(['Max timestamp jump = ',num2str(max(diff(SECS_PER_DAY*t3))),' seoonds (expected less than 30 sec)']);
    if ~strmatch(datestr(f1d,'mm-dd'),datestr(t3(1),'mm-dd'))
        disp(['**WARNING** file name datestamp does not match packet datestamp']);
    end
    
    %% time axes
    t1_secs=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,5:8),2));
    t1_fsecs=double(t1_secs);
    t2_mdays=t1_fsecs/86400+datenum(EPOCH);
    t2_mdays_1=t3(1);
    t2_mdays_2=t3(end);
    t2_doy=floor(date2doy(t3(1)));
    numt1=length(t1);
    dt1_secs=t1_secs(end)-t1_secs(1);

    tit1=BinFileName;
    tit2=[datestr(t2_mdays_1,'yyyy-mm-dd'),...
        '(day ',num2str(t2_doy),') ',datestr(t2_mdays_1,'hh:MM:ss'),...
        ' to ',datestr(t2_mdays_2,'hh:MM:ss'),' UTC (',...
        num2str(dt1_secs),' secs)'];
    tit3=[num2str(length(x2)),' data points'];

    %%
    figure(kk) % time
    picname = [fnb,'.time.png'];
    tit0='Time Counter (seconds since epoch)';
    plot(t2_mdays,t1_secs,'.');
    xlim([t2_mdays_1 t2_mdays_2]);
    datetick('x','HH:MM','keepticks','keeplimits');
    xlabel('SEED time (SV HH:MM)','Interpreter','None');
    ylabel('time_falconseed (sec since EPOCH)','Interpreter','None');
    title({tit0,tit1,tit2,tit3},'Interpreter','None');
    print('-dpng', fullfile(fng,picname));

    %%
    figure(kk+100); % counters
    picname = [fnb,'.PIBcounters.png'];
    tit0='PIB Counters';
    c1_sent_dp5=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,15:16),2));
    c1_recd_dp5=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,17:18),2));
    c1_errorbits=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,19:20),2));
    c1_usart0_errs=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,23:24),2));
    c1_t1=data_packets.data_packet_type_1(:,24);
    c1_usart1_errs=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,25:26),2));
    c1_t2=data_packets.data_packet_type_1(:,26);

    c1_7_8=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,7:8),2)); % last two bytes of time
    c1_9_10=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,9:10),2)); % PIB recd
    c1_11_12=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,11:12),2)); % PIB cmds recd


    c20=c1_sent_dp5(1)-c1_recd_dp5(1);
    c2=c1_sent_dp5-c1_recd_dp5-c20;
    
    tlo = tiledlayout(4,1,'TileSpacing','none','Padding','compact');

    
    
    nexttile,plot(t2_mdays(x2),c1_9_10(x2),'.');
    xlim([t2_mdays_1 t2_mdays_2]);
    axis tight;
    xticklabels([]);
    title('#PIB received requests','Interpreter','None');
    ylabel('#','Interpreter','None');    
    
    nexttile,plot(t2_mdays(x2),c1_11_12(x2),'.');
    xlim([t2_mdays_1 t2_mdays_2]);
    axis tight;
    xticklabels([]);
    title('#PIB received commands','Interpreter','None');
    ylabel('#','Interpreter','None');    
    
    nexttile,plot(t2_mdays(x2),c2(x2),'.');
    xlim([t2_mdays_1 t2_mdays_2]);
    axis tight;
    xticklabels([]);
    title('PIB delta(requests - replies)','Interpreter','None');    
    ylabel('#','Interpreter','None');    
   
    nexttile,plot(t2_mdays(x2),c1_usart0_errs(x2),'.');
    xlim([t2_mdays_1 t2_mdays_2]);
    hold on;
    plot(t2_mdays(x2),c1_usart1_errs(x2),'.');
    xlim([t2_mdays_1 t2_mdays_2]);
    ylim([-1 5])
    hold off;
    axis tight;
    legend('USART0 errors','USART1 errors');
    title('USART errors','Interpreter','None');    
    ylabel('#','Interpreter','None');    


    datetick('x','HH:MM','keepticks','keeplimits');
    xlabel('SEED time (SV HH:MM)','Interpreter','None');
    sgtitle({tit0,tit1,tit2,tit3},'Interpreter','None');
    print('-dpng', fullfile(fng,picname));    
     %%
    figure(kk+500); % counters
    picname = [fnb,'.DP5status.png'];
    tit0='DP5 Status';


    c1_15_16=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,15:16),2)); % DP5 sent
    c1_17_18=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,17:18),2)); % DP5 recd
    
    
    %c1_11_12=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,11:12),2)); % PIB cmds recd

    tlo = tiledlayout(3,1,'TileSpacing','none','Padding','compact');

    nexttile,plot(t2_mdays(x2),c1_15_16(x2),'.');
    hold on
    plot(t2_mdays(x2),c1_17_18(x2),'.');
    hold off
    axis tight;
    xticklabels([]);
    legend('Sent to DP5','Recd from DP5');
    title('DP5 send/recd packets','Interpreter','None');
    ylabel('#','Interpreter','None');    
    
    c1_21_22=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,21:22),2)); % DP5 init fail
    nexttile,plot(t2_mdays(x2),c1_21_22(x2),'.');
    axis tight;
    xticklabels([]);
    title('#DP5 init fails','Interpreter','None');
    ylabel('#','Interpreter','None');    
    
%     
%     c1_19_20=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,19:20),2)); % errbit ctr
%     nexttile,plot(t2_mdays(x2),c2(x2),'.');
%     axis tight;
%     xticklabels([]);
%     title('#Error flags raised)','Interpreter','None');    
%     ylabel('#','Interpreter','None');    
   
    c_dp5_boardtemp = data_packets.data_packet_type_1(:,107);
    c_dp5_boardtemp(find(c_dp5_boardtemp>127))=c_dp5_boardtemp(find(c_dp5_boardtemp>127))-256;
    nexttile,plot(t2_mdays(x2),c_dp5_boardtemp(x2),'.');
    axis tight;
    title('DP5 board temperature','Interpreter','None');    
    ylabel('deg C','Interpreter','None');    


    datetick('x','HH:MM','keepticks','keeplimits');
    xlabel('SEED time (SV HH:MM)','Interpreter','None');
    sgtitle({tit0,tit1,tit2,tit3},'Interpreter','None');
    print('-dpng', fullfile(fng,picname));       
    %% 
    % error table
    e_all=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,4089:4092),2)); % errblock
    t_error=find(e_all>0);
    errfilename = [fnb,'.errors.txt'];
    fid=fopen(fullfile(fng,errfilename),'wt');
    tit0='Error flag time history';
    fprintf(fid,'%s\n',tit0);
    fprintf(fid,'%s\n',tit1);
    fprintf(fid,'%s\n',tit2);
    fprintf(fid,'%s\n',tit3);
    tit4=['Packet error flag rate = ',num2str(3600*double(length(t_error)/length(x2))),' hr-1'];
    fprintf(fid,'%s\n',tit4);

    for i=1:length(t_error)
        e_str='';
        fprintf(fid,'%s ',datestr(t2_mdays(t_error(i))));
        for k=1:length(ERR_LIST);
            if bitshift(e_all(t_error(i)),-(k-1))
                fprintf(fid,'%s ',char(ERR_LIST{k}));
            end
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
    %winopen(fullfile(pwd,fng,errfilename))

      %%
    figure(kk+200); % dosimeter
    picname = [fnb,'.dosimeter.png'];
    tit0='Dosimeter';
    d0=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,33:34),2));
    d1=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,35:36),2));
    d2=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,37:38),2));
    d3=cellfun(@(x) bytesum(x,0), num2cell(data_packets.data_packet_type_1(:,39:40),2));
    
    plot(t2_mdays(x2),d0(x2),'.');
    hold on;
    plot(t2_mdays(x2),d1(x2),'.');
    plot(t2_mdays(x2),d2(x2),'.');
    plot(t2_mdays(x2),d3(x2),'.');
    hold off;

    legend('Ch0','Ch1','Ch2','Ch3');
    %xlim([t2_mdays_1 t2_mdays_2]);
    axis tight;
    datetick('x','HH:MM','keepticks','keeplimits');
    xlabel('SEED time (HH:MM)','Interpreter','None');
    ylabel('Dosimeter ADC count','Interpreter','None');
    title({tit0,tit1,tit2},'Interpreter','None');
    print('-dpng', fullfile(fng,picname));
    
    %%
    figure(kk+300); % spectra
    picname = [fnb,'.spectra.png'];
    tit0='DP5 Spectra';
    %s0=data_packets.data_packet_type_1(:,163:3234);

    data5=data4(~isnan(data4));
    data6=reshape(data5,[],4096);

    s0=data6(:,163:3234);
    timeaxis=t2_mdays(x2);
    
    %s0a = s0(x2,:);
    s0a=s0;
    numt2=size(data6,1);
    s1 = squeeze(reshape(s0a,numt2,3,1024));
    s2 = num2cell(s1,2);
    s3 = double(squeeze(cellfun(@(x) bytesum(x,1), s2)));
    s4=uint32(s3');
    s5=log10(double(s4));
   
    binaxis = 1:1024;
    energyaxis = binaxis*0.1392 - 0.6919; % in keV

    %imagesc(s5);
%%
    imagesc(timeaxis,energyaxis,s4);
    set(gca,'YDir','normal');
    xlim([t2_mdays_1 t2_mdays_2]);
    ylim([min(energyaxis) max(energyaxis)]);
    datetick('x','HH:MM','keepticks','keeplimits');
    xlabel('SEED time (HH:MM)','Interpreter','None');
    ylabel('Energy (keV)');
    title({tit0,tit1,tit2},'Interpreter','None');

    print('-dpng', fullfile(fng,picname));   
    
%     %%
%     figure(kk+400); % line spectra
%     picname = [fnb,'.lastspectra.png'];
%     
%     subplot(2,1,1);
%     
%     tit0='DP5 Spectra Count Rate';
%     diffspec=s4(:,x2(end))-s4(:,x2(1));
%     difftime=t1_secs(x2(end))-t1_secs(x2(1));
%     diffspec=diffspec/difftime;
%     [a,b]=max(diffspec);
%     %disp(['Diffspec rate max = ',num2str(max(diffspec)),' peak = ',num2str(b),' sum = ',num2str(sum(diffspec))]);
% 
%     semilogy(energyaxis,diffspec);
%     xlim([min(energyaxis) max(energyaxis)]);   
% 
% %     semilogy(energyaxis,s4(:,end));
% %     xlim([min(energyaxis) max(energyaxis)]);
% %     hold on
% %     for p=1:numpackets
% %         semilogy(energyaxis,s4(:,p))
% %         %plot(energyaxis,s4(:,p));
% %     end
% %     hold off
%     xlabel('(Kirtland calibration May 2019) Energy (keV)','Interpreter','None');
%     ylabel('Counts/sec','Interpreter','None');
%     
%     subplot(2,1,2);
%       
%     semilogy(diffspec);
%     xlim([1 300]);   
%     
%     xlabel('Bin # (zoomed axis)','Interpreter','None');
%     ylabel('Counts/sec','Interpreter','None');
% 
%    
%     sgtitle({tit0,tit1,tit2},'Interpreter','None');
% 
%     print('-dpng', fullfile(fng,picname));    
%     
% 
 end
    
    %% Housekeeping at end
%     %close all;
%     disp(['STATUS: L0 files closed.']);
%     disp(['ACTION: Now run the L0 to L1 script.']);

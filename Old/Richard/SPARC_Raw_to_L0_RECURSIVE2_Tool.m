


%% Edit only this section!!!
clear all;
close all;
fclose('all');

thispath = fileparts(mfilename('fullpath'));
% Edit the path/wildcard for the instrument-specific parameter files.  This
% will likely be in **your local** SVN copy.
INC_FILTER = [thispath,'\INC_PARAMS_*'];

%% Housekeeping

toptimestamp = now;
logtimestamp = datestr(toptimestamp,'yyyymmdd_hhMMss');
nctimestamp = datestr(toptimestamp);
perca = 1 + (0:99); % Percentage array

disp(['INFO: Running ',mfilename]);

%% Read instrument-specific parameters from config file.
[ParameterFile,ParameterPath]=uigetfile(INC_FILTER,'Select the instrument-specific parameters include file.');
% Running the file populates the variables.
run(fullfile(ParameterPath,ParameterFile));
disp(['INFO: Searching for ',HOST,' ',INSTRUMENT,' data.']);

%% Select binary flatfiles FILE BY FILE
[binfiles,PathName,FilterIndex] = uigetfile('*.bin','Select binary flatfiles','Multiselect','on');
% Write the filepath/names to a cell array.
cd(PathName);
% If you only select one file, turn it into a cell array anyway.
if ~iscell(binfiles)
    binfiles = {binfiles};
end
numbinfiles = length(binfiles);
disp(['INFO: Selected ',num2str(numbinfiles),' ',INSTRUMENT,' binary flatfile(s).']);
% %% Select binary flatfiles MASS DIRECTORY
% PathNameChosen = uigetdir('Select binary directories');
% % Write the filepath/names to a cell array.
% cd(PathNameChosen);
% binfiles = dir (['*.',EXTENSION]);
% % If you only select one file, turn it into a cell array anyway.

% numbinfiles = cellfun(@(field) length(field),binfiles);
% disp(['INFO: Selected ',num2str(numbinfiles),' ',INSTRUMENT,' binary flatfile(s).']);
%% Create an output directory to put the L0 files in.
% Create a new folder with today's datestamp to put the new L0 files in.
timestamp = datestr(now,'yyyymmddHHMM');
outputdir = ['Raw_to_L0_',timestamp];
disp(['INFO: Creating output directory .\',outputdir]);
mkdir (outputdir);

qqq=fopen('VCDU_Analysis3.txt','w+');

%% Iterate through each file in turn.

for kk=1:numbinfiles
    BinFileName = binfiles{kk};
    %BinPathName = binfiles{1}(kk).folder;
    FileName = BinFileName;
    BinPathName = PathName;
disp(['BinPathName:', BinPathName])
    disp('===================================================================');
    disp(['INFO: Opening file ',num2str(kk),'/',num2str(numbinfiles),' ',BinFileName]);
    %fid = fopen(fullfile(BinPathName,BinFileName),'r');
    fid = fopen(BinFileName,'r');
    clear data;
    data = fread(fid);
    fclose(fid);
    numbytes = length(data);
    disp(['INFO: Read in ',num2str(numbytes),' bytes.']);
    
    % If we are GPIM (IMESA), we need to get rid of the interleaved CADUs.
    if strcmp(HOST,'GPIM')
        GPIM_CADU_Extractor;
    end
    
    % If we are STPSat-4, we need to get rid of the interleaved CADUs.
%     if strcmp(HOST,'STPSat-4')
%         STPSat4_CADU_Extractor;
%     end
    
    % If we are STPSat-6 (FalconSEED), we need to get rid of the interleaved CADUs.
    if strcmp(HOST,'STPSat-6')
        STPSat6_CADU_Extractor;
    end
    
    % If we are STP-H7 (Falcon Neuro), we need to get rid of the DICE wrappers.
    if strcmp(HOST,'STP-H7')
        %STPH7_DICE_Extractor;
    end

    % If we are STP-H7 (Falcon Neuro), we need to get rid of the DICE wrappers.
    if strcmp(HOST,'STP-H9')
        STPH9_DICE_Extractor;
    end

    
    % Search through the current file to look for packet types.
    % If we find a packet, check its CRC.  If the CRC is bad, NaN the
    % packet.
    totpackets = 0;
    L0_Type_Finder2;
    
    if totpackets == 0
        disp('ERROR: No instrument packets found in this file.');
        disp('ERROR: Skipping this file.');
        %error('erk4');
        continue;
    end
    
    % Write this Raw file to a L0 NetCDF file
    disp(['STATUS: Creating NetCDF L0 file (any existing file will be overwritten)...']);
    
    
    ncfilename = [FileName,'_L0.nc'];
    fullncfilename = fullfile(BinPathName,outputdir,ncfilename);
    ncid_L0 = netcdf.create(fullncfilename,'CLOBBER');
      
    disp(['INFO: ',ncfilename,' L0 file created in .\',outputdir]);
    
    % Now we populate the globals just the once, and
    % may as well do it here.
    varid = netcdf.getConstant('GLOBAL');
    
    netcdf.putAtt(ncid_L0,varid,'instrument',INSTRUMENT);
    netcdf.putAtt(ncid_L0,varid,'host',HOST);
    netcdf.putAtt(ncid_L0,varid,'epoch',EPOCH);
    netcdf.putAtt(ncid_L0,varid,'parameterfile',ParameterFile);
    netcdf.putAtt(ncid_L0,varid,'parameterpath',ParameterPath);
    
    
    netcdf.putAtt(ncid_L0,varid,'parameterfile',ParameterFile);
    
    % Housekeeping
    netcdf.putAtt(ncid_L0,varid,'nc_creation_time',nctimestamp);
    netcdf.putAtt(ncid_L0,varid,'source_filename',FileName);
    netcdf.putAtt(ncid_L0,varid,'source_pathname',PathName);
    
    fatts = dir(FileName);
    fct = fatts.date;
    netcdf.putAtt(ncid_L0,varid,'source_filename_modified_time',fct);
    netcdf.putAtt(ncid_L0,varid,'num_packet_types',len_packet_types);
    
    netcdf.endDef(ncid_L0);
    
    if totpackets>0
        %for i=1:len_packet_types
        %for i=1:length(PACKET_TYPES)
        %for i = 1:length(PACKET_TYPES)
        for i=1:length(PACKET_TYPES)
            packet_type = ['name_packet_type_',num2str(i)];
            data_packet_name = ['data_packet_type_',num2str(i)]; % 1,2,3...etc
            num_packet_name = ['num_packet_type_',num2str(i)]; % 1,2,3...etc
            len_packet_name = ['len_packet_type_',num2str(i)];
            len_packet = eval(genvarname(['TYPE',num2str(i),'_PKT_LEN']));
            pt = char(PACKET_TYPES(i));
            

            
            %pt_dim0 = netcdf.defDim(ncid_L1,pt_today_len,SECS_PER_DAY);
            
            %         % Re-enter define mode
            %         netcdf.reDef(ncid_L1);
            %         pt_dim2 = netcdf.defDim(ncid_L1,L1_name,pt_len);
            %         if pt_len > 1
            %             varid = netcdf.defVar(ncid_L1,pt_dsc_name,'double',[pt_dim0 pt_dim2]);
            %         else
            %             varid = netcdf.defVar(ncid_L1,pt_dsc_name,'double',pt_dim0);
            %         end
            
            %netcdf.endDef(ncid_L0);
            if isfield(data_packets,num_packet_name)
                
                dp = data_packets.(data_packet_name);
                [np,lb] = size(dp);

                if (np > 0)
                    
                    
                    netcdf.reDef(ncid_L0);
                    
                    
                    pt_dim0 = netcdf.defDim(ncid_L0,num_packet_name,np);
                    pt_dim1 = netcdf.defDim(ncid_L0,len_packet_name,lb);
                    
                    varid2 = netcdf.defVar(ncid_L0,data_packet_name,'double',[pt_dim0 pt_dim1]);
                    
                    netcdf.endDef(ncid_L0);
                    dp2 = double(dp);
                    netcdf.putVar(ncid_L0,varid2,dp2);
                    
                end
                %             nccreate(fullncfilename,data_packet_name,'Dimensions',{num_packet_name,np,len_packet_name,lb}');
                %             ncwrite(fullncfilename,data_packet_name,dp);
                
            end
        end
            
    end
        
        netcdf.close(ncid_L0);
    end
    
    %% Housekeeping at end
    fclose(qqq);
    disp(['STATUS: L0 files closed.']);
    disp(['ACTION: Now run the L0 to L1 script.']);

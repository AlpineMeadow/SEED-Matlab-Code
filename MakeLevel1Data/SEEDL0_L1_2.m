function [] = SEEDL0_L1_2(Paths)

fclose('all');
close all;

%Read in the Parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
run([Paths.MatlabPath, ParameterFile])

toptimestamp = now;
nctimestamp = datestr(toptimestamp);

all_source_files = {};

%I am making a test case for removing NaN's.
removeEntireSpectra = 1;

% Select L0 files.
L0files = {dir(Paths.L0FilesPathSTP6).name};


% If you only select one file, turn it into a cell array anyway.
if ~iscell(L0files)
    L0files = {L0files};
    numL0files = 1;
else
    L0files = sort(L0files);
    numL0files = length(L0files);
end
disp(['INFO: Selected ',num2str(numL0files),' L0 file(s).']);

% Read in data from each file
all_data = struct();
for f=1:numL0files

    % Open each file in turn.
    fpn = [Paths.L0FilesPath,L0files{f}];

    ncid_L0 = netcdf.open(fpn,'NOWRITE');
    disp(['STATUS: Opened ',L0files{f},' L0 file for reading.']);
    
    % Read the number of dimensions, variables, and attributes to make sure
    % it's not an empty file.
    [ndims,nvars,natts,~] = netcdf.inq(ncid_L0);
    if (ndims == 0) || (natts == 0) || (nvars == 0)
        disp('ERROR: L0 file has insufficient fields to proceed.');
        disp('ERROR: Skipping this file.');
        continue;
    end
    
    % Read in the L0 file attributes into a temporary structure
    for j=0:natts-1
        attname = ['att',num2str(j)];
        L0_att_name.(attname) = netcdf.inqAttName(ncid_L0,netcdf.getConstant('NC_GLOBAL'),j);
        L0_att_val.(attname) = netcdf.getAtt(ncid_L0,netcdf.getConstant('NC_GLOBAL'),L0_att_name.(attname));
    end
    
    % Read in the L0 file dimensions into a temporary structure
    for j=0:ndims-1
        dimname = ['dim',num2str(j)];
        [L0_dim_name.(dimname),L0_dim_len.(dimname)] = netcdf.inqDim(ncid_L0,j);
    end
    
    % Read in the L0 file variables into a temporary structure
    for j=0:nvars-1
        varname = ['var',num2str(j)];
        L0_var_name.(varname) = netcdf.inqVar(ncid_L0,j);
        L0_var_val.(varname) = netcdf.getVar(ncid_L0,j);
    end

    len_PACKET_TYPES = length(PACKET_TYPES);
    len_PACKET_PARAMS = length(PACKET_PARAMS);
    len_PACKET_PARAM_ATTRIBS = length(PACKET_PARAM_ATTRIBS);
    
%    cd (PathName); % Go back to the L0 file directory
    
    % Verify the INC file attributes are all correct.
    param_matrix = zeros(len_PACKET_TYPES,len_PACKET_PARAMS,len_PACKET_PARAM_ATTRIBS);
    param_good = zeros(len_PACKET_TYPES,len_PACKET_PARAMS);
    for i=1:len_PACKET_TYPES
        for j=1:len_PACKET_PARAMS
            for k=1:len_PACKET_PARAM_ATTRIBS
                paramname = [join(['TYPE',num2str(i),'_PKT_',PACKET_PARAMS(j),'_',...
					PACKET_PARAM_ATTRIBS(k)],"")];
                if exist(paramname, 'var') ~= 1
                else
                    param_matrix(i,j,k) = 1;
                end
            end
            param_good(i,j) = sum(param_matrix(i,j,len_PACKET_PARAM_ATTRIBS));
        end
    end

    for t=1:length(PACKET_TYPES)
        pt_num = 0;
        data_packet_name = ['data_packet_type_',num2str(t)]; % 1,2,3...etc

        %Look through all the dimensions.
        for l=0:nvars-1
            if strcmp(L0_var_name.(['var',num2str(l)]),['data_packet_type_',num2str(t)])
                pt_num = size(L0_var_val.(['var',num2str(l)]),1);
                data_id = netcdf.inqVarID(ncid_L0,data_packet_name);
                data_data = (netcdf.getVar(ncid_L0,data_id));
                name=['all_data_packet_type_',num2str(t)];
                if isfield(all_data,name)
                    all_data.(name) = cat(1,all_data.(name),data_data);
                else
                    all_data.(name) = data_data;
                end
            end
        end
        
    end
    
    all_source_files = cat(1,all_source_files,...
			   netcdf.getAtt(ncid_L0,netcdf.getConstant('NC_GLOBAL'),...
					 'source_filename'));
    netcdf.close(ncid_L0);
    
end % f

% Extract every parameter that is defined properly in the INC file.
% Only do this once.
pt_today_len = 'NUMBER_OF_PACKETS';

for t=1:length(PACKET_TYPES)

    new_pt_name = ['TYPE',num2str(t),'_PKT_NUM'];

    for j=1:len_PACKET_PARAMS % Time, Temp, Sweep Voltage, etc.
        if param_good(t,j)
            pt_varroot = join(['TYPE',num2str(t),'_PKT_',PACKET_PARAMS(j)],"");
            
            pt_dsc = eval(genvarname(join([pt_varroot,'_DSC'],"")));
            pt_pos = eval(genvarname(join([pt_varroot,'_POS'],"")));
            pt_len = eval(genvarname(join([pt_varroot,'_LEN'],"")));
            pt_bpd = eval(genvarname(join([pt_varroot,'_BPD'],"")));
            lendian = exist(join([pt_varroot,'_LENDIAN'],""), 'var');
            
            pt_len_name = char(join([pt_varroot,'_LEN'],""));
            pt_dsc_name = char(join([pt_varroot,'_ARRAY'],""));
            
            % Just the telemetry field in the packet
            name=['all_data_packet_type_',num2str(t)];
            if ~isfield(all_data,name)
                continue
            end
            data_data = all_data.(name);


            % FalconSEED only: fix broken spectra
            if strcmp(INSTRUMENT,'FalconSEED') 
                disp('>> Checking for broken spectra')
                
                www=zeros(1,size(data_data,1));
                dp5syncra = sscanf('F5FA','%2x')';
                for qq=1:size(data_data,1)
                    dp5sync = strfind(data_data(qq,:),dp5syncra);
                    www(qq)=length(dp5sync);
                    if length(dp5sync)>3
                        %disp([num2str(qq),' > ',num2str(dp5sync)]);
                        data_data(qq,dp5sync(4):3300)=NaN;
                    end
                    if length(dp5sync)<3
                        %disp([num2str(qq),' > ',num2str(dp5sync)]);
                        data_data(qq,:)=NaN;
                    end                    
                end

            end
            pt_field = data_data(:,pt_pos:pt_pos+(pt_bpd*pt_len)-1);
            ptf_num = size(pt_field,1);            

            pt_field_2 = squeeze(reshape(pt_field,ptf_num,pt_bpd,pt_len));
            
            % ...and sum multi-byte datapoints
            % Turn into a cell array...
            pt_field_2_cell = num2cell(pt_field_2,2);
            % ...sum the bytes in the field and squeeze any single
            % dimension (again)
            % This is now an array <x> data points long.
            pt_data_1 = double(squeeze(cellfun(@(x) bytesum(x,lendian), pt_field_2_cell)));
            
            if (strcmp(PACKET_PARAMS(j), 'DATA_TIME'))
                % array of times, with repeats, with time gaps, across
                % multiple days
                aaa1 = pt_data_1;
                hdatatime = (itime2htime(pt_data_1, EPOCH, TICKSPERSEC));
                
                
                % uhdatatime is unique times sorted, with time gaps, across
                % multiple days
                % iaunt is the index of those times in the original array.
                [~,iaunt,~] = unique(hdatatime);
                ohdatatime=hdatatime;
                [hdatatime,~,ic] = unique(hdatatime);
                hdatatime = hdatatime(~isnan(hdatatime));
                
                [udays,ia,ic] = unique(floor(hdatatime)); % unique MATLAB days
                
                num_packets = accumarray(ic,1);
                doys = date2doy(udays); % unique days of year
                ndoys = length(doys); % number of days of year
                revsweep=zeros(ndoys,SECS_PER_DAY);
                mode_num = zeros(ndoys,NUM_MODES+1);
            end
            
             pt_data_unique_sweeps = pt_data_1(iaunt,:);
            
            for k=1:ndoys
               
                doy = doys(k);
                idxtoday = find(floor(hdatatime)==udays(k));
                pt_dim0val = length(idxtoday);
                if pt_dim0val < 10
                   continue;
                end

                % Open a L1 NetCDF for each day.
                % Create the file name
                d1=[char(HOST),'_',char(INSTRUMENT),'_'];
                d2 = [d1,datestr(udays(k),'yyyymmdd'),num2str(doys(k),'_%03i'),'_L1.nc'];
         		fL1n = [Paths.L1FilesPath,d2];

                % Create the file itself
                if exist(fL1n)==2
                    L1_ids(k) = netcdf.open(fL1n,'WRITE');
                    ncid_L1 = L1_ids(k);

                else
                    disp(['Opening ',d2]);
                    L1_ids(k) = netcdf.create(fL1n,'CLOBBER');
                    ncid_L1 = L1_ids(k);
                    
                    % Now we populate the globals just the once, and
                    % may as well do it here.
                    varid = netcdf.getConstant('GLOBAL');
                    
                    netcdf.putAtt(ncid_L1,varid,'number_of_source_files',num2str(numL0files));
                    netcdf.putAtt(ncid_L1,varid,'instrument',INSTRUMENT);
                    netcdf.putAtt(ncid_L1,varid,'host',HOST);
                    netcdf.putAtt(ncid_L1,varid,'epoch',EPOCH);
                    netcdf.putAtt(ncid_L1,varid,'julianday',num2str(doys(k),'%03i'));
                    netcdf.putAtt(ncid_L1,varid,'date',datestr(udays(k),'yyyy-mm-dd'));
                    netcdf.putAtt(ncid_L1,varid,'parameterfile',ParameterFile);
                    netcdf.putAtt(ncid_L1,varid,'L1_creation_time',nctimestamp);

                    pt_dim0 = netcdf.defDim(ncid_L1,pt_today_len,num_packets(k));
                    pt_dimnsf = netcdf.defDim(ncid_L1,'number of source files',numL0files);
                    netcdf.endDef(ncid_L1);
                    
                end
                netcdf.reDef(ncid_L1);                
                               
                netcdf.endDef(ncid_L1);
                                                
                % pt_len is the dimension of the variable in each
                % sweep, e.g. 4 for dosimeter, 2 for sweep voltage, etc
                L1_name = pt_len_name;

                % Re-enter define mode
                netcdf.reDef(ncid_L1);
                pt_dim2 = netcdf.defDim(ncid_L1,L1_name,pt_len);
                if pt_len > 1
                    varid = netcdf.defVar(ncid_L1,pt_dsc_name,'double',[pt_dim0 pt_dim2]);
                else
                    varid = netcdf.defVar(ncid_L1,pt_dsc_name,'double',pt_dim0);
                end
                netcdf.endDef(ncid_L1);
                
                % But pt_data_1 is only ptf_num data points long, not 86400 (one second
                % cadence) long, so we need to make another array that is
                % 86400 points long and it's all NaNs.
                today_pt_data_1 = zeros(pt_dim0val,pt_len);
                
                if length(idxtoday) > 1
                    today_pt_data_1(:,:) = pt_data_unique_sweeps(idxtoday,:);
                    today_pt_data_1=squeeze(today_pt_data_1);

                    % Actually write the variable
                    netcdf.putVar(ncid_L1,varid,today_pt_data_1);
                    
                    if (strcmp(PACKET_PARAMS(j), 'INST_TIME'))
                        inst_time = today_pt_data_1;
                    end
                    
                    if (strcmp(PACKET_PARAMS(j), 'DOSIMETER'))
                        dosimeter = today_pt_data_1;
                    end
                    
                    if (strcmp(PACKET_PARAMS(j), 'SPECTRA'))
                        spectra = today_pt_data_1;
                    end

                    if (strcmp(PACKET_PARAMS(j), 'SWEEP_VOLTAGE'))
                        svolt = today_pt_data_1;
                    end
                                        
                    if (strcmp(PACKET_PARAMS(j), 'SWEEP_DATA'))
                        sdata = today_pt_data_1;
                    end
                                        
                    if (strcmp(PACKET_PARAMS(j), 'TEMPERATURE_BRAINS'))
                        temperature = today_pt_data_1;
                    end
                    
                    if (strcmp(PACKET_PARAMS(j), 'DATA_TIME'))
                        a_data_time = today_pt_data_1;
                    end
                end

                % Re-enter define mode
                netcdf.reDef(ncid_L1);
                netcdf.putAtt(ncid_L1,varid,'description',pt_dsc);
                netcdf.putAtt(ncid_L1,varid,'position in packet in bytes',pt_pos);
                netcdf.putAtt(ncid_L1,varid,'field length in bytes',pt_len);
                netcdf.putAtt(ncid_L1,varid,'data length in bytes',pt_bpd);
                netcdf.putAtt(ncid_L1,varid,'packet type',char(PACKET_TYPES(t)));
                
                gvarid = netcdf.getConstant('GLOBAL');
                netcdf.putAtt(ncid_L1,gvarid,'data_earliest_today',datestr(hdatatime(idxtoday(1))));
                netcdf.putAtt(ncid_L1,gvarid,'data_latest_today',datestr(hdatatime(idxtoday(end))));
                netcdf.putAtt(ncid_L1,gvarid,'num_packets_today',num_packets(k));
                netcdf.putAtt(ncid_L1,gvarid,'num_acqs_per_mode',mode_num(k,:));
                netcdf.endDef(ncid_L1);
            end
        end
    end
end

for k=1:ndoys
    try
        netcdf.close(L1_ids(k));
    catch
    end
end

disp('ACTION: Now run the QDV script or process beyond L1.');

end

function  SEEDL0_L1(info)

%This function is called by STPSatRise.m


%Read in the Parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
run([info.MatlabPath, ParameterFile])

fileTimeStr = datestr(now, 'hhMMss');

toptimestamp = now;
nctimestamp = datestr(toptimestamp);

allSourceFiles = {};

%Get a list of the file names in the L1 directory.
L1Files = {dir(info.L1FilesPath).name};
numL1Files = length(L1Files);

%There is a problem if we already have files in the L1 directory.  So we
%delete them.  This only really comes up when I am writing code or
%debugging code.
if numL1Files > 2
    for i = 3 : numL1Files
%        disp([info.L1FilesPath, L1Files{i}])
        delete([info.L1FilesPath, L1Files{i}])
    end
end
% Select L0 files.
L0files = {dir(info.L0FilesPathSTP6).name};

% If you only select one file, turn it into a cell array anyway.
if ~iscell(L0files)
    L0files = {L0files};
    numL0files = 1;
else
    L0files = sort(L0files);
    numL0files = length(L0files);
end

%disp(['INFO: Selected ',num2str(numL0files),' L0 file(s).']);

% Read in data from each file
all_data = struct();
for f = 1 : numL0files

    % Open each file in turn.
    fpn = [info.L0FilesPath, L0files{f}];

    ncid_L0 = netcdf.open(fpn, 'NOWRITE');
%    disp(['STATUS: Opened ',L0files{f},' L0 file for reading.']);
    
    % Read the number of dimensions, variables, and attributes to make sure
    % it's not an empty file.
    [ndims,nvars,natts,~] = netcdf.inq(ncid_L0);
    if (ndims == 0) || (natts == 0) || (nvars == 0)
%        disp('ERROR: L0 file has insufficient fields to proceed.');
%        disp('ERROR: Skipping this file.');
        continue;
    end
    
    % Read in the L0 file attributes into a temporary structure
    for j=0:natts-1
        attname = ['att',num2str(j)];
        L0_att_name.(attname) = netcdf.inqAttName(ncid_L0,netcdf.getConstant('NC_GLOBAL'),j);
        L0_att_val.(attname) = netcdf.getAtt(ncid_L0,netcdf.getConstant('NC_GLOBAL'),...
		  L0_att_name.(attname));
    end
    
    % Read in the L0 file dimensions into a temporary structure
    for j=0:ndims-1
        dimname = ['dim',num2str(j)];
        [L0_dim_name.(dimname),L0_dim_len.(dimname)] = netcdf.inqDim(ncid_L0,j);
    end
    
    % Read in the L0 file variables into a temporary structure
    for j = 0 : nvars - 1
        varname = ['var',num2str(j)];
        L0_var_name.(varname) = netcdf.inqVar(ncid_L0,j);
    end  %End of for loop - for j = 0 : nvars - 1
        
    numPacketTypes = length(PACKET_TYPES);
    numPacketParams = length(PACKET_PARAMS);

    %Determine which flags are present.  The array paramFlags will be a
    %vector of 1's and 0's, with 1 indicating a parameter is present and a
    %0 indicating a parameter is not present.
    paramFlags = generateParamFlags(info, PACKET_TYPES, PACKET_PARAMS, ...
                    PACKET_PARAM_ATTRIBS);

    %Loop through the packet types.
    for t = 1 : numPacketTypes

        data_packet_name = ['data_packet_type_',num2str(t)]; % 1,2,3...etc

        %Loop through all the dimensions.
        for l = 0 : nvars - 1

            if strcmp(L0_var_name.(['var',num2str(l)]),['data_packet_type_',num2str(t)])
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
    
    allSourceFiles = cat(1, allSourceFiles,...
			 netcdf.getAtt(ncid_L0,netcdf.getConstant('NC_GLOBAL'),...
				       'source_filename'));
    netcdf.close(ncid_L0);
    
end %End of for loop - for f = 1 : numL0files


% Extract every parameter that is defined properly in the INC file.
pt_today_len = 'NUMBER_OF_PACKETS';

for t = 1 : numPacketTypes
    for j = 1 : numPacketParams % Time, Temp, Sweep Voltage, etc.
        
        if paramFlags(t, j)
            pt_varroot = join(['TYPE',num2str(t),'_PKT_',PACKET_PARAMS(j)],"");
            
            pt_dsc = eval(genvarname(join([pt_varroot,'_DSC'],"")));
            pt_pos = eval(genvarname(join([pt_varroot,'_POS'],"")));
            pt_len = eval(genvarname(join([pt_varroot,'_LEN'],"")));
            pt_bpd = eval(genvarname(join([pt_varroot,'_BPD'],"")));
            lendian = exist(join([pt_varroot,'_LENDIAN'],""), 'var');
            
            pt_len_name = char(join([pt_varroot,'_LEN'],""));
            pt_dsc_name = char(join([pt_varroot,'_ARRAY'],""));

            % Just the telemetry field in the packet
            name= ['all_data_packet_type_',num2str(t)];
            if ~isfield(all_data, name)
                continue
            end  %End of if statement - if ~isfield(all_data, name)

            %Get the data out of the structure and into an array.
            data_data = all_data.(name);

            %I am having memory problems.  I do not know where this is
            %happening so I am trying a few things.  The structure all_data
            %is huge it is of size [247720, 4096].  After the command (just
            %above) of data_data = all_data.(name);  it is no longer used.
            %Actually it is! It is inside 3 loops.
            
%            clear all_data
    
            % FalconSEED only: fix broken spectra
            if strcmp(INSTRUMENT,'FalconSEED') 

                %Richard defines this variable "www" as an array and then
                %fills the array but then never uses it.
                www=zeros(1,size(data_data,1));

                %Here Richard converted 'F5FA' into two decimal numbers.
                %F5 equals 245 and FA = 250.  I do not understand why he
                %did this, why not just have Matlab search for 245 and 250?
                dp5syncra = sscanf('F5FA','%2x')';

                for qq=1:size(data_data,1)
                    dp5sync = strfind(data_data(qq,:),dp5syncra);
                    www(qq)=length(dp5sync);

                    if length(dp5sync) ~= 3
                        data_data(qq, :) = NaN;
                    end  %End of if statement - if length(dp5sync) ~= 3

                end  %End of for loop - for qq=1:size(data_data,1)

            end  %End of if statement -  if strcmp(INSTRUMENT,'FalconSEED') 
	    
            pt_field = data_data(:,pt_pos:pt_pos+(pt_bpd*pt_len)-1);
            ptf_num = size(pt_field,1);
            
            pt_field_2 = squeeze(reshape(pt_field,ptf_num,pt_bpd,pt_len));
            
            % ...and sum multi-byte datapoints
            % Turn into a cell array...
            pt_field_2_cell = num2cell(pt_field_2,2);
            % ...sum the bytes in the field and squeeze any single
            % dimension (again)
            % This is now an array <x> data points long.
            pt_data_1 = double(squeeze(cellfun(@(x) bytesum(x,lendian), ...
                            pt_field_2_cell)));
            
            if (strcmp(PACKET_PARAMS(j), 'DATA_TIME'))
                % array of times, with repeats, with time gaps, across
                % multiple days

                hdatatime = (itime2htime(pt_data_1, EPOCH, TICKSPERSEC));
                                
                % uhdatatime is unique times sorted, with time gaps, across
                % multiple days
                % iaunt is the index of those times in the original array.
                [~,iaunt,~] = unique(hdatatime);

                [hdatatime,~,~] = unique(hdatatime);
                hdatatime = hdatatime(~isnan(hdatatime));
                
                [udays,~,ic] = unique(floor(hdatatime)); % unique MATLAB days
                
                num_packets = accumarray(ic,1);
                %On June 10, 2025 I got an error that said date2doy does
                %not exist.  I do not know what happened to it.  I have
                %generated a workaround that I hope will do the trick.  The
                %original statement is just below.
                %doys = date2doy(udays); % unique days of year
                %In order to get this program to work, I have the following
                %commands.
                doys = day(datetime(udays, 'ConvertFrom', 'datenum'), ...
                    'dayofyear');
                ndoys = length(doys); % number of days of year
                mode_num = zeros(ndoys,NUM_MODES+1);
            end
            
             pt_data_unique_sweeps = pt_data_1(iaunt,:);
             L1_ids = zeros(1, ndoys);
            
            for k = 1 : ndoys
               
                idxtoday = find(floor(hdatatime)==udays(k));
                pt_dim0val = length(idxtoday);
                if pt_dim0val < 10
                   continue;
                end %End of if statement - if pt_dim0val < 10

                % Open a L1 NetCDF for each day.
                % Create the file name
                d1=[char(HOST),'_',char(INSTRUMENT),'_'];

                %Renaming the files so that we do not overwrite them.
                d2 = [d1, datestr(udays(k), 'yyyymmdd'), '_', ...
                    num2str(doys(k),'%03i'), '_', fileTimeStr, '_L1.nc'];

                %Generate the filename for the output files.
                %Changing this to reflect that the files need to be put in
                %the correct directory instead of all the files being put 
                %in the same directory.
                fL1n = [info.L1RootPath, num2str(doys(k), '%03d'), '/', d2];

         		% Create the file itself		
                if exist(fL1n, 'file') == 2
                    L1_ids(k) = netcdf.open(fL1n,'WRITE');
                    ncid_L1 = L1_ids(k);

                else
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
                    netcdf.endDef(ncid_L1);
                    
                end  %End of if-else clause - if exist(fL1n, 'file') == 2

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
                end  %End of if-else clause - if pt_len > 1

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
                                        
                end  %End of if statement - if length(idxtoday) > 1
                
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

            end %End of for loop - for k=1:ndoys
            
        end %End of if statement - if paramFlags(t, j)
    end  %End of for loop - for j=1:numPacketParams
end  %End of for loop - for t=1:numPacketTypes

   
if exist('ndoys', 'var')
    for k = 1 : ndoys
        try
            netcdf.close(L1_ids(k));
        catch
        end  %End of try-catch clause.
    end  %End of for loop - for k = 1 : ndoys
end  %End of the if statement - if exist(ndoys, 'var')

clear all_data
clear data_data

end  %End of the function SEEDL0_L1.m
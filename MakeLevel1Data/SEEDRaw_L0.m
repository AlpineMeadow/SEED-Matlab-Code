function [] = SEEDRaw_L0(Paths)


binfiles = {dir(Paths.rawFilesPathSTP6).name};

%Set up some file paths for later inclusion in the script.
CADUExtractor = [Paths.MatlabPath, 'STPSat6_CADU_Extractor'];
L0TypeFinder = [Paths.MatlabPath, 'L0_Type_Finder2'];

toptimestamp = now;
nctimestamp = datestr(toptimestamp);

%Read in the Parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
run([Paths.MatlabPath ParameterFile])


numbinfiles = length(binfiles);
disp(['INFO: Selected ',num2str(numbinfiles),' ',INSTRUMENT,' binary flatfile(s).']);


qqq=fopen('VCDU_Analysis3.txt','w+');

%% Iterate through each file in turn.

for kk=1:numbinfiles
    BinFileName = binfiles{kk};
    FileName = BinFileName;

    disp('===================================================================');
    disp(['INFO: Opening file ',num2str(kk),'/',num2str(numbinfiles),' ',BinFileName]);

    fid = fopen([Paths.rawFilesPath, BinFileName],'r');

    clear data;
    data = fread(fid);
    fclose(fid);
    numbytes = length(data);
    disp(['INFO: Read in ',num2str(numbytes),' bytes.']);
    
    % If we are STPSat-6 (FalconSEED), we need to get rid of the interleaved CADUs.
    if strcmp(HOST,'STPSat-6')
      run(CADUExtractor);
    end
    
    % Search through the current file to look for packet types.
    % If we find a packet, check its CRC.  If the CRC is bad, NaN the
    % packet.
    totpackets = 0;
    run(L0TypeFinder);
    
    if totpackets == 0
        disp('ERROR: No instrument packets found in this file.');
        disp('ERROR: Skipping this file.');
        %error('erk4');
        continue;
    end
    
    % Write this Raw file to a L0 NetCDF file
    disp(['STATUS: Creating NetCDF L0 file (any existing file will be overwritten)...']);
    
    
    ncfilename = [FileName,'_L0.nc'];
    fullncfilename = [Paths.L0OutputDir, ncfilename];
    disp(fullncfilename)
    ncid_L0 = netcdf.create(fullncfilename,'CLOBBER');
      
    disp(['INFO: ',ncfilename,' L0 file created in .\',Paths.L0OutputDir]);
    
    % Now we populate the globals just the once, and
    % may as well do it here.
    varid = netcdf.getConstant('GLOBAL');
    
    netcdf.putAtt(ncid_L0,varid,'instrument',INSTRUMENT);
    netcdf.putAtt(ncid_L0,varid,'host',HOST);
    netcdf.putAtt(ncid_L0,varid,'epoch',EPOCH);
    netcdf.putAtt(ncid_L0,varid,'parameterfile',ParameterFile);
    netcdf.putAtt(ncid_L0,varid,'parameterpath',Paths.MatlabPath);        
    netcdf.putAtt(ncid_L0,varid,'parameterfile',ParameterFile);
    
    % Housekeeping
    netcdf.putAtt(ncid_L0,varid,'nc_creation_time',nctimestamp);
    netcdf.putAtt(ncid_L0,varid,'source_filename',FileName);
    netcdf.putAtt(ncid_L0,varid,'source_pathname',Paths.rawFilesPath);

    fatts = dir(Paths.rawFilesPath);
    fct = fatts.date;
    netcdf.putAtt(ncid_L0,varid,'source_filename_modified_time',fct);
    netcdf.putAtt(ncid_L0,varid,'num_packet_types',len_packet_types);
    
    netcdf.endDef(ncid_L0);
    
    if totpackets>0
        for i=1:length(PACKET_TYPES)
            packet_type = ['name_packet_type_',num2str(i)];
            data_packet_name = ['data_packet_type_',num2str(i)]; % 1,2,3...etc
            num_packet_name = ['num_packet_type_',num2str(i)]; % 1,2,3...etc
            len_packet_name = ['len_packet_type_',num2str(i)];
            len_packet = eval(genvarname(['TYPE',num2str(i),'_PKT_LEN']));
            pt = char(PACKET_TYPES(i));
            
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
            end
        end
            
    end
        
        netcdf.close(ncid_L0);
    end
    
    %% Housekeeping at end
%    fclose(qqq);
    disp(['ACTION: Now run the L0 to L1 script.']);

end

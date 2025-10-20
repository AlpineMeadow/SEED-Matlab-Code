function SEEDRaw_L0(info, mdn)

%This function will raise the SEED data files from the raw level to level
%0.  This function is called by STPSatRise.m.  This code was mostly written
%by Richard and so I have not changed much of it.

%Convert the mission day to day of year.
[dayOfYear, year] = MDNToDN(mdn);

rawDirName = [info.STPSat6RootDir, 'SEED/', info.startYearStr, '/Raw/DayOfYear_', ...
        num2str(dayOfYear, '%03d')];

dirName = [rawDirName, '/STP6*'];

binfiles = {dir(dirName).name};

%Set up some file paths for later inclusion in the script.
CADUExtractor = ['/SS1/STPSat-6/MatlabCode/Functions/STPSat6_CADU_Extractor'];
L0TypeFinder = ['/SS1/STPSat-6/MatlabCode/Functions/L0_Type_Finder2'];

toptimestamp = now;
nctimestamp = datestr(toptimestamp);

%Read in the Parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
run(['/SS1/Matlab/', ParameterFile])

numbinfiles = length(binfiles);

% Iterate through each file in turn.
for kk = 1 : numbinfiles
    BinFileName = binfiles{kk};
    
    %Open the file to read in the data.
    fname = [rawDirName, '/', BinFileName];
    disp(['Opening file : ', fname]);
    fid = fopen(fname, 'r');

    clear data;
    data = fread(fid);
    fclose(fid);

    %We need to get rid of the interleaved CADUs.
    data = STPSat6_CADU_Extractor(data);
 
    
    % Search through the current file to look for packet types.
    % If we find a packet, check its CRC.  If the CRC is bad, NaN the
    % packet.
    totpackets = 0;
    run(L0TypeFinder);
    
    if totpackets == 0
%        disp('ERROR: No instrument packets found in this file.');
%        disp('ERROR: Skipping this file.');
        continue;
    end  %End of if statement - if totpackets == 0
    
    % Write this Raw file to a L0 NetCDF file
    ncfilename = [BinFileName,'_L0.nc'];
    fullncfilename = [info.L0OutputDir, ncfilename];
    ncid_L0 = netcdf.create(fullncfilename,'CLOBBER');
          
    % Now we populate the globals just the once, and
    % may as well do it here.
    varid = netcdf.getConstant('GLOBAL');
    
    netcdf.putAtt(ncid_L0,varid,'instrument',INSTRUMENT);
    netcdf.putAtt(ncid_L0,varid,'host',HOST);
    netcdf.putAtt(ncid_L0,varid,'epoch',EPOCH);
    netcdf.putAtt(ncid_L0,varid,'parameterfile',ParameterFile);
    
    % Housekeeping
    netcdf.putAtt(ncid_L0,varid,'nc_creation_time',nctimestamp);
    netcdf.putAtt(ncid_L0,varid,'source_filename',BinFileName);
    netcdf.putAtt(ncid_L0,varid,'source_pathname',info.rawFilesPath);

    fatts = dir(info.rawFilesPath);
    fct = fatts.date;
    netcdf.putAtt(ncid_L0,varid,'source_filename_modified_time',fct);
    netcdf.putAtt(ncid_L0,varid,'num_packet_types',len_packet_types);
    
    netcdf.endDef(ncid_L0);
    
    if totpackets > 0
        for i = 1 : length(PACKET_TYPES)
            data_packet_name = ['data_packet_type_',num2str(i)]; % 1,2,3...etc
            num_packet_name = ['num_packet_type_',num2str(i)]; % 1,2,3...etc
            len_packet_name = ['len_packet_type_',num2str(i)];
            
            if isfield(data_packets,num_packet_name)
                
                dp = data_packets.(data_packet_name);
                [np,lb] = size(dp);

                if (np > 0)                   
                    
                    netcdf.reDef(ncid_L0);
                    
                    pt_dim0 = netcdf.defDim(ncid_L0,num_packet_name,np);
                    pt_dim1 = netcdf.defDim(ncid_L0,len_packet_name,lb);
                    
                    varid2 = netcdf.defVar(ncid_L0, data_packet_name, ...
                            'double',[pt_dim0 pt_dim1]);
                    
                    netcdf.endDef(ncid_L0);
                    dp2 = double(dp);
                    netcdf.putVar(ncid_L0, varid2, dp2);
                    
                end %End of if statement - if (np > 0)
            end %End of if statement - if isfield(data_packets,num_packet_name)
        end  %End of for loop - for i=1:length(PACKET_TYPES)
            
    end  %End of if statement - if totpackets > 0
        
    netcdf.close(ncid_L0);    
end %End of the for loop - for kk 1 : numinfiles

joe = 1;

end %End of the function SEEDRaw_L0(info, mdn)

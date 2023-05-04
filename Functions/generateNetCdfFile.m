function generateNetCdfFile(info, outFilename, time, Data, ...
    InstrumentName, dateStr, dayOfYearStr)

%Check to see if the outfile already exists.  If it does, we will delete it
%since I cannot get Matlab to overwrite it.
if exist(outFilename, 'file') == 2
    delete(outFilename)
end

%Get the number of instances and energy channels.
[numInstances, numChannels] = size(Data);

%Check to see if is exists.
if exist(outFilename, 'file') == 2
    fileID = netcdf.open(outFilename, 'WRITE');
else
    fileID = netcdf.create(outFilename, 'CLOBBER');
end

%Define the data dimensions.
timeDimID = netcdf.defDim(fileID, 'TIME', numInstances);
dataDimID = netcdf.defDim(fileID, 'CHANNELS', numChannels);

%Define the data variables.
timeID = netcdf.defVar(fileID, 'Time', 'NC_DOUBLE', timeDimID);
dataID = netcdf.defVar(fileID, 'Data', 'NC_DOUBLE', [timeDimID, dataDimID]);

%Define the various attributes.
varid = netcdf.getConstant('GLOBAL');

netcdf.putAtt(fileID,varid,'instrument', info.Instrument);
netcdf.putAtt(fileID,varid,'host', info.Host);
netcdf.putAtt(fileID,varid,'julianday', dayOfYearStr);
netcdf.putAtt(fileID,varid,'date', dateStr);
netcdf.putAtt(fileID,varid,'L1_creation_time', datestr(now));

%End definitions.
netcdf.endDef(fileID);

%Now put the data into the file.
netcdf.putVar(fileID, timeID, time);
netcdf.putVar(fileID, dataID, Data);

%Close the file
netcdf.close(fileID);

end  %End of the unction generateNetCdfFile.m
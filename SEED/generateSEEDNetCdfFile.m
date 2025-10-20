function generateSEEDNetCdfFile(fluxStructure, energyBins, time, fileName, ...
    info)

    netcdfFileName = [info.dataDir, 'STPSat-6_FalconSEED_', info.yearStr, ...
    info.monthStr, info.dayOfMonthStr, '_', info.dayOfYearStr, '_L2.nc'];

    %This function is called by FalconSEEDFlux.m  It will generate
    %netcdf files 

    flux = fluxStructure.fluxActual;
    
    if exist(fileName, 'file') == 2
        delete(fileName)
    end
    
   %Get the number of instances and energy channels.
   [numInstances, numEnergyChannels] = size(flux);

   %Determine the instrument values to be saved. 
   InstrumentName = 'SEED';

   %Check to see if is exists.
   if exist(fileName, 'file') == 2
       fileID = netcdf.open(fileName, 'WRITE');
   else
       fileID = netcdf.create(fileName, 'CLOBBER');
   end

   %Define the two data dimensions.
   timeDimID = netcdf.defDim(fileID, 'TIME', numInstances);
   dataDimID = netcdf.defDim(fileID, 'ENERGYBINS', numEnergyChannels);

   %Define the three data variables.
   timeID = netcdf.defVar(fileID, 'SEEDTime', 'NC_DOUBLE', timeDimID);
   dataID = netcdf.defVar(fileID, 'SEEDData', 'NC_DOUBLE', [timeDimID, dataDimID]);
   energyID = netcdf.defVar(fileID, 'SEEDEnergy', 'NC_DOUBLE', dataDimID);

   %Define the various attributes.                    
   varid = netcdf.getConstant('GLOBAL');
   Host = 'STPSat-6';
   dateStr = [info.yearStr, info.monthStr, info.dayOfMonthStr];

   netcdf.putAtt(fileID,varid,'instrument',InstrumentName);                    
   netcdf.putAtt(fileID,varid,'host',Host);                    
   netcdf.putAtt(fileID,varid,'julianday',info.dayOfYearStr);                    
   netcdf.putAtt(fileID,varid,'date',dateStr);                    
   netcdf.putAtt(fileID,varid,'L1_creation_time',datestr(now));

   %End definitions.
   netcdf.endDef(fileID);

   %Now put the data into the file.
   netcdf.putVar(fileID, timeID, time);
   netcdf.putVar(fileID, dataID, flux);
   netcdf.putVar(fileID, energyID, energyBins(:, 2));

   %Close the file
   netcdf.close(fileID);

end  %End of the function generateSEEDNetCdfFile.m
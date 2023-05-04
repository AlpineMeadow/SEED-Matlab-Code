function generateLosAlamosNetcdfFile(info, fname, DosimeterTime, DosimeterCounts, ...
	DosimeterDose, SEEDTime, SEEDCounts, SEEDFlux, energyBins)

   %This function generates the netcdf file.


   %Get the number of instances for the dosimeter.
   numDoseInstances = length(DosimeterTime);

   %Get the number of instances for the spectrometer.
   numSEEDInstances = length(SEEDTime);

   %Generate the filename of the netcdf file that will be output.
   fileName = [info.LosAlamosOutputDataDir, fname];

   %Get the Level 1 ID.
   L1ID = netcdf.create(fileName, 'CLOBBER');

   %Define the data dimensions.
   DosimeterTimeDimID = netcdf.defDim(L1ID, 'DOSIMETER_TIME', numDoseInstances);
   DosimeterDimID = netcdf.defDim(L1ID, 'DOSIMETER_CHANNELS', 1);

   SEEDTimeDimID = netcdf.defDim(L1ID, 'SEED_TIME', numSEEDInstances);
   SEEDEnergyDimID = netcdf.defDim(L1ID, 'SEED_ENERGY_BINS', 1024);

   %Define the dosimeter data variables.
   DosimeterTimeDataID = netcdf.defVar(L1ID, 'Dosimeter_Time', 'NC_DOUBLE', DosimeterTimeDimID);
   DosimeterCountDataID = netcdf.defVar(L1ID, 'Dosimeter_Counts', 'NC_DOUBLE', [DosimeterTimeDimID, DosimeterDimID]);
   DosimeterDoseDataID = netcdf.defVar(L1ID, 'Dosimeter_Dose', 'NC_DOUBLE', [DosimeterTimeDimID, DosimeterDimID]);
   
   %Define the SEED data variables.
   SEEDTimeDataID = netcdf.defVar(L1ID, 'Spectrometer_Time', 'NC_DOUBLE', SEEDTimeDimID);
   SEEDCountsDataID = netcdf.defVar(L1ID, 'Spectrometer_Counts', 'NC_DOUBLE', [SEEDTimeDimID, SEEDEnergyDimID]);
   SEEDFluxDataID = netcdf.defVar(L1ID, 'Spectrometer_Flux', 'NC_DOUBLE', [SEEDTimeDimID, SEEDEnergyDimID]);
   SEEDEnergyBinDataID = netcdf.defVar(L1ID, 'Spectrometer_Energy_Bin_Center_Energy', 'NC_DOUBLE', SEEDEnergyDimID);

   %Define the various attributes.                    
   varid = netcdf.getConstant('GLOBAL');

   %Add the various data attributes to the file.   
   netcdf.putAtt(L1ID,varid,'Dosimeter_Dose_Units', 'Rads'); 
   netcdf.putAtt(L1ID,varid,'Dosimeter_Time_Units', 'UTC');
 
   netcdf.putAtt(L1ID,varid,'Spectrometer_Energy_Units', 'keV');
   netcdf.putAtt(L1ID,varid,'Spectrometer_Flux_Units', 'Counts/(keV s cm^2 ster)');
   netcdf.putAtt(L1ID,varid,'Spectrometer_Time_Units', 'UTC');

   netcdf.putAtt(L1ID,varid,'Day_Of_Year', num2str(info.startDayOfYear,'%03d'));                    
   netcdf.putAtt(L1ID,varid,'date',datestr(datetime(info.startYear, info.startMonth, ...
    info.startDayOfMonth,'Format', 'yyyy-MM-dd')));                    

   %End definitions.
   netcdf.endDef(L1ID);

   %Now put the data into the file.
   netcdf.putVar(L1ID, DosimeterTimeDataID, DosimeterTime);
   netcdf.putVar(L1ID, DosimeterCountDataID, DosimeterCounts);
   netcdf.putVar(L1ID, DosimeterDoseDataID, DosimeterDose);
   netcdf.putVar(L1ID, SEEDTimeDataID, SEEDTime);
   netcdf.putVar(L1ID, SEEDCountsDataID, SEEDCounts);
   netcdf.putVar(L1ID, SEEDFluxDataID, SEEDFlux);
   netcdf.putVar(L1ID, SEEDEnergyBinDataID, energyBins);

   %Close the file
   netcdf.close(L1ID);

end  %End of the function generateLosAlamosNetcdfFile.m
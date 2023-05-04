function [DosimeterTime, DosimeterCounts, DosimeterDose, SpecTime, SpecCounts, ...
	SpecFlux, SpecEnergyBins] = LosAlamosGetNetcdfData(info)

    %This function will return the netcdf data from the SEED mission.
    %the data.  The input is the info structure.  Neither the attributes or
	%the dimensions are output from this function although the data is
	%available.  

	%Generate the file name to be opened.
	fname = ['LosAlamos_STPSat-6_FalconSEED_', info.startYearStr, info.startMonthStr, ...
		info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];
	fileName = [info.LosAlamosInputDataDir, fname];


    %First open the file for reading.
    fileID = netcdf.open(fileName,'NOWRITE');


    % Read the number of dimensions, variables, and attributes to make sure
    % it's not an empty file.
    [ndims, nvars, natts, ~] = netcdf.inq(fileID);

    %Check to see if the file is intact.
    if (ndims == 0) || (natts == 0) || (nvars == 0)
        error('ERROR: L1 file has insufficient fields to proceed.');
    end  %End of if statement.

    % Read in the L1 file attributes 
    for j = 0 : natts - 1
        attname = ['att',num2str(j)];
        attributeName.(attname) = netcdf.inqAttName(fileID,netcdf.getConstant('NC_GLOBAL'), j);
        attributeValue.(attname) = netcdf.getAtt(fileID,netcdf.getConstant('NC_GLOBAL'),attributeName.(attname));
        Attributes.(attributeName.(attname)) = attributeValue.(attname); 
    end  %End of for loop - for j = 0 : natts - 1

    % Read in the L1 file dimensions 
    for j = 0 : ndims - 1
        dimname = ['dim',num2str(j)];
        [Dimensions.(dimname), netcdfDimLength.(dimname)] = netcdf.inqDim(fileID, j);
    end  %End of for loop - for j = 0 : ndims - 1

    % Read in the L1 file variables 
    for j = 0 : nvars - 1
        varname = ['var',num2str(j)];
        variableName.(varname) = netcdf.inqVar(fileID, j);
        varValue.(varname) = netcdf.getVar(fileID, j);
        data.(variableName.(varname)) = varValue.(varname);
    end  %End of for loop - for j = 0 : nvars - 1

	%Now return the data.
	DosimeterTime = data.Dosimeter_Time;
	DosimeterCounts = data.Dosimeter_Counts;
	DosimeterDose = data.Dosimeter_Dose;

	SpecTime = data.Spectrometer_Time;
	SpecCounts = data.Spectrometer_Counts;
	SpecFlux = data.Spectrometer_Flux;
	SpecEnergyBins = data.Spectrometer_Energy_Bin_Center_Energy;

end  %End of function LosAlamosGetNetcdfData.m
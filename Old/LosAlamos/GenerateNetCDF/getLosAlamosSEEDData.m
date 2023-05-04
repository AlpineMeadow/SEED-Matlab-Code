function [SEEDTime, SEEDCounts, SEEDFlux] = getLosAlamosSEEDData(info);

   %This function will return the netcdf attributes and dimensions as well as
    %the data.  The input is the info structure.

    %This function is called by LosAlamosNetCDFFiles.m

	%Generate a file name.
	fname = ['STPSat-6_FalconSEED_', info.startYearStr, info.startMonthStr, ...
		info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];
	fileName = [info.LosAlamosInputSEEDDataDir, fname];

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


	%Get the correct time for the data.  We also return the correctly
	%time shifted counts.
	[SEEDTime, SEEDCounts] = LosAlamosSetSEEDTime(info, data);


	%Determine the energy bin width.
	deltaE = 0.1465;  %Units are in keV.

	%Determine the time bin width.
	deltaT = 0.5;  %Units are in seconds.

	%Determine the geometric factor width.
	g = 3.0e-6;  %Units of cm^2 st.  Taken from paper.

	%The flux is detemined from the counts by dividing the counts by the
	%energy, time and geometric factor.  Since none of these are time or energy
	%dependent I do not need to loop over any of the quantities.
	SEEDFlux = SEEDCounts./(deltaE*deltaT*g);


end  %End of the function getLosAlamosSEEDData.m

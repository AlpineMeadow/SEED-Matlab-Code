function [Attributes, Dimensions, data] = getNETCDFData(info)

    %Generate the file name for the data to be analyzed.  This will change
    %depending on the user.
    PathName = [info.SEEDRootDir, info.startYearStr, '/L1/DayOfYear_', ...
        info.startDayOfYearStr, '/'];

    %Generate the file names.
    L1File = ['STPSat-6_FalconSEED_2022', info.startMonthStr, ...
		info.startDayOfMonthStr, '_', info.startDayOfYearStr, '_L1.nc'];  
    fileName = [PathName, L1File];

    %This function will return the netcdf attributes and dimensions as well as
    %the data.  The input is a string containing the filename and path to where
    %the data file is located.

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


end  %End of the function getNETCDFData.m
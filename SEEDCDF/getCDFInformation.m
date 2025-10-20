function infoCDF = getCDFInformation(info)

%This function will create a structure that holds the global and variable
%attributes needed to correctly fill out the CDF files.

%Get the global attributes.
infoCDF = getCDFGlobalAttributes(info);

%Get the variable attributes.
infoCDF = getCDFVariableAttributes(info, infoCDF);

end  %End of the function getCDFInformation.m
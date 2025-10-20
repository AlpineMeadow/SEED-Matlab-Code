function paramFlags = generateParamFlags(info, packetTypes, packetParams, ...
                    packetParamAttribs)

% Verify the INC file attributes are all correct. 
%This function will generate an array of parameter flags to be used to
%determine whether or not any given parameter exists.  This function is
%called by SEEDL0_L1.m.

%Read in the Parameter file.
ParameterFile = 'INC_PARAMS_STPSat6_FalconSEED.m';
run([info.MatlabPath, ParameterFile])

%Find the number of packet attributes and types.
numPacketTypes = length(packetTypes);
numPacketParams = length(packetParams);
numPacketParamAttribs = length(packetParamAttribs);

%Set up two matrices of zeros.  
paramMatrix = zeros(numPacketTypes, numPacketParams, numPacketParamAttribs);
paramFlags = zeros(numPacketTypes, numPacketParams);
    
%Loop through the packet types.
for i=1:numPacketTypes
    
    %Loop through the packet params.
    for j=1:numPacketParams
    
        %Loop through the packet attributes.
        for k=1:numPacketParamAttribs

            %Create a param name.
            paramname = [join(['TYPE', num2str(i), '_PKT_', ...
                    packetParams(j),'_', packetParamAttribs(k)],"")];
               
            %Check to see if the param name is a variable.
            if exist(paramname, 'var') ~= 1

            else
               paramMatrix(i, j, k) = 1;
            end
        end
            
        paramFlags(i,j) = sum(paramMatrix(i,j,numPacketParamAttribs));
    end
end

end  %End of the function generateParamFlags.m
function  data = SEEDL0_L1(inData)

%This function is called by SEEDRaw_L0.m.  It checks the data for
%interlaced CADU's and removes them.  The function returns the data array
%but without the interlaced CADU's.

cadustart = strfind(inData', sscanf('1ACFFC1D', '%2x')');
numcadus = length(cadustart);
caducounter = zeros(numcadus, 1);

numDataPoints = length(inData);

for i = 1 : numcadus
%    disp(['Index in STPSat6_CADU_Extractor : ', num2str(i)])
    cs = cadustart(i);
    lo = cs - 12;

    if lo < 1
        lo = 1;
    end

    hi = cs + 20;
    
    if hi > numDataPoints
        hi = numDataPoints;
    end

    % hi=lo+1;
    caducounter(i) = bytesum(inData(cs+6 : cs+8), 0);
    inData(lo : hi) = NaN;
       
    % Get rid of CP_PDU header
    data = inData(find(~isnan(inData)));    
end %End of for loop - for i = 1 : numcadus

end  %End of the function STPSat6_CADU_Extractor.m
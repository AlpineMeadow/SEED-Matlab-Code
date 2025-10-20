function GOESData = GOESRemoveMissingData(GOESDataRaw)

%Find any data points that are missing.
zeroIndex = find(GOESDataRaw < 0);

%Check to see if all of the data is missing.
if length(zeroIndex) == length(GOESDataRaw)
    GOESData = ones(length(GOESDataRaw), 1);
    disp('The data are completely missing')
    return;
end


if length(zeroIndex) ~= 0
%    zeroIndexPlus = zeroIndex - 1;
%    if zeroIndexPlus(1) == 0
%        zeroIndexPlus(1) = 1;
%    end
%    GOESDataRaw(zeroIndex) = GOESDataRaw(zeroIndexPlus);
    GOESDataRaw(zeroIndex) = 1.0;
    GOESData = GOESDataRaw;
else
    GOESData = GOESDataRaw;
end

end  %End of the function GOESRemoveMissingData.m
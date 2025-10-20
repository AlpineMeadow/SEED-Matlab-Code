%This script will test the CDF functions.


clearvars;
close all;
fclose('all');

masterfilenameCDF = ['/SS1/STPSat-6/CDF/', ...
    'stpsat-6_h0_falconseed_00000000_v01.cdf'];

%Get the master file information.
CDFInfo = spdfcdfinfo(masterfilenameCDF);


for p = 1:length(CDFInfo.Variables(:,1))
    compress{(2*p)-1} = CDFInfo.Variables(p,1); 	% Variable name
    compress{2*p} = CDFInfo.Variables(p,7);	% Variable compression
    sparse{(2*p)-1} = CDFInfo.Variables(p,1);	% Variable name
    sparse{2*p} = CDFInfo.Variables(p,6);	% Variable sparseness
    bf{2*p-1} = CDFInfo.Variables{p,1};		% Variable name
    bf{2*p} = CDFInfo.Variables{p,8};		% Variable blocking factor
    pad{2*p-1} = CDFInfo.Variables{p,1};		% Variable name
    pad{2*p} = CDFInfo.Variables{p,9};		% Variable pad value
    datatypes{2*p-1} = CDFInfo.Variables{p,1};	% Variable name
    datatypes{2*p} = CDFInfo.Variables{p,4};	% Variable data type
end




   rbvars = {info.Variables{:,1}};		% Variable names for recordbound
%   for p = length(rbvars):-1:1
%     if (strncmpi(info.Variables{p,5},'f',1)==1)	% NRV variable
%       rbvars(:,p)=[]; 	  		% Remove it
%     end
%   end
%   if isnumeric(info.FileSettings.CompressionParam) % A number for Gzip parameter 
%     cdfcompress=strcat(info.FileSettings.Compression, '.', ... % Make it 'gzip.x'
%                        num2str(info.FileSettings.CompressionParam));
%   else
%     cdfcompress=strcat(info.FileSettings.Compression, '.', ... % None or non-gzip
%                        info.FileSettings.CompressionParam);
%   end
%
%   % fill data
%   for p = 1:length(info.Variables(:,1))
%     varsdata{2*p-1} = info.Variables{p,1};
%     if (p == 15)				% A sparse record variable 
%       var15data={single([123 321]);[];[];[];single([-321 -123])};
%       varsdata{(2*15)} = var15data;		% Sparse record data
%     else
%       varsdata{(2*p)} = [...];		% Normal data
%     end
%   end














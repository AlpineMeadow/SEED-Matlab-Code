%This script will mv the cdf files to a single place so that I can upload
%them onto teams.

year = 2023;
yearStr = num2str(year);
for i = 60:100
    doyStr = num2str(i, '%03d');
    rootDirStr = ['/SS1/STPSat-6/SEED/', yearStr, '/L1/DayOfYear_'];
    fileName = [rootDirStr, doyStr, '/*.cdf'];
    mvDir = '/SS1/STPSat-6/SEED/';
    command = ['cp ', fileName, ' ', mvDir];
    status = system(command);
    disp(command)
end

% year = 2022;
% for i = 15:365
%     doyStr = num2str(i, '%03d');
% 
%     DateVector = datevec(datenum(year, 0, i));
%     Month = DateVector(2);
%     DayOfMonth = DateVector(3);
% 
%     rootDirStr = '/SS1/STPSat-6/SEED/STPSat-6_Falcon_SEED-L1_';
%     fileName = [rootDirStr, num2str(year), num2str(Month, '%02d'), ...
%         num2str(DayOfMonth, '%02d'), '_v01.cdf'];
%     mvDir = ['/SS1/STPSat-6/SEED/', num2str(year), '/L1/DayOfYear_', ...
%         doyStr, '/'];
%     command = ['mv ', fileName, ' ', mvDir];
%     status = system(command);
% %    disp(command)
% end


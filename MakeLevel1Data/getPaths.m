function Paths = getPaths(year, dayOfYear, rootPath, Instrument)

%Set up some paths using a structure.

Paths.includeFiles = '/SS1/Matlab/';
Paths.rootPath = rootPath;
Paths.MatlabPath = [rootPath, 'MatlabCode/'];

yearStr = num2str(year);
dayOfYearStr = num2str(dayOfYear, '%03d');

fillStr = [rootPath, Instrument, '/', yearStr];

if strcmp(Instrument, 'SEED')
    Paths.rawFilesPath = [fillStr, '/Raw/DayOfYear_', dayOfYearStr, '/'];
    Paths.rawFilesPathSTP6 = [fillStr, '/Raw/DayOfYear_', dayOfYearStr, '/STP6*'];
    Paths.L0FilesPath = [fillStr, '/L0/DayOfYear_', dayOfYearStr, '/'];
    Paths.L0FilesPathSTP6 = [fillStr, '/L0/DayOfYear_', dayOfYearStr, '/STP6*'];
    Paths.L1FilesPath = [fillStr, '/L1/DayOfYear_', dayOfYearStr, '/'];
    Paths.L1FilesPathSTP6 = [fillStr, '/L1/DayOfYear_', dayOfYearStr, '/STP6*']; 
    Paths.L1RootPath = [fillStr, '/L1/DayOfYear_'];
    Paths.L2FilesPath = [fillStr, '/L2/DayOfYear_', dayOfYearStr, '/'];
    Paths.L2FilesPathSTP6 = [fillStr, '/L2/DayOfYear_', dayOfYearStr, '/STP6*'];
    Paths.L2RootPath = [fillStr, '/L2/DayOfYear_'];
    Paths.L0OutputDir = [fillStr, '/L0/DayOfYear_', dayOfYearStr, '/'];
    Paths.L1OutputDir = [fillStr, '/L1/DayOfYear_', dayOfYearStr, '/'];
    Paths.L2OutputDir = [fillStr, '/L2/DayOfYear_', dayOfYearStr, '/'];
end
if strcmp(Instrument, 'EPEE')
    Paths.rawFilesPath = [fillStr, '/Raw/DayOfYear_', dayOfYearStr, '/'];
    Paths.rawFilesPathSTPH9 = [fillStr, '/Raw/DayOfYear_', dayOfYearStr, '/STP-H9*'];
    Paths.L0FilesPath = [fillStr, '/L0/DayOfYear_', dayOfYearStr, '/'];
    Paths.L0FilesPathSTPH9 = [fillStr, '/L0/DayOfYear_', dayOfYearStr, '/STP-H9*'];   
    Paths.L1FilesPath = [fillStr, '/L1/DayOfYear_', dayOfYearStr, '/'];
    Paths.L1FilesPathSTPH9 = [fillStr, '/L1/DayOfYear_', dayOfYearStr, '/STP-H9*'];
    Paths.L2FilesPath = [fillStr, '/L2/DayOfYear_', dayOfYearStr, '/'];
    Paths.L2FilesPathSTPH9 = [fillStr, '/L2/DayOfYear_', dayOfYearStr, '/STP-H9*'];
    Paths.L0OutputDir = [fillStr, '/L0/DayOfYear_', dayOfYearStr, '/'];
    Paths.L1OutputDir = [fillStr, '/L1/DayOfYear_', dayOfYearStr, '/'];
    Paths.L2OutputDir = [fillStr, '/L2/DayOfYear_', dayOfYearStr, '/'];
end


end  %End of the function generatePaths.m
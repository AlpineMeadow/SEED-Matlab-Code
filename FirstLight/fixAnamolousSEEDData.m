function [data1, data2] = ...
    fixAnamolousSEEDData(AverageSEEDElectronEnergy1, ...
    AverageSEEDElectronEnergy2, deltaLimit)

%This function is called by plotGOESData.m.  It will attempt to fix some of
%the anamolous SEED data points by looking at the values of the differenced
%data points.

%Lets save the electron data to extra variables.
data1 = AverageSEEDElectronEnergy1;
data2 = AverageSEEDElectronEnergy2;

%First replace any NaN values with the mean of the data not including the
%NaN values.
meanData1 = mean(data1, 'omitnan');
meanData2 = mean(data2, 'omitnan');

%Next replace all NaN values with the mean.
nanIndex1 = find(isnan(data1) == 1);
nanIndex2 = find(isnan(data2) == 1);

data1(nanIndex1) = meanData1;
data2(nanIndex2) = meanData2;

%Now let us find the difference between the data points.
datalength = length(data1);
deltadata1 = diff(data1);
deltadata2 = diff(data2);

%By the way of generating a difference the first entry in the deltadata
%variable will be zero.  Let us just replace this with the value in the
%first non-zero entry.  This is not correct but it allows for an easier
%analysis.
deltadata1(1) = deltadata1(2);
deltadata2(1) = deltadata2(2);

%Let us make the deltadata variables be the same length as the original
%data variables. 
deltadata1 = [deltadata1(2), deltadata1];
deltadata2 = [deltadata2(2), deltadata2];

%Now lets find the large delta flux values.
%First set up an arbitrary value that we can compare against.  This is just
%empirical and would probably not work for every data set we will analyze.
%For now this is the best compromise.
deltaLimit = 1.0e6;
largeFluxIndex1 = find(deltadata1 > deltaLimit | deltadata1 < -deltaLimit);
largeFluxIndex2 = find(deltadata2 > deltaLimit | deltadata1 < -deltaLimit);


%Use the large delta values to replace the actual values with the mean.
data1(largeFluxIndex1) = meanData1;
data2(largeFluxIndex2) = meanData2;

end  %End of the function fixAnamolousSEEDData.m
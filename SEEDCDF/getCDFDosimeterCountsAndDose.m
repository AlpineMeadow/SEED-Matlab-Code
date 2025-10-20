function [DosimeterCounts, DosimeterDose] = ...
    getCDFDosimeterCountsAndDose(info, TT2000DosimeterCounts)

%This function is called by exportSEEDCDF.m.  This function will use the
%results from plotCDFDosimeterData.m to set the correct count values to be
%exported.  This function will then convert the counts to dose and return
%the results along with the chosen times.

%We need to difference the data.
%Subtract interval (i + 1) from interval (i).
orderOfDifference = 1;  

%The dimension over which the difference will be calculated.
%Here we are working with the rows which has array dimension = 1.
arrayDimension = 1;  

%Get the count difference for channel 1.
countDifference1 = diff(TT2000DosimeterCounts(:, 1), orderOfDifference, ...
    arrayDimension);

%Now lets add the first row of TT2000DosimeterCounts to the differenced data in
%countDifference1.
countDifference1 = [TT2000DosimeterCounts(1, 1); countDifference1];

%Get the count difference for channel 2.
countDifference2 = diff(TT2000DosimeterCounts(:, 2), orderOfDifference, ...
    arrayDimension);

%Now lets add the first row of TT2000DosimeterCounts to the differenced data in
%countDifference1.
countDifference2 = [TT2000DosimeterCounts(1, 2); countDifference2];

%Get the count difference for channel 3.
countDifference3 = diff(TT2000DosimeterCounts(:, 3), orderOfDifference, ...
    arrayDimension);

%Now lets add the first row of TT2000DosimeterCounts to the differenced data in
%countDifference1.
countDifference3 = [TT2000DosimeterCounts(1, 3); countDifference3];

%These count limits were detemined by trial and error.  They may not be
%perfect for any given day.  Do not know what else to do.  It may be a good
%idea to check that these values are okay for days 139-229 as this set of
%days did not have the 20 minute reset procedure operating.
lowerCountsLimitChannel1 = -5;
lowerCountsLimitChannel2 = 1;
lowerCountsLimitChannel3 = 0;

%We have decided to only present channels 1 through 3 of the dosimeter.

%Set the valid minimum and valid maximum values for the dosimeter.  These
%are taken from the CDF master file.
validMin = 0;
%This is 4*2^12.  This is not correct but I cannot seem to get a clear
%answer as to what this size actually is! 
validMax = 16384;  

% %Set out the variables for the different channels.
% countsChannel1 = TT2000DosimeterCounts(:, 1);
% countsChannel2 = TT2000DosimeterCounts(:, 2);
% countsChannel3 = TT2000DosimeterCounts(:, 3);

%Get rid of the negative counts.
countDifference1(countDifference1 < lowerCountsLimitChannel1) = validMin;
countDifference2(countDifference2 < lowerCountsLimitChannel2) = validMin;
countDifference3(countDifference3 < lowerCountsLimitChannel3) = validMin;

%Now set any high value to NaN.  We do this because the instrument had a
%12-bit data value which translates to a maximum count value of 4096. This
%is then multiplied by 4. If any data values are higher than this
%there is some kind of error(hardware or software).  It is not real.  As
%there appear to be few of these let's just set them to NaNs.
countDifference1(countDifference1 > 16384) = validMax;
countDifference2(countDifference2 > 16384) = validMax;
countDifference3(countDifference3 > 16384) = validMax;

%Put the various variables into a structure.
DosimeterCounts.channel1 = countDifference1;
DosimeterCounts.channel2 = countDifference2;
DosimeterCounts.channel3 = countDifference3;

%Now convert from counts to dose.
doseChannel1 = info.DosimeterChannel1CountsToRads*countDifference1;
doseChannel2 = info.DosimeterChannel2CountsToRads*countDifference2;
doseChannel3 = info.DosimeterChannel3CountsToRads*countDifference3;

%Put the various variables into a structure.
DosimeterDose.channel1 = doseChannel1;
DosimeterDose.channel2 = doseChannel2;
DosimeterDose.channel3 = doseChannel3;

end  %End of the function getCDFDosimeterCountsAndDose.m
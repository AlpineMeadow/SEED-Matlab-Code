function dosePerDay = getDosimeterDose(info, rawTime, rawDose, xvalues, xdays)

%This function will calculate the dosimeter dose rate from the dosimeter
%counts.  I will use the paper "Calibration and Initial Results of Space
%Radiation Dosimetry Using the iMESA-R", page 4, Table 2, Column 5.  This
%may not be exactly correct but the instrument are the same manufacture and
%this is the best we have.


%Lets make a histogram and plot of the time values.
%dosimeterDoseTimeHistogram(info, rawTime, xvalues, xdays)
%dosimeterDoseTimeSeries(info, rawTime, xvalues, xdays, rawDose);

%Now find the difference between the rows.
orderOfDifference = 1;  %This will always be what we want.
arrayDimension = 1;  %This will always be what we want.
countDifferenceChannel1 = diff(rawDose(:, 1), orderOfDifference, arrayDimension);
countDifferenceChannel2 = diff(rawDose(:, 2), orderOfDifference, arrayDimension);
countDifferenceChannel3 = diff(rawDose(:, 3), orderOfDifference, arrayDimension);
countDifferenceChannel4 = diff(rawDose(:, 4), orderOfDifference, arrayDimension);

%Find the conversion factor between counts and dose.			
newChannel1CountsToRads = findConversionFactor(countDifferenceChannel1, info);

%We need to prepend the original first row to the new array.
countsChannel1 = [rawDose(1, 1); countDifferenceChannel1];
countsChannel2 = [rawDose(1, 2); countDifferenceChannel2];
countsChannel3 = [rawDose(1, 3); countDifferenceChannel3];
countsChannel4 = [rawDose(1, 4); countDifferenceChannel4];

%Now set any negative differences to NaN.  This may not be what we want to
%do.  Lets look at how it looks.  We may just want to take the absolute
%value of the entire data array.
%counts(counts < 0) = 0;
countsChannel1(countsChannel1 < 0) = NaN;
countsChannel2(countsChannel2 < 0) = NaN;
countsChannel3(countsChannel3 < 0) = NaN;
countsChannel4(countsChannel4 < 0) = NaN;

%Now set any high value to NaN.  We do this because the instrument had a
%12-bit data value which translates to a maximum count value of 4096. 
%If any data values are higher than this
%there is some kind of error(hardware or software).  It is not real.  As
%there appear to be few of these lets just set them to NaNs.
countsChannel1(countsChannel1 > 4096) = NaN;
countsChannel2(countsChannel2 > 4096) = NaN;
countsChannel3(countsChannel3 > 4096) = NaN;
countsChannel4(countsChannel4 > 4096) = NaN;

%Set up an array that will hold the dose per day.
dosePerDay = zeros(4, length(xdays));

%Now we sum up the counts for the day.
for i = 1 : length(xdays)
    if(i == 1)

%		dosePerDay(1, i) = timeConversionFactor(1)*info.channel1CountsToRads*sum(countsChannel1(1:xvalues(i)), 'omitnan');
		dosePerDay(1, i) = info.channel1CountsToRads*sum(countsChannel1(1:xvalues(i)), 'omitnan');
        dosePerDay(2, i) = info.channel2CountsToRads*sum(countsChannel2(1:xvalues(i)), 'omitnan');
        dosePerDay(3, i) = info.channel3CountsToRads*sum(countsChannel3(1:xvalues(i)), 'omitnan');
        dosePerDay(4, i) = info.channel4CountsToRads*sum(countsChannel4(1:xvalues(i)), 'omitnan');
    else
%        dosePerDay(1, i) = timeConversionFactor(i)*info.channel1CountsToRads*sum(countsChannel1(xvalues(i - 1) : xvalues(i)), 'omitnan');
		dosePerDay(1, i) = info.channel1CountsToRads*sum(countsChannel1(xvalues(i - 1) : xvalues(i)), 'omitnan');
        dosePerDay(2, i) = info.channel2CountsToRads*sum(countsChannel2(xvalues(i - 1) : xvalues(i)), 'omitnan');
        dosePerDay(3, i) = info.channel3CountsToRads*sum(countsChannel3(xvalues(i - 1) : xvalues(i)), 'omitnan');
        dosePerDay(4, i) = info.channel4CountsToRads*sum(countsChannel4(xvalues(i - 1) : xvalues(i)), 'omitnan');
    end
end  %End of for loop for i = 1 : length(xdays)

end  %End of the function getDosimeterDose.m
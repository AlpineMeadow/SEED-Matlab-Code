function [SEEDInterpolatedCounts, SEEDInterpolatedTime] = ...
    interpolateSEEDCounts(SEEDTime, smoothConstant, SEEDCounts)

%This function will interpolate the SEED counts onto a grid of 1440 data
%points.
%This function is called by concatGOESSEEDData.m and concatSEEDData.m.

%We will determine the size of the SEEDCounts array.
[numEvents, numEnergyBins] = size(SEEDCounts);

%Set up the interpolated counts array.
SEEDInterpolatedCounts = zeros(1440, numEnergyBins);
SEEDInterpolatedTime = zeros(1, 1440);

%Set up the vector of times to be interpolated into.
tt = 0.0 : 60.0 : 86399.0 ;

%Convert the time from datenum values into datetime values.
ttDatetime = SEEDTime;

%convert the tt values into datetime values.
SEEDInterpolatedTime = datetime(tt, 'ConvertFrom', 'epochtime', ...
    'Epoch', ttDatetime(1));

%Convert from the datetime structure into seconds from start of the day.
timeSeconds = ttDatetime.Hour*3600 + ttDatetime.Minute*60 + ...
    ttDatetime.Second;

%Now loop through the energy channels.
for e = 1 : numEnergyBins

    %convert the counts from type unsigned integers to type double since
    %that is what interp1 requires.
    y = double(SEEDCounts(:, e));

    %Interpolate and smooth the counts.
    if smoothConstant ~= 0
        SEEDInterpolatedCounts(:, e) = smoothdata(interp1(timeSeconds, y, ...
            tt, 'linear'), 'gaussian', smoothConstant);
    else
        SEEDInterpolatedCounts(:, e) = interp1(timeSeconds, y, ...
            tt, 'linear');
    end
end

end  %End of the function interpolateSEEDCounts.m
function temperatureData = convertSEEDTemperature(rawTemperatureData);

%Convert the counts to temperature.  The counts range from -128 to 127. 1
%to 127 are mapped directly to temperature in degrees Celsius.  -127 to 0
%are mapped by taking absolute value and adding to 128.  This converts to
%degrees Celsius.

TData = rawTemperatureData;
TData(TData <= 0) = abs(TData(TData <= 0)) + 128;

temperatureData = TData;

end  %End of the function convertSEEDTemperature.m
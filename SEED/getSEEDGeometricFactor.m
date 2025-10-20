function g = getSEEDGeometricFactor(energyBins)

%This function is called by generateInformationStructure.m

%Calculate (or set) the geometric factor.   This is an issue that needs to
%be solved.  I believe that the geometric factor taken from the paper is
%not quite correct.  One way to check to to compare these results to the
%GOES satellite data and to also compare to available geophysical models
%such as SPENVIS.  
R1 = 1.14; %Units of millimeters.
R2 = 0.25; %Units of millimeters.
h = 6.35;  %Units of millimeters.
conversionFactor = 0.01;  %Convert from mm^2 to cm^2. 1cm^2 = 100mm^2.
g = conversionFactor*0.5*pi^2*(R2^2 + h^2 + R1^2 - ...
    ((h^2 + R1^2 + R2^2)^2 - 4*R1^2*R2^2)^.5);

%We now believe that the paper geometric factor is more likely to be correct.
%Let us use the paper values to find the geometric factor.  The paper
%showed the geometric factor to be a linear function of the energy of the
%particles.  This is not theoretically supported, however, it is likely
%that the energy dependence is present due to the inability of the
%instrument electronics to properly separate the electron energies into the
%correct bins. Or something like that. 

%In any event we have the following set of value taken from the paper.
%      Energy (keV) |    Geometric Factor (cm^2 ster.)
%   
% 1.       15                  0.8x10^-6
% 2.       20                  1.75x10^-6
% 3.       25                  2.5x10^-6
% 4.       30                  3.4x10^-6
%

%Since the data are linear we will assume that we can write a linear
%function that will fit all of the energies.  I think that this is a bad
%idea.  But here we go.

% y1 = m*x1 + b
% y2 = m*x2 + b
% y2 - y1 = m(x2 - x1)
%  m = (y2 - y1)/(x2 - x1)
%  b = y1 - x1*(y2 - y1)/(x2 - x1)

y1 = 0.8e-6;
y2 = 3.4e-6;
x1 = 15.0;
x2 = 30.0;

%Calculate the slope and the intercept.
m = (y2 - y1)/(x2 - x1);
b = y1 - x1*m;

%Get the energy out of the energy bins.
centerEnergy = energyBins(:, 2);

g = m*centerEnergy + b;

%The values for m and b given above result in a negative geometric factor
%for g(1:97). This is non-physical.  I don't really know what to do since
%it is also %nonsensical.  So  I will simply replace all of the 1 through
%97 values with g(98).  Yay!  Also, we are not using any energy channels
%smaller than 120 since the those are filled with noise.
%g(1:97) = g(98);

%g = 3.0e-6;  %Units of cm^2 st.  Taken from paper.

end  %End of the function getSEEDGeometricFactor.m
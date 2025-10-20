function [weightedSEEDEnergy1, weightedSEEDEnergy2, ...
    MPSHIWeightedSEEDEnergy1Flux, MPSHIWeightedSEEDEnergy2Flux] = ...
    getMPSHISEEDCalibrationFactor(info, SEEDElectronFlux)

%This function is called by plotGOESData.m.  This function will use the
%GOES instrument response function for the 1 and 2 energy values to
%calculate a weighting factor and then multiply that factor onto the SEED
%data.

%Load in the instrument response functions.
MPSHIE1fname = "/SS1/STPSat-6/AncillaryData/GOES17/G17_mpshi_E1S_gf.csv";
MPSHIE2fname = "/SS1/STPSat-6/AncillaryData/GOES17/G17_mpshi_E2_gf.csv";
MPSHIData1 = readmatrix(MPSHIE1fname);
MPSHIData2 = readmatrix(MPSHIE2fname);

%Get the SEED energy bins.
energyBins = info.energyBins(:, 2);

%Now interpolate the instrument response functions onto the SEED energy bin
%values.  We use the spline interpolation because the linear procedure
%seems to give NaN's. 
MPSHIInterpolationEnergy1 = interp1(MPSHIData1(:, 1), MPSHIData1(:, 5), ...
    energyBins, 'spline');
MPSHIInterpolationEnergy2 = interp1(MPSHIData2(:, 1), MPSHIData2(:, 5), ...
    energyBins, 'spline');

%Get the SEED data out of the structure.
SEEDFlux = SEEDElectronFlux.deltat15FluxActual;

%Find the normalization factor for each of the MPS-HI interpolated
%instrument response functions.
N1 = sum(MPSHIInterpolationEnergy1);
N2 = sum(MPSHIInterpolationEnergy2);

%Now we convolve the interpolated fluxes onto the SEED data.
weightedSEEDEnergy1 = MPSHIInterpolationEnergy1'./N1*SEEDFlux';
weightedSEEDEnergy2 = MPSHIInterpolationEnergy2'./N2*SEEDFlux';

%Now we try the method Juan Rodriguez suggested.  Here we do not normalize
%by the GOES interpolated energy values.  We instead multiply by the delta
%Energy.  The result of this is that we have the quantity of counts/time
%interval.
MPSHIWeightedSEEDEnergy1Flux = info.deltaE*MPSHIInterpolationEnergy1'*SEEDFlux';
MPSHIWeightedSEEDEnergy2Flux = info.deltaE*MPSHIInterpolationEnergy2'*SEEDFlux';

end  %End of the function getGOESSEEDCalibrationFactor.m
%This script will take the STPSat-6 data from raw to Level 1.
close all;
clearvars;

dbstop if error;

%Set the day to be analyzed.
dayOfYear = 120;
year = 2023;

%I am making a test case for removing NaN's.
removeEntireSpectra = 1;

Paths = generatePaths(year, dayOfYear);

%Now call the function that brings the raw data to Level 0 data.
SEEDRaw_L0(Paths);

%Now call the function that brings the Level 0 data to Level 1 data.
SEEDL0_L1(Paths, year, dayOfYear, removeEntireSpectra);



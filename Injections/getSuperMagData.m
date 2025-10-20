function superMagData = getSuperMagData()

%This function will read in the SuperMag data for the year 2022.
%This function is called by ReadInjectionDB.m

%Create a variable that holds the injection database filename.
SMFilename = '/SS1/STPSat-6/AncillaryData/SuperMag/Data/20231124-20-29-supermag.csv';

%Read in the table.
superMagTable = readtable(SMFilename, 'VariableNamingRule', 'preserve');

%Get the times.  The data are given in YYYY-MM-DD HH:MM:SS.  We do not get
%the seconds because they are all zero.
dt = superMagTable{:, 1};
superMagData.dt = dt;
superMagData.UTCHours = dt.Hour;
superMagData.UTCMinutes = dt.Minute;
superMagData.year = year(dt);
superMagData.month = month(dt);
superMagData.dayOfMonth = day(dt);


%Now get the indices.  The first are the auroral indices.
sme = superMagTable{:, 2};
sml = superMagTable{:, 3};
smu = superMagTable{:, 4};

%Next are the ring current indices.The first is the average of the 4
%partial ring current values.  That is, smr = 0.25*(smr00 + smr06 + smr12 + smr18).
smr = superMagTable{:, 5};
smr00 = superMagTable{:, 6};
smr06 = superMagTable{:, 7};
smr12 = superMagTable{:, 8};
smr18 = superMagTable{:, 9};

superMagData.sme = sme;
superMagData.sml = sml;
superMagData.smu = smu;
superMagData.smr = smr;
superMagData.smr00 = smr00;
superMagData.smr06 = smr06;
superMagData.smr12 = smr12;
superMagData.smr18 = smr18;

end  %End of the function getSuperMagData.m
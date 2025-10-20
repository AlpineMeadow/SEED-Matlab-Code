function infoCDF = getCDFGlobalAttributes(info)

%Text string at PI disposal allowing for information on expected 
%acknowledgment if data is citable.
%Acknowledgement--- recommended
acknowledgement = '';
infoCDF.Acknowledgement = acknowledgement;

%This attribute identifies the data type of the CDF data set. Both a 
%long name and a short name are given. For ISTP exchangeable data products 
%the values are "Kn>Key Parameter" for approximately minute averaged survey 
%data, and "Hn>High Resolution data" for certified data of higher resolution 
%than Key Parameters.$n$ can run from 0 to 9 to allow for more than one 
%kind of data product. For Cluster/CSDS this can either be "SP>Summary 
%Parameter" or "PP>Prime Parameter". Other possible data types may be 
%defined in future. If any of these data sets are modified or used to 
%produce derived products, the data type should be, e.g., "Mn>Modified 
%Data n", where n is from 0 to 9.
%Data_type --- required
dataType = 'H0>High Time Resolution';
infoCDF.Data_type = dataType;

%This attribute identifies the version of a particular CDF data file for a 
%given date, e.g., the file GE_K0_MGF_19920923_V01 is the first version of 
%data for 1992 September 23. Each time this particular data file is 
%reproduced - for recalibration or other reasons - the Data_version is 
%incremented by 1. Data_version always starts at `1'.
%Data_version --- required
CDFDataVersion = ['V', num2str(info.CDFDataVersionNumber, '%03d')];
dataDateStr = [info.startYearStr, info.startMonthStr, ...
    info.startDayOfMonthStr];
dataVersion = '';
infoCDF.Data_version = dataVersion;

%This attribute identifies the name of the instrument or sensor that 
%collected the data. Both a long name and a short name are given. An 
%example for ISTP is "EPI>Energetic Particles and Ion Composition". 
%The short name should be limited to from 2 to 4 characters for consistency 
%with ISTP. This attribute should be single valued.
%Descriptor --- required
descriptor = '';
infoCDF.Descriptor = descriptor;

%This attribute describes both the science discipline and subdiscipline. 
%More than one entry is allowed. The list for space physics is:

 %   "Space Physics>Magnetospheric Science"
 %   `Space Physics>Interplanetary Studies"
 %   `Space Physics>Ionospheric Science"
%Discipline --- required
discipline = 'Space Physics>Magnetospheric Science';
infoCDF.Discipline = discipline;

%Unique Digital Identifier (DOI) as a persistent identifier for the 
%dataset, of the form https://doi.org/<PREFIX>/<SUFFIX> with the <PREFIX> 
%identifying the DOI registration authority and the <SUFFIX> identifying 
%the dataset. The DOI should point to a landing page for additional 
%information about the dataset. DOIs are typically created by the SPASE 
%naming authority or archive.
%DOI --- recommended
DOI = '';
infoCDF.DOI = DOI;

%This attribute allows for the generating data center/group to be identified.
%Generated_by --- recommended
generatedBy = '';
infoCDF.Generated_by = generatedBy;

%Date stamps the creation of the file using the syntax yyyymmdd, e.g., 
%"19920923". This is distinct from the date in "validate" below which 
%records the times of later validation processes.
%Generation_date --- recommended
generationDate = '';
infoCDF.Generation_date = generationDate;

%This attribute stores the URL for the PI or CoI web site holding on-line 
%data. This attribute is used in conjunction with "LINK_TEXT" and 
%"LINK_TITLE". There can be up to 5 entries for each - there MUST be a 
%corresponding entry of "LINK_TEXT" and "LINK_TITLE" for each "HTTP_LINK" 
%entry. CDAWeb will then link to the URL given by "HTTP_LINK" using the 
%"LINK_TITLE" and the description in "LINK_TEXT", on the CDAWeb Data 
%Explorer page. For example

%    "LINK_TEXT" = 3-sec MGF magnetic field 1 Sep 1993 through 30 Sep 2015 
%      available at
%    "LINK_TITLE" = ISAS DARTS
%    "HTTP_LINK" = https://www.darts.isas.jaxa.jp/stp/geotail/ 

%will give the following link:

%3-sec MGF magnetic field 1 Sep 1993 through 30 Sep 2015 available at ISAS 
%DARTS
%HTTP_LINK --- recommended
httpLink = '';
infoCDF.HTTPLINK = httpLink:

%This attribute is used to facilitate making choices of instrument type 
%through CDAWeb. More than one entry is allowed. The following list 
%contains the valid values.

%    Electric Fields (space)
%    Ephemeris
%    Imagers (space)
%    Magnetic Fields (space)
%    Particles (space)
%    Plasma and Solar Wind
%    Radio and Plasma Waves (space)
%    Ground-Based HF-Radars
%    Ground-Based Imagers
%    Ground-Based Magnetometers, Riometers, Sounders
%    Ground-Based VLF/ELF/ULF, Photometers 
%Instrument_type --- required
instrumentType = 'Particles (space)';
infoCDF.Instrument_type = instrumentType;

%This attribute stores text describing on-line data available at PI or 
%CoI web sites. This attribute is used in conjunction with "LINK_TITLE" 
%and "HTTP_LINK". There can be up to 5 entries for each - there MUST be a 
%corresponding entry of "LINK_TITLE" and "HTTP_LINK" for each "LINK_TEXT" 
%entry. CDAWeb will then link to the URL given by "HTTP_LINK" using the 
%"LINK_TITLE" and the description in "LINK_TEXT", on the CDAWeb Data 
%Explorer page. For example,

%    "LINK_TEXT" = 3-sec MGF magnetic field 1 Sep 1993 through 30 Sep 2015 available at
%    "LINK_TITLE" = ISAS DARTS
%    "HTTP_LINK" = https://www.darts.isas.jaxa.jp/stp/geotail/ 

%will give the following link:
%3-sec MGF magnetic field 1 Sep 1993 through 30 Sep 2015 available at ISAS DARTS
%LINK_TEXT --- recommended
linkText = '';
infoCDF.LINK_TEXT = linkText;

%This attribute stores the title of the web site holding on-line data 
%available at PI or CoI web sites. This attribute is used in conjunction 
%with "LINK_TEXT" and "HTTP_LINK". There can be up to 5 entries for each - 
%there MUST be a corresponding entry of "LINK_TEXT" and "HTTP_LINK" for 
%each "LINK_TITLE" entry. CDAWeb will then link to the URL given by 
%"HTTP_LINK" using the "LINK_TITLE" and the description in "LINK_TEXT", 
%on the CDAWeb Data Explorer page. For example

%    "LINK_TEXT" = 3-sec MGF magnetic field 1 Sep 1993 through 30 Sep 2015 available at
%    "LINK_TITLE" = ISAS DARTS
%    "HTTP_LINK" = https://www.darts.isas.jaxa.jp/stp/geotail/ 

%will give the following link:
%3-sec MGF magnetic field 1 Sep 1993 through 30 Sep 2015 available at ISAS DARTS
%LINK_TITLE --- recommended
linkTitle = '';
infoCDF.LINK_TITLE = linkTitle;

%This attribute stores the name of the CDF file using the ISTP naming 
%convention (source_name / data_type / descriptor / date / data_version), 
%e.g., GE_K0_MGF_19920923_V01. This attribute is required (1) to allow 
%storage of the full name on IBM PCs, and (2) to avoid loss of the original 
%source in the case of accidental (or intentional) renaming. For CDFs 
%created on the ISTP CDHF, the correct Logical_file_id will be filled in 
%by an ICSS support routine.
%Logical_file_id --- required
logicalFileID = '';
infoCDF.logical_file_id = logicalFileID;

%This attribute carries source_name, data_type, and descriptor information. 
%Used by CDAWeb.
%Logical_source --- required
logicalSource = '';
infoCDF.Logical_source = logicalSource;

%This attribute writes out the full words associated with the encrypted 
%Logical_source above, e.g., "Geotail Magnetic Field Key Parameters". 
%Used by CDAWeb.
%Logical_source_description --- required
logicalSourceDescription = '';
infoCDF.Logical_source_description = logicalSourceDescription;


%This attribute has a single value and is used to facilitate making choices 
%of source through CDAWeb. Valid values include (but are not restricted to) :

%    Geotail
%    IMP8
%    Wind
%    Geosynchronous Investigations
%    Ground-Based Investigations 
%Mission_group --- required
missionGroup = 'Geosynchronous Investigations';
infoCDF.Mission_group = missionGroup;

%This attribute is an NSSDC standard global attribute which is used to 
%denote the history of modifications made to the CDF data set. The MODS 
%attribute should contain a description of all significant changes to the 
%data set. This attribute is not directly tied to Data_version, but each 
%version produced will contain the relevant modifications. This attribute 
%can have as many entries as necessary to contain the desired information.
%MODS --- recommended
mods = '';
infoCDF.MODS = mods;

%This attribute lists the parent CDF(S) for files of derived and merged data 
%sets. Subsequent entry values are used for multiple parents. The syntax 
%for a CDF parent would be e.g. "CDF>logical_file_id".
%Parents --- optional
parents = '';
infoCDF.Parents = parents;

%This attribute value should include a recognizable abbreviation.
%PI_affiliation --- required
PIAffiliation = 'United States Air Force Academy';
infoCDF.PI_affiliation = PIAffiliation;

%This attribute value should include first initial and last name.
%PI_name --- required
PIName = 'M.G. McHarg';
infoCDF.PI_name = PIName;

%This attribute identifies the name of the project and indicates ownership. 
%For ISTP missions and investigations, the value used is "ISTP>International 
%Solar-Terrestrial Physics". For the Cluster mission, the value is "STSP 
%Cluster>Solar Terrestrial Science Programmes, Cluster". Other acceptable 
%values are "IACG>Inter-Agency Consultative Group", "CDAWxx>Coordinated 
%Data Analysis Workshop xx", and "SPDS>Space Physics Data System". Others 
%may be defined in future. This attribute can be multi-valued if the data 
%has been supplied to more than one project.
%Project --- required
project = 'SPDS';
infoCDF.Project = project;

%Text containing information on, {\it e.g.} citability and PI access 
%restrictions. This may point to a World Wide Web page specifying the 
%rules of use.
%Rules_of_use --- recommended
rulesOfUse = '';
infoCDF.Rules_of_use = rulesOfUse;

%This is a text attribute containing the skeleton file version number. This 
%is a required attribute for Cluster, but for IACG purposes it exists if 
%experimenters want to track it.
%Skeleton_version --- optional
skeletonVersion = '';
infoCDF.Skeleton_version = skeletonVersion;

%This is a required attribute for Cluster, but for IACG purposes it exists 
%if experimenters want to track it.
%Software_version --- optional
softwareVersion = '';
infoCDF.Software_version = softwareVersion;

%This attribute identifies the mission or investigation that contains the 
%sensors. For ISTP, this is the mission name for spacecraft missions or 
%the investigation name for ground-based or theory investigations. Both a 
%long name and a short name are provided. This attribute should be single 
%valued. Examples:

%    "GEOTAIL>Geomagnetic Tail"
%    "WIND>Wind Interplanetary Plasma Laboratory"
%    "DARN>Dual Auroral Radar Network"
%    "GOES_7>Geostationary Operational Environmental Satellite 7"
%    "IMP-8>Interplanetary Monitoring Platform"
%    "LANL1989_046>Los Alamos National Laboratory 1989"
%    "C1>Cluster Satellite No 1". 
%Source_name --- required
sourceName = 'STPSat-6>Space Test Program Satellite 6';
infoCDF.Source_name = sourceName;


%Unique dataset identifier assigned by SPASE, of the form 
%spase://<NAMING_AUTHORITY>/<UNIQUE_ID>, where <UNIQUE_ID> is the ID 
%assigned to the SPASE resource record for the dataset in the SPASE system 
%by a SPASE <NAMING_AUTHORITY>. The SPASE resource record provides metadata
%about the dataset, including pointers to locations holding the data.
%spase_DatasetResourceID --- recommended
spaseDatasetResourceID = '';
infoCDF.spase_DatasetResourseID = spaseDatasetResourceID;

%This attribute is an NSSDC standard global attribute which is a text 
%description of the experiment whose data is included in the CDF. A 
%reference to a journal article(s) or to a World Wide Web page describing 
%the experiment is essential, and constitutes the minimum requirement. A 
%written description of the data set is also desirable. This attribute 
%can have as many entries as necessary to contain the desired information.
%TEXT --- required
text = '';
infoCDF.TEXT = text;

%Specifies time resolution of the file, e.g., "3 seconds".
%Time_resolution --- recommended
timeResolution = '15 Seconds';
infoCDF.Time_resolution = timeResolution;

%This attribute is an NSSDC standard global attribute which is a title for 
%the data set, e.g., " Geotail EPIC Key Parameters".
%TITLE --- optional
title = '';
infoCDF.TITLE = title;

%Details to be specified. This attribute is written by software for 
%automatic validation of features such as the structure of the CDF file 
%on a simple pass/fail criterion. The software will test that all expected 
%attributes are present and, where possible, have reasonable values. The 
%syntax is likely to be of the form "test>result>where-done>date". It is 
%not the same as data validation.
%Validate --- optional
validate = '';
infoCDF.validate = validate;

end  %end of the function getCDFGlobalAttributes.m
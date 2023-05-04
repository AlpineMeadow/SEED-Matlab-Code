%% Top-level parameters
TEST = 123456;
INSTRUMENT = 'FalconSEED';
HOST = 'STPSat-6';
EPOCH = '6 Jan 1980 00:00:00';
LAUNCH = '6 Jan 1980 00:00:00';
NUM_MODES = 1;
SECS_PER_DAY = 86400;
TICKSPERSEC = 1;

ERR_LIST={"ERR_DP5_NO_RESPONSE",...
    "ERR_DP5_BAD_RESPONSE",...
    "ERR_DP5_ACK_ERROR",...
    "ERR_DP5_BADLOOKUP",...
    "ERR_DP5_RESPONSE_NOT_CODED",...
    "ERR_DP5_NOINIT",...
    "ERR_DP5_LOCKED",...
    "ERR_DP5_GENERAL",...
    "ERR_CMD_NOT_YET_CODED",...
    "ERR_CMD_RESERVED",...
    "ERR_CMD_BAD_CMD",...
    "ERR_CMD_BAD_ARG",...
    "ERR_CMD_RESERVED5",...
    "ERR_CMD_RESERVED6",...
    "ERR_CMD_UNK_CMD",...
    "ERR_CMD_GENERAL",...
    "ERR_PKT_BAD_SYNC",...
    "ERR_PKT_BAD_CRC",...
    "ERR_PKT_RESERVED3",...
    "ERR_PKT_RESERVED4",...
    "ERR_PKT_RESERVED5",...
    "ERR_PKT_RESERVED6",...
    "ERR_PKT_BADTIME",...
    "ERR_PKT_GENERAL",...
    "ERR_MSC_SPI_ERROR",...
    "ERR_MSC_UART0_ERROR",...
    "ERR_MSC_UART1_ERROR",...
    "ERR_MSC_DOSIMETER",...
    "ERR_MSC_RESERVED5",...
    "ERR_MSC_RESERVED6",...
    "ERR_MSC_NOT_HERE",...
    "ERR_MSC_GENERAL"};

ERR_MSC_SPI_ERROR =0;
ERR_MSC_UART0_ERROR =1;
ERR_MSC_UART1_ERROR =2;
ERR_MSC_DOSIMETER =3;
ERR_MSC_RESERVED5 =4;
ERR_MSC_RESERVED6= 5;
ERR_MSC_NOT_HERE= 6 ;
ERR_MSC_GENERAL =7;

ERR_PKT_BAD_SYNC =8;
ERR_PKT_BAD_CRC =9;
ERR_PKT_RESERVED3 =10;

ERR_PKT_RESERVED4 =11;
ERR_PKT_RESERVED5 =12;
ERR_PKT_RESERVED6 =13;
ERR_PKT_BADTIME =14;
ERR_PKT_GENERAL =15;

ERR_CMD_NOT_YET_CODED =16;
ERR_CMD_RESERVED =17;
ERR_CMD_BAD_CMD =18;
ERR_CMD_BAD_ARG =19;
ERR_CMD_RESERVED5 =20;
ERR_CMD_RESERVED6 =21;
ERR_CMD_UNK_CMD =22;
ERR_CMD_GENERAL =23;

ERR_DP5_NO_RESPONSE =24;
ERR_DP5_BAD_RESPONSE =24;
ERR_DP5_ACK_ERROR =26;
ERR_DP5_BADLOOKUP =27;
ERR_DP5_RESPONSE_NOT_CODED =28;
ERR_DP5_NOINIT =29;
ERR_DP5_LOCKED =30;
ERR_DP5_GENERAL =31;

%% File info
FILE_EXTENSION = '.0';
% FILE_EXTENSION = ''; % for no extension.


%% Types of packet
PACKET_TYPES = ["STATUS"];

%This PACKET_PARAMS variable is the correct variable.  I want to just look at
%spectra.  I will switch this back later.
PACKET_PARAMS = ["DATA_TIME","INST_TIME","DATA_TIMEMS","INST_MODE", ...
    "DOSIMETER","SWEEP_VOLTAGE","SWEEP_DATA","SD_BLOCKNUM", ...
    "TEMPERATURE_HEAD","TEMPERATURE_BRAINS","ERRORS","DP5STATUSBITS","RECDCMDS","SPECTRA","CTR_CMD","CTR_REQ"];
% DSC = Long description of the parameter

% DSC = Long description of the parameter
% POS = First byte of the parameter in the packet, counting from 1
% LEN = How many datapoints for this parameter in the packet (e.g. 100 for
% a 100-step data array
% BPD = How many bytes per datapoint (e.g. 2 for an IMESA ADC)
% These ATTRIB names are immutable, and may be added to in the future
PACKET_PARAM_ATTRIBS = ["DSC","POS","LEN","BPD"];
% For future use
PACKET_PARAM_DATA = ["NAME","DATA"];
%% CRC info
LEN_CRC = 2;
CRC_INIT = strcat('FFFF');
LEN_CRC = 2;
CRC_LEN = 2;
%% Packet sync patterns
% Status packets
DP5SYNC='F5FA';
sync_pattern_dp5 = sscanf(DP5SYNC,'%2x')';

SYNC_DATA1 = '5EED';
FOOT_DATA1 = 'DEE5';
LEN_DATA1 = 4096;

TYPE1_PKT_SYNC = '5EED1000';
TYPE1_PKT_FOOT = 'DEE5'; %No footer for GPIM LR packets.
TYPE1_PKT_LEN = 4096;
TYPE1_PKT_ID = '5E';
TYPE1_PKT_IDLOC = 1;

% Populate any Type 1 packet parameters here
TYPE1_PKT_INST_TIME_DSC = 'Instrument time in seconds since epoch';
TYPE1_PKT_INST_TIME_POS = 5;
TYPE1_PKT_INST_TIME_LEN = 1;
TYPE1_PKT_INST_TIME_BPD = 4;

TYPE1_PKT_DATA_TIME_DSC = 'Instrument time in seconds since epoch';
TYPE1_PKT_DATA_TIME_POS = 5;
TYPE1_PKT_DATA_TIME_LEN = 1;
TYPE1_PKT_DATA_TIME_BPD = 4;

TYPE1_PKT_DOSIMETER_DSC = 'Instrument dosimeter ADC data';
TYPE1_PKT_DOSIMETER_POS = 33;
TYPE1_PKT_DOSIMETER_BPD = 2;
TYPE1_PKT_DOSIMETER_LEN = 4;

TYPE1_PKT_SPECTRA_DSC = 'Instrument spectra';
TYPE1_PKT_SPECTRA_POS = 163;
TYPE1_PKT_SPECTRA_BPD = 3;
TYPE1_PKT_SPECTRA_LEN = 1024;
TYPE1_PKT_SPECTRA_LENDIAN = 1;

TYPE1_PKT_ERRORS_DSC = 'ERRor bit field';
TYPE1_PKT_ERRORS_POS = 4089;
TYPE1_PKT_ERRORS_BPD = 4;
TYPE1_PKT_ERRORS_LEN = 1;

TYPE1_PKT_DP5STATUSBITS_DSC = 'DP5 Status Bits';
TYPE1_PKT_DP5STATUSBITS_POS = 108;
TYPE1_PKT_DP5STATUSBITS_BPD = 2;
TYPE1_PKT_DP5STATUSBITS_LEN = 1;

TYPE1_PKT_DP5PKTSRECD_DSC = 'DP5PKTSRECD';
TYPE1_PKT_DP5PKTSRECD_POS = 108;
TYPE1_PKT_DP5PKTSRECD_BPD = 2;
TYPE1_PKT_DP5PKTSRECD_LEN = 1;

TYPE1_PKT_RECDCMDS_DSC = 'RECDCMDS';
TYPE1_PKT_RECDCMDS_POS = 11;
TYPE1_PKT_RECDCMDS_BPD = 2;
TYPE1_PKT_RECDCMDS_LEN = 1;

TYPE1_PKT_CTR_CMD_DSC = 'CTR_CMD';
TYPE1_PKT_CTR_CMD_POS = 11;
TYPE1_PKT_CTR_CMD_BPD = 2;
TYPE1_PKT_CTR_CMD_LEN = 1;

TYPE1_PKT_CTR_REQ_DSC = 'CTR_REQ';
TYPE1_PKT_CTR_REQ_POS = 9;
TYPE1_PKT_CTR_REQ_BPD = 2;
TYPE1_PKT_CTR_REQ_LEN = 1;

TYPE1_PKT_TEMPERATURE_BRAINS_DSC = 'TEMPERATURE_BRAINS';
TYPE1_PKT_TEMPERATURE_BRAINS_POS = 107;
TYPE1_PKT_TEMPERATURE_BRAINS_BPD = 1;
TYPE1_PKT_TEMPERATURE_BRAINS_LEN = 1;
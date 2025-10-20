function injectionDB = getInjectionDB()

%This function will read in the injection database and place it into a
%structure.  This is called by ReadInjectionDB.m


%Create a variable that holds the injection database filename.
DBFilename = '/SS1/STPSat-6/SEEDDB/SEEDInjectionDB.csv';

%Read in the table.
injectionTable = readtable(DBFilename, 'VariableNamingRule', 'preserve');

%Set out the dates.  These will be of type datetime.
dt = injectionTable{:, 1};
injectionDB.InjectionDates = dt;

injectionDB.year = year(dt);
injectionDB.month = month(dt);
injectionDB.dayOfMonth = day(dt);


%Set out the day of year.  These will be of type double.
injectionDB.injectionDayOfYear = injectionTable{:, 2};

%Set out the Mission day number.  These will be of type double.
injectionDB.injectionMissionDayNumber = injectionTable{:, 3};

%Set out the time at which the injection occured.  These will be of type
%duration.
UTCInjectionTime = injectionTable{:, 4};
UTCInjectionHours = floor(hours(UTCInjectionTime));
UTCInjectionMinutes = fix(60*(hours(UTCInjectionTime) - ...
    floor(hours(UTCInjectionTime))));

injectionDB.UTCInjectionTime = UTCInjectionTime;
injectionDB.UTCInjectionHours = UTCInjectionHours;
injectionDB.UTCInjectionMinutes = UTCInjectionMinutes;

%Convert the UTC hours into local time hours.  The difference between the
%two scales is 6 hours.
LTInjectionHours = fix(UTCInjectionHours) - 6;

%Handle the cases for which LTInjectionHours is less than zero.
LTInjectionHours(LTInjectionHours < 0) = ...
    LTInjectionHours(LTInjectionHours < 0) + 24;

injectionDB.LTInjectionHours = LTInjectionHours;
injectionDB.LTInjectionMinutes = UTCInjectionMinutes;

%Set out the injection type.  These will be of type cell.
injectionDB.injectionType = injectionTable{:, 5};

%Get the comments.  These will be of type cell.
injectionDB.injectionComments = injectionTable{:, 6};


end  %End of the function getIjectionDB.m
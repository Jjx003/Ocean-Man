
% Daniele:

% Purpose: compile all available observations of C-system parameters in the Southern California Bight.
% Deliverable: A matlab (and ASCII) structure containing observations of C-system from the region, with ancillary data, from reliable data sources (NOAA cruises and buoys, CalCOFI cruises, SMBO observation, and other published datasets).
% Details: Fayçal will provide observations. 
% To be included in the database, they need to include:
% At least 1 C-system parameter observation, i.e. pCO2, pH, dissolved inorganic carbon (DIC), alkalinity (Alk)
% Basic physical variables: T, S
% Longitude, Latitude, Time (year, month, day and possibly hour of the day). Time should be processed as a time vector.
% Other variables that, if present, should be included:	
% Nutrients: phosphate (PO4), silicate (SIO2), nitrate (NO3) …
% Chlorophyll or fluorescence
% Oxygen (O2)
% ...
% Information on the data source (cruise, buy, project) should be included in the database, for each observation, as an unique identifier (e.g. a string of characters). The database should be organized as a matlab structure with multiple fields, e.g.:
% database.data_source
% database.lon
% database.lat
% database.time
% database.temperature

% The data could also contain flags for measurements (good, bad, questionable), 
% but if we include only reliable measurements, probably that’s not needed in the 
% first iteration. Also, we should keep track of the data sources (e.g. a small 
% write up on each of the sources, linked to the unique identifier), with info 
% on the error associated to each measurement if present. We may want to add 
% an additional layer to the data_source, for example profile number for in 
% situ profiles, or cruise number for zodiac data – this could be discussed. 
% The purpose would be retrieving individual “meaningful units” from the dataset.

%%% Compiling Buoy Data
%fname = 'mooring_2001_tss.nc';


% DIC, ALKALINITY, pH, pCO2, 
% Po4, SIO2, NO3, Chlorophyll/Fluorescence, Oxygen
% lon, lat, time

%% [Zodiac] (pCO2)
load('Zodiac.mat'); % zodiac

location = 0;

zdate = zodiac.date_num;
zlength = length(zdate);
i = 1:zlength;

date(i) = zdate;
lon(i) = zodiac.lons;
lat(i) = zodiac.lats;
pCO2(i) = zodiac.pCO2_1;
salt(i) = zodiac.salts;
temp(i) = zodiac.temps;
fluor(i) = zodiac.fluorescence;


% we don't have these values 
pH(i) = NaN;
NO3(i) = NaN;
PO4(i) = NaN;
SIO2(i) = NaN;
NH4(i) = NaN;
set(i) = 'SMBO';
% so put em as NaN

location = location + zlength;
%% [SMBO 2003-2008] (pH,NO3,PO4,SIO2,NH4 w/o Calculated values)
load('smbo_data.mat');

sdate = datenum(smbo.date_vector);
slength = length(sdate);
i = (location+1):(location+slength);

date(i) = sdate;
lon(i) = smbo.lon;
lat(i) = smbo.lat;
pCO2(i) = smbo.pco2;
salt(i) = smbo.salt;
temp(i) = smbo.temp;

pH(i) = smbo.pH;
NO3(i) = smbo.no3;
PO4(i) = smbo.po4;
SIO2(i) = smbo.sio2;
NH4(i) = smbo.nh4;
set(i) = 'Zodiac';

%% [...]





%% [Compiling]

% DIC, ALKALINITY, pH, pCO2, 
% Po4, SIO2, NO3, Chlorophyll/Fluorescence, Oxygen
% lon, lat, time

fname = 'Southern California Bight';


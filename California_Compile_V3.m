
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


%% [SETTINGS]
output = 'SCali.nc';

addpath('rectdandco2');
addpath('rectdandco2/CO2');
addpath('rectdandco2/Surf');
addpath('SMBO');

% CO2 Zodiac settings
CO2CompTimeLag = (40) / 3600 ; % 40 seconds delay  
% (supposed to be closeto two minutes)
CO2Folder = '/home/jeffxy/Documents/rectdandco2/CO2/'; % adjust accordingly
CO2Segs = dir([CO2Folder '*.txt']);

RangeFactor = 1.01;

min_lon = -118.430;
max_lon = -118.418;
min_lat = 33.754;
max_lat = 33.766;

% Range of plots:
LatRange = max_lat - min_lat;
LonRange = max_lon - min_lon; 


%% [Zodiac] (pCO2)
load('Zodiac.mat'); % zodiac
% 
location = 0;
% 
zdate = Zodiac.date_num;

% [date_num,dist,speed,lons,lats,depths,temps,salts,cons,fluor] = DirectCompile(fname);

% this is a bit off. ^^ fix this

% zdate = zdate;
% zlon = zodiac.lons;
% zlat = zodiac.lats;
% %zpCO2 = zodiac.pCO2_1;
% zsalt = zodiac.salts;
% ztemp = zodiac.temps;
% zfluor = zodiac.fluorescence;
% pCO2 values from this set seem strange. I'm going to use the data set
% from CO2_... .txt files

flon = []; flat = []; fdate = []; fsalt = []; fc = []; ftemp = []; ffluor = [];

for i = 1:length(CO2Segs) 
    name = CO2Segs(i).name;
   [CO2Segs(i).time,CO2Segs(i).date,CO2Segs(i).CO2] = CO2_Reader2(name,CO2CompTimeLag);
%    [CO2Segs(i).time,CO2Segs(i).CO2] = CO2_Reader2(name,CO2CompTimeLag);
    CO2i = interp1(CO2Segs(i).time/24/3600,CO2Segs(i).CO2,zdate/24/3600);
    Valid = (~isnan(CO2i));   
    flon = [flon, Zodiac.lons(Valid)'];
    flat = [flat, Zodiac.lats(Valid)'];
%     fdate = [fdate, zdate(Valid)'];
    fdate = [fdate, CO2Segs(i).date(Valid)'];
    fsalt = [fsalt, Zodiac.salts(Valid)'];
    fc = [fc, CO2i(Valid)'];
    ftemp = [ftemp, Zodiac.temps(Valid)'];
    ffluor = [ffluor, Zodiac.fluorescence(Valid)'];
end

zlength = length(fdate);
i = 1:zlength;

date(i) = fdate;
lon(i) = flon;
lat(i) = flat;
pCO2(i) = fc;
salt(i) = fsalt;
temp(i) = ftemp;
fluor(i) = ffluor;

%The next implementation assures that the plot axes are of approximately

zlon = []; zlat = []; ztime = []; c = []; zspeed = []; ztemp = [];

% we don't have these values 
pH(i) = NaN;
NO3(i) = NaN;
PO4(i) = NaN;
SIO2(i) = NaN;
NH4(i) = NaN;
% so put em as NaN
set(i) = 1; % set 1 = zodiac 

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
set(i) = 2; % set 2 = SMBO 2003-2008

%% [...]






%% [Compiling]
try
    delete(output)
catch
	delete(output)
end

if ~isempty(which(output))
    delete(output);
end

% DIC, ALKALINITY, pH, pCO2, 
% Po4, SIO2, NO3, Chlorophyll/Fluorescence, Oxygen
% lon, lat, time
vars = {'date','lon','lat','pCO2','salt','temp','pH','NO3','PO4','SIO2','NH4','set'};
for i = 1:length(vars) 
    key = vars{i};
    value = eval([key '(:,:)']);
    [r,c] = size(value);
    nccreate(output,key,'Dimensions',{'rows',r,'coloumns',c},'FillValue',NaN);
    ncwrite(output,key,value);
end
disp('Done!');


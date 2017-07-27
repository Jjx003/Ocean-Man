
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

ctds = {'mooring_2005_ctd.nc' 'mooring_2006_ctd.nc' 'mooring_2007_ctd.nc' 'mooring_2008_ctd.nc'};
tss = {'mooring_2001_tss.nc' 'mooring_2005_ctd.nc' 'mooring_2006_tss.nc' 'mooring_2007_tss.nc' 'mooring_2008_tss.nc'};

% ctd: ctd_press, lon, lat, time, ctd_cond, ctd_sal, trans, fluoro,
%   ctd_temp
% corrected: time, lat, lon, press, temp, cond, salt, trans, fluor

% tss: time, lat, lon, depth, tss_press, tss_temp, tss_cond, tss_sal,
%   tss_depth_ipol, tss_temp_ipol, tss_cond_ipol, tss_salt_ipol
% adcp: lat, lon, depth, time, u_vel, w_vel, err_vel, ehco_int, echo_anom
% metsys: lon, lat, time, air_temp, rel_hum, baro_press, windspd,
%   winddir, windu, windv, buoyhdg, relwinddir

% SMBO_CTD 

ctds_1 = 'mooring_2001_ctd.nc'; % This one is out of the cell cuz its formatted differently from the others 
info = ncinfo(ctds_1);

a = ncread(ctds_1, 'time');
b = ncread(ctds_1, 'lat');
c = ncread(ctds_1, 'lon');
d = squeeze(ncread(ctds_1, 'ctd_press'));
e = squeeze(ncread(ctds_1, 'ctd_temp'));
f = squeeze(ncread(ctds_1, 'ctd_cond'));
g = squeeze(ncread(ctds_1, 'ctd_sal'));
h = squeeze(ncread(ctds_1, 'trans'));
I = squeeze(ncread(ctds_1, 'fluoro'));

cast_name = regexp(ctds_1,'mooring_(\d+)_ctd.nc','tokens');
cast_name = ['mooring',char(cast_name{:})];
SMBO_CTD.(cast_name) = struct('time',a,'lat',b,'lon',c,'press',d,...
    'temp',e,'cond',f,'salt',g,'trans',h,'fluor',I);

%last# corresponds to certain indicies where the last ctd left off
%asd = max(info.Variables(3).Size);

for i = 1:length(ctds)
    file_name = ctds{i};
    a = ncread(file_name, 'time');
    b = ncread(file_name, 'lat');
    c = ncread(file_name, 'lon');
    d = squeeze(ncread(file_name, 'press'));
    e = squeeze(ncread(file_name, 'temp'));
    f = squeeze(ncread(file_name, 'cond'));
    g = squeeze(ncread(file_name, 'salt'));
    h = squeeze(ncread(file_name, 'trans'));
    I = squeeze(ncread(file_name, 'fluor'));

    cast_name = regexp(file_name,'mooring_(\d+)_ctd.nc','tokens');
    cast_name = ['mooring',char(cast_name{:})];
    SMBO_CTD.(cast_name) = struct('time',a,'lat',b,'lon',c,'press',d,...
    'temp',e,'cond',f,'salt',g,'trans',h,'fluor',I);
end

% ctd: ctd_press, lon, lat, time, ctd_cond, ctd_sal, trans, fluoro,
%   ctd_temp




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

ctd_time_size = max(info.Variables(3).Size);
ctd_lat_size = max(info.Variables(2).Size);
ctd_lon_size = max(info.Variables(1).Size);
ctd_press_size = max(info.Variables(4).Size);
ctd_temp_size = max(info.Variables(5).Size);
ctd_cond_size = max(info.Variables(6).Size);
ctd_salt_size = max(info.Variables(7).Size);
ctd_trans_size = max(info.Variables(8).Size);
ctd_fluor_size = max(info.Variables(9).Size);
 % I just realized that these all should have the same sizes, except for the lons and lats
% I'm keepin things as is anyway, however

for i = 1:length(ctds)
    info = ncinfo(ctds{i});
    ctd_time_size = ctd_time_size + max(info.Variables(1).Size);
    ctd_lat_size = ctd_lat_size + max(info.Variables(2).Size);
    ctd_lon_size = ctd_lon_size + max(info.Variables(3).Size);
    ctd_press_size = ctd_press_size + max(info.Variables(4).Size);
    ctd_temp_size = ctd_temp_size + max(info.Variables(5).Size);
    ctd_cond_size = ctd_cond_size + max(info.Variables(6).Size);
    ctd_salt_size = ctd_salt_size + max(info.Variables(7).Size);
    ctd_trans_size = ctd_trans_size + max(info.Variables(8).Size);
    ctd_fluor_size = ctd_fluor_size + max(info.Variables(9).Size);
end

ctd_cast_size = ctd_fluor_size;

ctd_time = zeros(1,ctd_time_size);
ctd_lat = zeros(1,ctd_lat_size);
ctd_lon = zeros(1,ctd_lon_size);
ctd_press = zeros(1,ctd_press_size);
ctd_temp = zeros(1,ctd_temp_size);
ctd_cond = zeros(1,ctd_cond_size);
ctd_salt = zeros(1,ctd_salt_size);
ctd_trans = zeros(1,ctd_trans_size);
ctd_fluor = zeros(1,ctd_fluor_size);
ctd_cast = cell(1,ctd_cast_size);

last1 = 0;last2 = 0;last3 = 0;last4 = 0;last5 = 0;last6 = 0;last7 = 0;last8 = 0;last9 = 0;

a = ncread(ctds_1, 'time');
last1 = length(a);
ctd_time(1:last1) = a;

b = ncread(ctds_1, 'lat');
last2 = length(b);
ctd_lat(1:last2) = b;

c = ncread(ctds_1, 'lon');
last3 = length(c);
ctd_lon(1:last3) = c;

d = squeeze(ncread(ctds_1, 'ctd_press'));
last4 = length(d);
ctd_press(1:last4) = d;

e = squeeze(ncread(ctds_1, 'ctd_temp'));
last5 = length(e);
ctd_temp(1:last5) = e;

f = squeeze(ncread(ctds_1, 'ctd_cond'));
last6 = length(f);
ctd_cond(1:last6) = f;

g = squeeze(ncread(ctds_1, 'ctd_sal'));
last7 = length(g);
ctd_salt(1:last7) = g;

h = squeeze(ncread(ctds_1, 'trans'));
last8 = length(h);
ctd_trans(1:last8) = h;

I = squeeze(ncread(ctds_1, 'fluoro'));
last9 = length(I);
ctd_fluor(1:last9) = I;

ctd_cast(1:last9) = {'mooring2001'};


%last# corresponds to certain indicies where the last ctd left off
%asd = max(info.Variables(3).Size);

for i = 1:length(ctds)
    file_name = ctds{i};
    % slowly insert them in..
    
    a = ncread(file_name, 'time');
    newl = last1 + length(a);
    ctd_time(last1+1:newl) = a;
    last1 = newl;

    b = ncread(file_name, 'lat');
    newl2 = last2 + length(b);
    ctd_lat(last2+1:newl2) = b;
    last2 = newl2;
    
    c = ncread(file_name, 'lon');
    newl3 = last3 + length(c);
    ctd_lon(last3+1:newl3) = c;
    last3 = newl3;

    d = squeeze(ncread(file_name, 'press'));
    newl4 = last4 + length(d);
    ctd_press(last4+1:newl4) = d;
    last4 = newl4;
    
    e = squeeze(ncread(file_name, 'temp'));
    newl5 = last5 + length(e);
    ctd_temp(last5+1:newl5) = e;
    last5 = newl5;

    f = squeeze(ncread(file_name, 'cond'));
    newl6 = last6 + length(f);
    ctd_cond(last6+1:newl6) = f;
    last6 = newl6;
    
    g = squeeze(ncread(file_name, 'salt'));
    newl7 = last7 + length(g);
    ctd_salt(last7+1:newl7) = g;
    last7 = newl7;
    
    h = squeeze(ncread(file_name, 'trans'));
    newl8 = last8 + length(h);
    ctd_trans(last8+1:newl8) = h;
    last8 = newl8;
    
    I = squeeze(ncread(file_name, 'fluor'));
    newl9 = last9 + length(I);
    ctd_fluor(last9+1:newl9) = I;
    
    
    j = regexp(file_name,'mooring_(\d+)_ctd.nc','tokens');
    j = ['mooring',char(j{:})];
    ctd_cast(last9+1:newl9) = {j};
    last9 = newl9;
end

ctd_cast = char(ctd_cast);


% ctd: ctd_press, lon, lat, time, ctd_cond, ctd_sal, trans, fluoro,
%   ctd_temp

SMBO_CTD = struct('cast',ctd_cast,'time',ctd_time,'lon',ctd_lon,'lat',ctd_lat,'press',ctd_press,...
'temp',ctd_temp,'cond',ctd_cond,'salt',ctd_salt,'trans',ctd_trans,...
'fluor',ctd_fluor);



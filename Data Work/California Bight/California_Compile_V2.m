
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

%% SMBO_CTD 
ctds = {'mooring_2005_ctd.nc' 'mooring_2006_ctd.nc' 'mooring_2007_ctd.nc' 'mooring_2008_ctd.nc'};
%tss = {'mooring_2001_tss.nc' 'mooring_2006_tss.nc' 'mooring_2007_tss.nc' 'mooring_2008_tss.nc'};

% ctd: ctd_press, lon, lat, time, ctd_cond, ctd_sal, trans, fluoro,
%   ctd_temp
% corrected: time, lat, lon, press, temp, cond, salt, trans, fluor

% tss: time, lat, lon, depth, tss_press, tss_temp, tss_cond, tss_sal,
%   tss_depth_ipol, tss_temp_ipol, tss_cond_ipol, tss_sal_ipol

% adcp: lat, lon, depth, time, u_vel, w_vel, err_vel, ehco_int, echo_anom
% metsys: lon, lat, time, air_temp, rel_hum, baro_press, windspd,
%   winddir, windu, windv, buoyhdg, relwinddir



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
SMBO_CTDS.(cast_name) = struct('time',a,'lat',b,'lon',c,'press',d,...
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
    SMBO_CTDS.(cast_name) = struct('time',a,'lat',b,'lon',c,'press',d,...
    'temp',e,'cond',f,'salt',g,'trans',h,'fluor',I);

    names = fieldnames(SMBO_CTDS.(cast_name));
    for i2 = 1:length(names)
        n = char(names{i2});
        val = SMBO_CTDS.(cast_name).(n);
        siz = length(val);
        nccreate([cast_name,'.nc'],n,'Dimensions',{n,siz},'FillValue',NaN);
        ncwrite([cast_name,'.nc'],n,val);
    end
end
%% CO2 Data 
%%% =======================================================================
    %Aggregate	ddata for pCO2, CTD, and Metsys, allow 10 min [600s] of...
    %   time difference for closest values for CTD, and Metsys to match...
    %   CO2 data
    
    %1: Time [s], Start 1.1.2001, PST									
    %2: water xCO2 [ppm]=[uatm], wet values									
    %3: air xCO2 [ppm]=[uatm], wet values									
    %4: delta pCO2=(air xCO2 - water xCO2) [ppm	]=[uatm]								
    %5: Oxygen saturation [%]									
    %6: SST [deg C] from surface CTD									
    %7: Salinity from surface CTD									
    %8: Pressure [dbar] from surface CTD									
    %9: Transmissivity [V]									
    %10: Fluorescence [V]									
    %11: Air temperature [deg C]									
    %12: Barometric pressure [dbar]									
    %13: Windspeed [m/s]									
    %14: Winddirection [grad]									
    %15: Windspeed u-component [m/s]									
    %16: Windspeed v-component [m/s]									
%%% =======================================================================
CO2 = load('CO2_all_0810_2002_600.dat');
bad_data_value = -99.99990;
 
%%% Pull out time (in seconds since 01-01-2001) vector
time_in_s = CO2(:,1);
time_datenum = datenum('01 Jan 2001') + time_in_s/(60*60*24);
water = CO2(:,2);
water(water==bad_data_value) = NaN;
air = CO2(:,3);
air(air==bad_data_value) = NaN;
dpCO2 = CO2(:,4);
dpCO2(dpCO2==bad_data_value) = NaN;
omega_oxygen = CO2(:,5);
omega_oxygen(omega_oxygen==bad_data_value) = NaN;
sst = CO2(:,6);
sst(sst==bad_data_value) = NaN;
salt = CO2(:,7);
salt(salt==bad_data_value) = NaN;
press = CO2(:,8);
press(press==bad_data_value) = NaN;
trans = CO2(:,9);
trans(trans==bad_data_value) = NaN;
fluor = CO2(:,10);
fluor(fluor==bad_data_value) = NaN;
air_temp = CO2(:,11);
air_temp(air_temp==bad_data_value) = NaN;
bpress = CO2(:,12);
bpress(bpress==bad_data_value) = NaN;
wind_speed = CO2(:,13);
wind_speed(wind_speed==bad_data_value) = NaN;
wind_direction = CO2(:,14);
wind_direction(wind_direction==bad_data_value) = NaN;
windu = CO2(:,15);
windu(windu==bad_data_value) = NaN;
windv = CO2(:,16);
windv(windv==bad_data_value) = NaN;

SMBO_CO2_2002 = struct('time',time_datenum,'water',water,'air',air,...
'dpCO2',dpCO2,'omega_oxygen',omega_oxygen,'sst',sst,'salt',salt,'press',...
press,'trans',trans,'fluor',fluor,'air_temp',air_temp,'bpress',bpress,...
'wind_speed',wind_speed,'wind_direction',wind_direction,'windu',windu,...
'windv',windv);

names = fieldnames(SMBO_CO2_2002);
for i2 = 1:length(names)
    n = char(names{i2});
    val = SMBO_CO2_2002.(n);
    siz = length(val);
    nccreate('SMBO_CO2_2002.nc',n,'Dimensions',{n,siz},'FillValue',NaN);
    ncwrite('SMBO_CO2_2002.nc',n,val);
end

% nccreate('test.nc','time','Dimensions',{'time',1531},'FillValue',NaN);
% ncwrite('test.nc','time',time_datenum);
% nccreate('test.nc','water','Dimensions',{'water', 1531},'FillValue',NaN);
% ncwrite('test.nc','water',water);
% nccreate('test.nc','air','Dimensions',{'air', 1531},'FillValue',NaN);
% ncwrite('test.nc','air',air);
% nccreate('test.nc','dpCO2','Dimensions',{'dpCO2', 1531},'FillValue',NaN);
% ncwrite('test.nc','dpCO2',dpCO2);
% nccreate('test.nc','omega_oxygen','Dimensions',{'omega_oxygen', 1531},'FillValue',NaN);
% ncwrite('test.nc','omega_oxygen',omega_oxygen);
% nccreate('test.nc','sst','Dimensions',{'sst', 1531},'FillValue',NaN);
% ncwrite('test.nc','sst',sst);
% nccreate('test.nc','salt','Dimensions',{'salt', 1531},'FillValue',NaN);
% ncwrite('test.nc','salt',salt);
% nccreate('test.nc','press','Dimensions',{'press', 1531},'FillValue',NaN);
% ncwrite('test.nc','press',press);
% nccreate('test.nc','trans','Dimensions',{'trans', 1531},'FillValue',NaN);
% ncwrite('test.nc','trans',trans);
% nccreate('test.nc','fluor','Dimensions',{'fluor', 1531},'FillValue',NaN);
% ncwrite('test.nc','fluor',fluor);
% nccreate('test.nc','air_temp','Dimensions',{'air_temp', 1531},'FillValue',NaN);
% ncwrite('test.nc','air_temp',air_temp);
% nccreate('test.nc','bpress','Dimensions',{'bpress', 1531},'FillValue',NaN);
% ncwrite('test.nc','bpress',bpress);
% nccreate('test.nc','wind_speed','Dimensions',{'wind_speed', 1531},'FillValue',NaN);
% ncwrite('test.nc','wind_speed',wind_speed);
% nccreate('test.nc','wind_direction','Dimensions',{'wind_direction', 1531},'FillValue',NaN);
% ncwrite('test.nc','wind_direction',wind_direction);
% nccreate('test.nc','windu','Dimensions',{'windu', 1531},'FillValue',NaN);
% ncwrite('test.nc','windu',windu);
% nccreate('test.nc','windv','Dimensions',{'windv', 1531},'FillValue',NaN);
% ncwrite('test.nc','windv',windv);

%% 



%%% 
%%% loadSMBOdata.m
%%%
%%% Reads SMBO data from tab-formatted file and makes it readily usable via Matlab.
%%%

%%% Data size
Ncols = 34;
Nrows = 1694;

%%% Open data file for reading
fid = fopen('SMBO_data_2003_2008.txt','r');

%%% Load data
alldata = zeros(Nrows,Ncols);
for i=1:Nrows
  
  %%% Create a datenum to represent the date and time
  thedate = fscanf(fid,'%s ',1);
  thetime = fscanf(fid,'%s ',1);
  alldata(i,1) = datenum(thedate);  
  
  %%% The rest of the data are just numerical
  alldata(i,2:Ncols) = fscanf(fid,'%lf',[1 Ncols-1]);
  
end

%%% Close the input file - no longer needed
fclose(fid);

%%% Save all data to a .mat file
save SMBO_alldata_2003_2008.mat





%%% Separate data into named variables
datetime = alldata(:,1);
days_year = alldata(:,2);
days_running = alldata(:,3);
station = alldata(:,4);
latitude = alldata(:,5);
longitude = alldata(:,6);
depth = alldata(:,7);
temperature = alldata(:,8);
salinity = alldata(:,9);
DIC = alldata(:,10);
alkalinity = alldata(:,11);
NO3 = alldata(:,12);
PO4 = alldata(:,13);
SIL = alldata(:,14);
NO2 = alldata(:,15);
NH4 = alldata(:,16);
Nstar = alldata(:,17);
Fe_total = alldata(:,18);
Mn_total = alldata(:,19);
Dsi = alldata(:,20);
Bsi = alldata(:,21);
Lsi = alldata(:,22);
chl_a = alldata(:,23);
phae = alldata(:,24);
pH = alldata(:,25);
pCO2 = alldata(:,26);
Omega_calc = alldata(:,27);
Omega_aragonite = alldata(:,28);
Secci_disc = alldata(:,29);
flag_depth = alldata(:,30);
flag_temperature = alldata(:,31);
flag_salinity = alldata(:,32);
flag_DIC = alldata(:,33);
flag_alkalinity = alldata(:,34);

%%% Save all data to a .mat file
save SMBO_named_2003_2008.mat datetime days_year days_running station latitude ...
  longitude depth temperature salinity DIC alkalinity NO3 PO4 SIL NO2 ...
  NH4 Nstar Fe_total Mn_total Dsi Bsi Lsi chl_a phae pH pCO2 Omega_calc ...
  Omega_aragonite Secci_disc flag_depth flag_temperature flag_salinity ...
  flag_DIC flag_alkalinity;





%%% Create a hydrocast object for each station
Nstations = max(station);
for n=1:Nstations
  
  %%% Construct the object itself
  newcast = hydrocast;  
  
  %%% List of array indices for which the station number is equal to n
  indices = find(station==n);
  
  %%% Properties that do not vary with depth
  newcast.station = station(indices(1));  
  newcast.datetime = datetime(indices(1));
  newcast.days_year = days_year(indices(1));
  newcast.days_running = days_running(indices(1));    
  newcast.latitude = latitude(indices(1));
  newcast.longitude = longitude(indices(1));

  %%% Properties that vary with depth
  newcast.depth = depth(indices)';
  newcast.temperature = temperature(indices)';
  newcast.salinity = salinity(indices)';
  newcast.DIC = DIC(indices)';
  newcast.alkalinity = alkalinity(indices)';
  newcast.NO3 = NO3(indices)';
  newcast.PO4 = PO4(indices)';
  newcast.SIL = SIL(indices)';
  newcast.NO2 = NO2(indices)';
  newcast.NH4 = NH4(indices)';
  newcast.Nstar = Nstar(indices)';
  newcast.Fe_total = Fe_total(indices)';
  newcast.Mn_total = Mn_total(indices)';
  newcast.Dsi = Dsi(indices)';
  newcast.Bsi = Bsi(indices)';
  newcast.Lsi = Lsi(indices)';
  newcast.chl_a = chl_a(indices)';
  newcast.phae = phae(indices)';
  newcast.pH = pH(indices)';
  newcast.pCO2 = pCO2(indices)';
  newcast.Omega_calc = Omega_calc(indices)';
  newcast.Omega_aragonite = Omega_aragonite(indices)';
  newcast.Secci_disc = Secci_disc(indices)';
  newcast.flag_depth = flag_depth(indices)';
  newcast.flag_temperature = flag_temperature(indices)';
  newcast.flag_salinity = flag_salinity(indices)';
  newcast.flag_DIC = flag_DIC(indices)';
  newcast.flag_alkalinity = flag_alkalinity(indices)';   
  
  %%% Add the cast object to the list
  allcasts(n) = newcast;
  
end

%%% Save cast data to a .mat file
save SMBO_casts_2003_2008.mat allcasts







%%% Interpolate vertically to create uniform grids
maxdepth = max(depth);
depth_grid = 1:3:maxdepth;
station_grid = zeros(Nstations,1);
datetime_grid = zeros(Nstations,1);
days_grid = zeros(Nstations,1);
Ndepths = length(depth_grid);
temperature_gridded = zeros(Nstations,Ndepths);
salinity_gridded = zeros(Nstations,Ndepths);
DIC_gridded = zeros(Nstations,Ndepths);
alkalinity_gridded = zeros(Nstations,Ndepths);
NO3_gridded = zeros(Nstations,Ndepths);
PO4_gridded = zeros(Nstations,Ndepths);
SIL_gridded = zeros(Nstations,Ndepths);
NO2_gridded = zeros(Nstations,Ndepths);
NH4_gridded = zeros(Nstations,Ndepths);
Nstar_gridded = zeros(Nstations,Ndepths);
Fe_total_gridded = zeros(Nstations,Ndepths);
Mn_total_gridded = zeros(Nstations,Ndepths);
Dsi_gridded = zeros(Nstations,Ndepths);
Bsi_gridded = zeros(Nstations,Ndepths);
Lsi_gridded = zeros(Nstations,Ndepths);
chl_a_gridded = zeros(Nstations,Ndepths);
phae_gridded = zeros(Nstations,Ndepths);
pH_gridded = zeros(Nstations,Ndepths);
pCO2_gridded = zeros(Nstations,Ndepths);
Omega_calc_gridded = zeros(Nstations,Ndepths);
Omega_aragonite_gridded = zeros(Nstations,Ndepths);
Secci_disc_gridded = zeros(Nstations,Ndepths);
for n=1:Nstations
  for k=1:Ndepths

    %%% Extract properties that are unique to each station
    station_grid(n) = allcasts(n).station;
    datetime_grid(n) = allcasts(n).datetime;
    days_grid(n) = allcasts(n).days_running;
    
    %%% Check depths increase monotonically
    depth_I = allcasts(n).depth;
    for j=2:length(depth_I)
      if (depth_I(j) == depth_I(j-1))
        depth_I(j) = depth_I(j) + 0.01;
      end
    end
        
    %%% Interpolate to make grids of properties that vary with depth
    temperature_gridded(n,:) = interp1nan(depth_I,allcasts(n).temperature,depth_grid);    
    salinity_gridded(n,:) = interp1nan(depth_I,allcasts(n).salinity,depth_grid);
    DIC_gridded(n,:) = interp1nan(depth_I,allcasts(n).DIC,depth_grid);
    alkalinity_gridded(n,:) = interp1nan(depth_I,allcasts(n).alkalinity,depth_grid);
    NO3_gridded(n,:) = interp1nan(depth_I,allcasts(n).NO3,depth_grid);
    PO4_gridded(n,:) = interp1nan(depth_I,allcasts(n).PO4,depth_grid);
    SIL_gridded(n,:) = interp1nan(depth_I,allcasts(n).SIL,depth_grid);
    NO2_gridded(n,:) = interp1nan(depth_I,allcasts(n).NO2,depth_grid);
    NH4_gridded(n,:) = interp1nan(depth_I,allcasts(n).NH4,depth_grid);
    Nstar_gridded(n,:) = interp1nan(depth_I,allcasts(n).Nstar,depth_grid);
    Fe_total_gridded(n,:) = interp1nan(depth_I,allcasts(n).Fe_total,depth_grid);
    Mn_total_gridded(n,:) = interp1nan(depth_I,allcasts(n).Mn_total,depth_grid);
    Dsi_gridded(n,:) = interp1nan(depth_I,allcasts(n).Dsi,depth_grid);
    Bsi_gridded(n,:) = interp1nan(depth_I,allcasts(n).Bsi,depth_grid);
    Lsi_gridded(n,:) = interp1nan(depth_I,allcasts(n).Lsi,depth_grid);
    chl_a_gridded(n,:) = interp1nan(depth_I,allcasts(n).chl_a,depth_grid);
    phae_gridded(n,:) = interp1nan(depth_I,allcasts(n).phae,depth_grid);
    pH_gridded(n,:) = interp1nan(depth_I,allcasts(n).pH,depth_grid);
    pCO2_gridded(n,:) = interp1nan(depth_I,allcasts(n).pCO2,depth_grid);
    Omega_calc_gridded(n,:) = interp1nan(depth_I,allcasts(n).Omega_calc,depth_grid);
    Omega_aragonite_gridded(n,:) = interp1nan(depth_I,allcasts(n).Omega_aragonite,depth_grid);
    Secci_disc_gridded(n,:) = interp1nan(depth_I,allcasts(n).Secci_disc,depth_grid);
    
  end
end

%%% Save gridded data to file
save SMBO_gridded_2003_2008.mat depth_grid station_grid datetime_grid days_grid ... 
  temperature_gridded salinity_gridded DIC_gridded alkalinity_gridded ...
  NO3_gridded PO4_gridded SIL_gridded NO2_gridded NH4_gridded ...
  Nstar_gridded Fe_total_gridded Mn_total_gridded Dsi_gridded ...
  Bsi_gridded Lsi_gridded chl_a_gridded phae_gridded pH_gridded ...
  pCO2_gridded Omega_calc_gridded Omega_aragonite_gridded Secci_disc_gridded;

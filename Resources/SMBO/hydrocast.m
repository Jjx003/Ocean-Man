classdef hydrocast
  %HYDROCAST Stores all the data collected from the bottles on a single hydrographic cast.
   
  properties
    
    %%% Properties that do not vary with depth
    station;
    datetime;
    days_year;
    days_running;    
    latitude;
    longitude;
    
    %%% Properties that vary with depth
    depth;
    temperature;
    salinity;
    DIC;
    alkalinity;
    NO3;
    PO4;
    SIL;
    NO2;
    NH4;
    Nstar;
    Fe_total;
    Mn_total;
    Dsi;
    Bsi;
    Lsi;
    chl_a;
    phae;
    pH;
    pCO2;
    Omega_calc;
    Omega_aragonite;
    Secci_disc;
    flag_depth;
    flag_temperature;
    flag_salinity;
    flag_DIC;
    flag_alkalinity;
    
  end
  
  methods
  end
  
end


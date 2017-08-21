% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       USAGE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function will combine pCO2 measurements 
% ("CO2_... .txt") with "surface" measurements 
% ("KDS_... .txt") into a structure format
% 
% * Please be aware that there are notable issues with 
% the accuracy of the pCO2 sensor in terms of its 
% calibration and time delay. Adjust this function as
% needed
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     ARGUMENTS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     [surf] - (string)  
%         The target folder location of "surface 
%         measurements" that provide longitude, latitude,
%         and other parameters
%         
%     [co2] - (string)
%         The target folder location of pCO2 measurements
%         from the pCO2 Oceanus Pro Instrument
%         
%     [co2delay] - (number)
%         The delay in seconds of the pCO2 values versus 
%         actual time. Estimates range from 120-130 secs.
%         
%     [strain_window] - (optional boolean/logical)
%         Set to true (or 1) to toggle restraining the 
%         output to only certain domain of coordinates.
%         Leave blank for default false value
%         
%     [min_coordinate] - (optional array 1x2)
%         The array should contain the minimum coordinate,
%         that determines the bottom left corner of the 
%         window ~ [min_lon,min_lat]
%         
%     [max_coordinate] - (optional array 1x2)
%         The array should contain the maximum coordinate,
%         that determines the top right corner of the 
%         window ~ [max_lon,max_lat]
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       OUTPUT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The output file contains a structure that combines 
% the two sets (surface and co2).
% 
% The structure's properties include:
%     [lon] - longitudes
%     [lat] - latitudes
%     [time] - time relative to day, not actual time
%     [speed] - speed of the boat (calculated)
%     [CO2] - pCO2 value measured 
%     [temp] - temperature
%     [salt] - salinity
%     [cons] - ??
%     [fluor] - fluorescence
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       EXAMPLE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surf = '/home/jeffxy/Documents/rectdandco2/Surf/';
% co2 = '/home/jeffxy/Documents/rectdandco2/CO2/';
% 
% min = [130, -97];
% max = [140, -93];
% 
% output_structure = CO2Surf(surf,co2,130,true,min,max);
% % >output should give structure within window w/130 
% % seconds co2 delay
% 
% ** For thorough example, look at CoordinateStall.m
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Structure = CO2Surf(surf,co2,co2delay, varargin)
    %=====================
    %===== SETTINGS ======

    if isempty(surf)
        SurfFolder = '/home/jeffxy/Documents/rectdandco2/Surf/';
    else
        SurfFolder = surf;
    end

    if isempty(co2)
        CO2Folder = '/home/jeffxy/Documents/rectdandco2/CO2/';
    else
        CO2Folder = co2;
    end

    Segs = dir([SurfFolder '*.txt']);
    CO2Segs = dir([CO2Folder '*.txt']);

    assert(~isempty(Segs),'Surface folder appears invalid');
    assert(~isempty(CO2Segs),'CO2 folder appears invalid');

    if isempty(co2delay)
        CO2CompTimeLag = 40/3600; %#hours the computer is behind local time
    else
        CO2CompTimeLag = co2delay;
    end

    RangeFactor = 1.5;% 1.5;%1; %Factor for extended range (beyond measurements) of lat and lon in plots

    
    strain_window = false;
	min_lon = 0;
    max_lon = 0;
    min_lat = 0;
    max_lat = 0;  
    
    if ~isempty(varargin)
        len = length(varargin);
        assert(len==1, 'Fourth argument should be followed by either two arguments for min and max coordinates (1x2 arrays)');
        assert(isa(varargin{1},'logical'),'Fourth argument should be a logical');
        
        strain_window = varargin{1};
        bottom = varargin{2};
        top = varargin{3};  
  
        min_lon = bottom(1);
        min_lat = bottom(2);
        max_lon = top(1);
        max_lat = top(2);    

    end
    %=====================
    %=====================
    
    

    time = []; speed = []; lon = []; lat = []; temp = []; salt = []; 
    cons = []; fluor = [];

    for i = 1:length(Segs)
        name = Segs(i).name;
        % [date_num,dist,speed,lons,lats,depths,temps,salts,cons,fluor]
        [Segs(i).time,~,Segs(i).speed,Segs(i).lon,Segs(i).lat,~,...
            Segs(i).temp,Segs(i).salt,Segs(i).cons,Segs(i).fluor] = ...
            DirectCompile(name);
        
        time = [time;Segs(i).time];
        speed = [speed;Segs(i).speed];
        lon = [lon;Segs(i).lon];
        lat = [lat;Segs(i).lat];
        temp = [temp;Segs(i).temp]; %#ok<*AGROW>
        salt = [salt;Segs(i).temp];
        cons = [cons;Segs(i).cons];
        fluor = [fluor;Segs(i).fluor];
    end


    if strain_window
        % Range of plots:
        LatRange = max_lat - min_lat;
        LonRange = max_lon - min_lon; 

        %The next implementation assures that the plot axes are of approximately
        %the same cartesian distance, to minimize distortion.
        if LonRange <= LatRange/cos(mean(lat)*pi/180)
            LonRange = LatRange/cos(mean(lat)*pi/180);
        else 
            LatRange = LonRange*cos(mean(lat)*pi/180);
        end

        Nlim = (max_lat + min_lat)/2 + LatRange*RangeFactor/2;%North limit for plotting
        Slim = (max_lat + min_lat)/2 - LatRange*RangeFactor/2;%South limit for plotting
        Elim = (max_lon + min_lon)/2 + LonRange*RangeFactor/2;%East limit for plotting
        Wlim = (max_lon + min_lon)/2 - LonRange*RangeFactor/2;%West limit for plotting
    end

    zlon = []; zlat = []; ztime = []; c = []; zspeed = []; ztemp = [];
    zsalt = []; zcons = []; zfluor = [];

    for i = 1:length(CO2Segs) 
        name = CO2Segs(i).name;
        [CO2Segs(i).time,CO2Segs(i).CO2] = CO2_Reader(name,CO2CompTimeLag);
        CO2i = interp1(CO2Segs(i).time/24/3600,CO2Segs(i).CO2,time);
        if strain_window
            Valid = (~isnan(CO2i)) & (lon>=Wlim & lon<=Elim) & (lat>=Slim & lat<=Nlim);
        else
            Valid = (~isnan(CO2i));
        end

        zspeed = [zspeed, speed(Valid)'];
        zlon = [zlon, lon(Valid)'];
        zlat = [zlat, lat(Valid)'];
        ztime = [ztime, time(Valid)'];
        c = [c, CO2i(Valid)'];
        ztemp = [ztemp, temp(Valid)'];
        zsalt = [zsalt, salt(Valid)'];
        zcons = [zcons, cons(Valid)'];
        zfluor = [zfluor, fluor(Valid)'];
    end
    
    Structure = struct('lon',zlon,'lat',zlat,'time',ztime,'speed',zspeed,'CO2',c,'temp',ztemp,'salt',zsalt,'cons',zcons,'fluor',zfluor);
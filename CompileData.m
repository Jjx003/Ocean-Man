function zodiac = CompileData(dataz, save_to_file, output_name)

    %%% [USAGE]: To Convert Raw Zodiac data into a structure format 
    %%%
    %%% [ARGUMENTS]: 
    %%%     dataz           - The loaded text file of the data (dataz =
    %%%                       load("filename"))
    %%%
    %%%     save_to_file    - Boolean to determine if you want to make 
    %%%                       output file
    %%%
    %%%     output_name     - The string name of the output file.
    %%%                       Don't leave this blank, even when not saving
    %%%
    %%% [OUTPUT] 
    %%%     zodiac - The structure of the compiled data
    %%%         Contains:
    %%%             datenum (date_num)
    %%%             distance (dist)
    %%%             speed (speed)
    %%%             longitude (lons)
    %%%             latitude (lats)
    %%%             pCO2 one (pCO2_1) (this one seems to work best)
    %%%             pCO2 two (pCO2_2)
    %%%             temperature (temps)
    %%%             depth (depths)
    %%%             cons? (cons) (not too sure what this is)
    %%%             fluorescence (flour)
    

    % here we are preallocating some data 
    [x, ~] = size(dataz);
    date_num = zeros(x,1);
    dist = zeros(x,1);
    % dist2 = zeros(x,1);
    speed = zeros(x,1);
    
    % extracting specific sets of data from coloumns
    lons = dataz(:,4);
    lats = dataz(:,5);
    pCO2_1 = dataz(:,6);
    pCO2_2 = dataz(:,7);
    depths = dataz(:,8); % not sure if this is actual depth
    temps = dataz(:,9);
    salts = dataz(:,10);
    cons = dataz(:,11); % not too sure what this is 
    flour = dataz(:,12);
    
    % messy datenum converter 
    % could be made more efficient ?
    for i = 1:x
        mydate2 = num2str(dataz(i,2));
        d = str2num(mydate2(1:2)); 
        mth = str2num(mydate2(3:4)); 
        y = str2num(mydate2(5:6))+2000;
        mydate3 = num2str(dataz(i,3));
        h = str2num(mydate3(1:2)); 
        m = str2num(mydate3(3:4)); 
        s = str2num(mydate3(5:6));
        date_num(i) = datenum(y,mth,d,h,m,s);
    end
    
    % distance code from getsstA_V3a.m by Jeroen Molemaker/ Aviv S.
    len = x;
    lonsr = lons * pi/180; % degrees to radians
    latsr = lats * pi/180;
    
    dx = cos(latsr(2:len)) .* (lonsr(2:len) - lonsr(1:len-1));  
    dy = latsr(2:len)-latsr(1:len-1);
    ds = 6.371E3 * sqrt(dx.^2 + dy.^2);  % in km
    dt = (date_num(2:len) - date_num(1:len-1)) * 3600 * 24;

    dist(1:len) = 0.00; % preallocate some more 
    % dist2(1:len) = 0.00;
    
    for i = 1:len-1 % iterating through each of the distances and ds
        current_distance = dist(i);
        delta_distance = ds(i);
        delta_time = dt(i);
        dist(i+1) = current_distance + delta_distance; % distance in km, adding up
        % dist2(i+1) = dist2(i) + distance(lats(i),lons(i),lats(i+1),lons(i+1)) * pi/180 * 6.371E3;
        % manual distance calculation is faster
        if delta_distance == 0 || delta_time == 0 
            speed(i+1) = 0; % we don't want any NaNs
        else
            speed(i+1) = delta_distance*1000/delta_time; % speed in m/s
        end
    end

    zodiac = struct('date_num',date_num,'lons',lons,'lats', ...
    lats,'pCO2_1',pCO2_1,'pCO2_2',pCO2_2,'temps',temps,'salts',salts,...
    'depths',depths,'cons',cons,'fluorescence',flour,'dist',dist,'speed',speed);

    if save_to_file 
        save([output_name '.mat'], 'zodiac');
        save([output_name 'Named.mat'], 'date_num', 'lons', 'lats', 'pCO2_1', 'pCO2_2', 'temps', 'salts', 'depths', 'cons', 'flour', 'dist', 'speed');
    end


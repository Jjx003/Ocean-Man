function [date_num,dist,speed,lons,lats,depths,temps,salts,cons,fluor] = DirectCompile(fname)
    
    dataz = importdata(fname,',');
    
    UTC2local = -7.0; %UTC to local time conversion [hr]
    
    % here we are preallocating some data 
    [x, ~] = size(dataz);
    date_num = zeros(x,1);
    dist = zeros(x,1);
    speed = zeros(x,1);
    
    % extracting specific sets of data from coloumns
    lons = dataz(:,4);
    lats = dataz(:,5);
    depths = dataz(:,8); % not sure if this is actual depth
    temps = dataz(:,9);
    salts = dataz(:,10);
    cons = dataz(:,11); % not too sure what this is 
    fluor = dataz(:,12);
    
    % messy datenum converter 
    % could be made more efficient ?
    for i = 1:x
        mydate2 = num2str(dataz(i,2));
        d = str2num(mydate2(1:2)); 
        mth = str2num(mydate2(3:4)); 
        y = str2num(mydate2(5:6))+2000;
        mydate3 = num2str(dataz(i,3));
        h = str2num(mydate3(1:2))+UTC2local; % this part taken from aviv's coden
        m = str2num(mydate3(3:4)); 
        s = str2num(mydate3(5:6));
        date_num(i) = datenum(0,0,0,h,m,s); % time is in h/m/s, not by actual date
    end
    
    % distance code from getsstA_V3a.m by Jeroen Molemaker/ Aviv S.
    len = x;
    lonsr = lons * pi/180; % degrees to radians
    latsr = lats * pi/180;
    
    dx = cos(latsr(2:len)) .* (lonsr(2:len) - lonsr(1:len-1));  
    dy = latsr(2:len)-latsr(1:len-1);
    ds = 6.371E3 * sqrt(dx.^2 + dy.^2);  % in km
    dt = (date_num(2:len) - date_num(1:len-1)) * 3600 * 24;

    dist(1:len) = 0.000; % preallocate some more 
    % dist2(1:len) = 0.00;
    
    for i = 1:len-1 % iterating through each of the distances and ds
        current_distance = dist(i);
        delta_distance = ds(i);
        delta_time = dt(i);
        dist(i+1) = current_distance + delta_distance; % distance in km, adding up
        if delta_distance == 0 || delta_time == 0 
            speed(i+1) = 0; % we don't want any NaNs
        else
            speed(i+1) = delta_distance*1000/delta_time; % speed in m/s
        end
    end



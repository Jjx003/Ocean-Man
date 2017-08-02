addpath rectdandco2
addpath rectdandco2/Surf
addpath rectdandco2/CO2

SurfFolder = '/home/jeffxy/Documents/rectdandco2/Surf/';
CO2Folder = '/home/jeffxy/Documents/rectdandco2/CO2/';
Segs = dir([SurfFolder '*.txt']);
CO2Segs = dir([CO2Folder '*.txt']);

CO2CompTimeLag = 0; %#hours the computer is behind local time.
TimeDiffTresh = 5; %[sec] max time difference between gps time and co2 time. If the minimal time difference is larger than the treshold, the co2 data point is dicarded
RangeFactor = 1.5;%1.5;%1; %Factor for extended range (beyond measurements) of lat and lon in plots

CO2_Min = 265; %nan;
CO2_Max = 315;%nan;

min_lon = -118.430;
max_lon = -118.418;
min_lat = 33.754;
max_lat = 33.766;

time = []; speed = []; lon = []; lat = []; temp = [];

for i = 1:length(Segs)
    name = Segs(i).name;
    % [date_num,dist,speed,lons,lats,depths,temps,salts,cons,fluor]
    [Segs(i).time,~,Segs(i).speed,Segs(i).lon,Segs(i).lat,~,Segs(i).temp,~,~,~] = DirectCompile(name);
    time = [time;Segs(i).time];
    speed = [speed;Segs(i).speed];
    lon = [lon;Segs(i).lon];
    lat = [lat;Segs(i).lat];
    temp = [temp;Segs(i).temp]; %#ok<*AGROW>
end

% Range of plots:
LatRange = max_lat - min_lat;
LonRange = max_lon - min_lon; 

%The next implementation assures that the plot axes are of approximately
%the same cartesian distance, to minimize distortion.
if LonRange <= LatRange/cos(mean(lat)*pi/180)
    LonRange = LatRange/cos(mean(lat)*pi/180);
else 
    LatRange = LonRange*cos(nanmean(lat)*pi/180);
end

Nlim = (max_lat + min_lat)/2 + LatRange*RangeFactor/2;%North limit for plotting
Slim = (max_lat + min_lat)/2 - LatRange*RangeFactor/2;%South limit for plotting
Elim = (max_lon + min_lon)/2 + LonRange*RangeFactor/2;%East limit for plotting
Wlim = (max_lon + min_lon)/2 - LonRange*RangeFactor/2;%West limit for plotting

clon = []; clat = []; ctime = []; c = []; cspeed = [];

for i = 1:length(CO2Segs) 
    name = CO2Segs(i).name;
    [CO2Segs(i).time,CO2Segs(i).CO2] = CO2_Reader(name,CO2CompTimeLag);
    CO2i = interp1(CO2Segs(i).time/24/3600,CO2Segs(i).CO2,time);
    Valid = (~isnan(CO2i)) & (lon>=Wlim & lon<=Elim) & (lat>=Slim & lat<=Nlim);
    
    CO2Segs(i).clon = lon(Valid);
    CO2Segs(i).clat = lat(Valid);
    CO2Segs(i).CO2i = CO2i(Valid);
    CO2Segs(i).itime = time(Valid);
    CO2Segs(i).speed = speed(Valid);
    %-------------------------------
    cspeed = speed(Valid);
    clon = [clon, lon(Valid)'];
    clat = [clat, lat(Valid)'];
    ctime = [ctime, (CO2Segs(i).itime)'];
    c = [c, (CO2Segs(i).CO2i)'];
end

if isnan(CO2_Min)
    CO2_Min = min(c);
end
if isnan(CO2_Max) 
    CO2_Max = max(c);
end

% Smooth out the calculated speeds
% Including this seems to make the results look a lot better
nv = size(cspeed,1);
wsiz = 3;
sh = (wsiz-1)/2;
cspeed0 = cspeed;

for i=wsiz:nv-wsiz
    cspeed(i) = nanmean(cspeed(i-sh:i+sh));
end
cspeed(cspeed==0) = nan;

% Smooth out the calculated co2 values
windowSize = 5; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
c = filter(b,a,c);






% Now we will try and find indexes at which the boat was moving slowly
Stalls = DetermineStall(cspeed,3,20);


% Lets plot all the stallin points 
figure
for i = 1:length(Stalls) 
    index = Stalls{i};
    %plot(c(index));
    %plot(clon(index),clat(index));
    clons = clon(index);
    clats = clat(index);
    cs = c(index);
    
    mesh([clons(:) clons(:)], [clats(:) clats(:)], [cs(:) cs(:)], ...
     'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
    hold on
end
caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid on;
hold off;


% Same graph, different colors
figure
plot(clon,clat,'k','LineWidth',1.5); % for the original route in black
hold on
for i = 1:length(Stalls) 
    index = Stalls{i};
    %plot(c(index));
    plot(clon(index),clat(index),'LineWidth',3); % the stalling routes will vary in color
    hold on
end
caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid on;
hold off


for i = 1:length(Stalls) 
    index = Stalls{i};
    plot(c(index));
end



% This is a set of x-points that I believed showed an exponential
% relationship with its corresponding CO2 values - let's plot them!
list = {
    20:70
    60:200
    200:900
    1100:1120
    1230:1400
    1400:1500
    1525:1750
    1780:1920
    2060:2375
    2380:2470
    2680:6000
    6400:6800
    7200:7640
};

for i = 1:length(list)
    figure
    indice = list{i};
    assignin('base',['data' int2str(i)],c(indice));
    plot(c(indice))
end

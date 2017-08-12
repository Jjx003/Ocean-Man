
%=====================
%===== SETTINGS ======
addpath ezyfit
addpath rectdandco2
addpath rectdandco2/Surf
addpath rectdandco2/CO2

SurfFolder = '/home/jeffxy/Documents/rectdandco2/Surf/';
CO2Folder = '/home/jeffxy/Documents/rectdandco2/CO2/';
Segs = dir([SurfFolder '*.txt']);
CO2Segs = dir([CO2Folder '*.txt']);

CO2CompTimeLag = 40/3600; %#hours the computer is behind local time.
TimeDiffTresh = 5; %[sec] max time difference between gps time and co2 time. If the minimal time difference is larger than the treshold, the co2 data point is dicarded
RangeFactor = 1.5;%1.5;%1; %Factor for extended range (beyond measurements) of lat and lon in plots

CO2_Min = 265; %nan;
CO2_Max = 315;%nan;

min_lon = -118.430;
max_lon = -118.418;
min_lat = 33.754;
max_lat = 33.766;

coordinates = [
    33.762902, -118.423319;
    33.760601, -118.421461;
    33.758322, -118.419645;
    33.7560950, -118.4177390;
    33.761688, -118.42448;
    33.759372, -118.422666;
    33.75707, -118.42085;
    33.754762, -118.419041;
];
%=====================
%=====================

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

zlon = []; zlat = []; ztime = []; c = []; zspeed = []; ztemp = [];

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
    zspeed = [zspeed, speed(Valid)'];
    zlon = [zlon, lon(Valid)'];
    zlat = [zlat, lat(Valid)'];
    ztime = [ztime, (CO2Segs(i).itime)'];
    c = [c, (CO2Segs(i).CO2i)'];
    ztemp = [ztemp, temp(Valid)'];
end

if isnan(CO2_Min)
    CO2_Min = min(c);
end
if isnan(CO2_Max) 
    CO2_Max = max(c);
end

markers = {};

for i = 1:length(coordinates)
    mymarker = marker;
    mymarker.latitude = coordinates(i,1);
    mymarker.longitude = coordinates(i,2);
    mymarker.radius = .1; % in km -> * 1000 m / km
    markers{i} = mymarker;
end

in = DetermineStall3(zlon, zlat, zspeed, ztime, c, ztemp, markers);

% windowSize = 3; 
% b = (1/windowSize)*ones(1,windowSize);
% a = 1;
% filtered_co2 = filter(b,a,co2);
%     
% windowSize = 3; 
% b = (1/windowSize)*ones(1,windowSize);
% a = 1;
% filtered_speed = filter(b,a,speed);

for i = 1:length(in)
    set = in{i};
    flons = set(:,1);
    flats = set(:,2);
    fspeed = set(:,3);
    ftimes = set(:,4);
    co2 = set(:,5);
    ftemp = set(:,6);
    
    mint = min(ftimes);
    bad = (ftimes-mint) >= 2000/(3600*24); % this sets it ~2000 seconds allowed
    flons(bad) = [];
    flats(bad) = [];
    fspeed(bad) = [];
    ftemp(bad) = [];
    co2(bad) = [];
    
    scale = 1:length(fspeed);

    % normalizing the three of these 
    co2 = (co2-mean(co2))/std(co2);
    fspeed = (fspeed-mean(fspeed))/std(fspeed);
    ftemp = (ftemp-mean(ftemp))/std(ftemp);

    figure
    hold on
    plot(scale,co2);
    plot(scale,fspeed);
    plot(scale,ftemp);
    legend('pCO2','Speed','Temperature');
    title(['Coordinate# ' int2str(i)]);
    hold off
    
end




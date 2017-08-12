% The rate is dependent on temperature
% and salinity, and to a much lesser degree, pressure.
% The membrane effect can be described using the Laws of Diffusion, whereby the
% diffusion coefficient of the semi-permeable membrane is a function of the gas solubility
% coefficient in the membrane, and the permeability of that gas through the membrane.
% The thickness of the membrane also plays a crucial role in the time for equilibration.
% Temperature and salinity can dramatically affect the diffusion through a membrane.

% In all cases, warmer temperatures improve the
% response time of the instruments, while cooler waters 


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

% windowSize = 3; 
% b = (1/windowSize)*ones(1,windowSize);
% a = 1;
% zspeed = filter(b,a,speed);



% Smooth out the calculated speeds
% Including this seems to make the results look a lot better
% nv = size(zspeed,1);
% wsiz = 3;
% sh = round((wsiz-1)/2);
% cspeed0 = zspeed;
% 
% for i=wsiz:nv-wsiz
%     zspeed(i) = nanmean(zspeed(i-sh:i+sh));
% end
% zspeed(zspeed==0) = nan;

%Smooth out the calculated co2 values (very noisy)
% windowSize = 5; 
% b = (1/windowSize)*ones(1,windowSize);
% a = 1;
% c = filter(b,a,c);


% Now we will try and find indexes at which the boat was moving slowly
% Stalls = DetermineStall(zspeed,8,40);


% Lets plot all the stallin points 
% figure
% for i = 1:length(Stalls) 
%     index = Stalls{i};
%     %plot(c(index));
%     %plot(clon(index),clat(index));
%     clons = zlon(index);
%     clats = zlat(index);
%     cs = c(index);
%     
%     mesh([clons(:) clons(:)], [clats(:) clats(:)], [cs(:) cs(:)], ...
%      'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
%     hold on
% end
% caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid on;
% hold off;


% Same graph, different colors
% figure
% plot(zlon,zlat,'k','LineWidth',1.5); % for the original route in black
% hold on
% for i = 1:length(Stalls) 
%     index = Stalls{i};
%     %plot(c(index));
%     plot(zlon(index),zlat(index),'LineWidth',3); % the stalling routes will vary in color
%     hold on
% end
% caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid on;
% hold off
% 

% figure
% mesh([zlon(:) zlon(:)], [zlat(:) zlat(:)], [c(:) c(:)], ...
% 'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
% caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid on;


% This is a set of x-points that I believed showed an exponential
% relationship with its corresponding CO2 values - let's plot them!
% list = {
%     20:70
%     60:200
%     200:900
%     1100:1120
%     1230:1400
%     1400:1500
%     1525:1750
%     1780:1920
%     2060:2375
%     2380:2470
%     2680:6000
%     6400:6800
%     7200:7640
% };
% 
% for i = 1:length(list)
%     figure
%     indice = list{i};
%     %assignin('base',['data' int2str(i)],c(indice));
%     plot(c(indice))
%     srange = [int2str(indice(1)),'...',int2str(indice(length(indice)))];
%     title(srange);
%     xlabel('index position');
%     ylabel('pCO2');
%     grid on
% end


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

markers = {};

for i = 1:length(coordinates)
    mymarker = marker;
    mymarker.latitude = coordinates(i,1);
    mymarker.longitude = coordinates(i,2);
    mymarker.radius = .1; % in km -> * 1000 m / km
    markers{i} = mymarker;
end

in = DetermineStalls3(zlon, zlat, zspeed, ztime, c, markers);
figure
for i = 1:length(in)
    figure
    set = in{i};
    flons = set(:,1);
    flats = set(:,2);
    fspeed = set(:,3);
    ftimes = set(:,4);
    co2 = set(:,5);
    mint = min(ftimes);
    bad = (ftimes-mint) >= 2000/(3600*24); % this sets it ~2000 seconds allowed
    flons(bad) = [];
    flats(bad) = [];
    co2(bad) = [];
    fspeed(bad) = [];
    plot(co2)
    hold on
end

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
    mint = min(ftimes);
    bad = (ftimes-mint) >= 2000/(3600*24); % this sets it ~2000 seconds allowed
    flons(bad) = [];
    flats(bad) = [];
    fspeed(bad) = [];
    co2(bad) = [];
    
    scale = 1:length(fspeed);
    
    hold on;
    yyaxis left;
    plot(scale,co2);
    axes = gca; axes.YLabel.String = 'pCO2';
    yyaxis right;
    plot(scale,fspeed);
    axes2 = gca; axes2.YLabel.String = 'Speed (m/s)';
    
    xlabel('Relative index');
    title(['Coordinate# ' int2str(i)]);
    
    hold off;
    

     
end




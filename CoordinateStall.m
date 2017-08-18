% 
% %=====================
% %===== SETTINGS ======
% addpath ezyfit
% addpath rectdandco2
% addpath rectdandco2/Surf
% addpath rectdandco2/CO2
% 
% SurfFolder = '/home/jeffxy/Documents/rectdandco2/Surf/';
% CO2Folder = '/home/jeffxy/Documents/rectdandco2/CO2/';
% Segs = dir([SurfFolder '*.txt']);
% CO2Segs = dir([CO2Folder '*.txt']);
% 
% CO2CompTimeLag = 40/3600; %#hours the computer is behind local time.
% TimeDiffTresh = 5; %[sec] max time difference between gps time and co2 time. If the minimal time difference is larger than the treshold, the co2 data point is dicarded
% RangeFactor = 1.5;%1.5;%1; %Factor for extended range (beyond measurements) of lat and lon in plots
% 
% CO2_Min = 265; %nan;
% CO2_Max = 315;%nan;
% 
% Consecutive_T = 20; % The threshhold for the minimum amount of times data set of temperature differs by one
% 
% min_lon = -118.430;
% max_lon = -118.418;
% min_lat = 33.754;
% max_lat = 33.766;
% 
% coordinates = [
%     33.762902, -118.423319;
%     33.760601, -118.421461;
%     33.758322, -118.419645;
%     33.7560950, -118.4177390;
%     %33.761688, -118.42448; %Coordinate 5, but has no good correlations
%     33.759372, -118.422666; 
%     33.75707, -118.42085;
%     33.754762, -118.419041;
% ];
% 
% %=====================
% %=====================
% 
% time = []; speed = []; lon = []; lat = []; temp = [];
% 
% for i = 1:length(Segs)
%     name = Segs(i).name;
%     % [date_num,dist,speed,lons,lats,depths,temps,salts,cons,fluor]
%     [Segs(i).time,~,Segs(i).speed,Segs(i).lon,Segs(i).lat,~,Segs(i).temp,~,~,~] = DirectCompile(name);
%     time = [time;Segs(i).time];
%     speed = [speed;Segs(i).speed];
%     lon = [lon;Segs(i).lon];
%     lat = [lat;Segs(i).lat];
%     temp = [temp;Segs(i).temp]; %#ok<*AGROW>
% end
% 
% % Range of plots:
% LatRange = max_lat - min_lat;
% LonRange = max_lon - min_lon; 
% 
% %The next implementation assures that the plot axes are of approximately
% %the same cartesian distance, to minimize distortion.
% if LonRange <= LatRange/cos(mean(lat)*pi/180)
%     LonRange = LatRange/cos(mean(lat)*pi/180);
% else 
%     LatRange = LonRange*cos(nanmean(lat)*pi/180);
% end
% 
% Nlim = (max_lat + min_lat)/2 + LatRange*RangeFactor/2;%North limit for plotting
% Slim = (max_lat + min_lat)/2 - LatRange*RangeFactor/2;%South limit for plotting
% Elim = (max_lon + min_lon)/2 + LonRange*RangeFactor/2;%East limit for plotting
% Wlim = (max_lon + min_lon)/2 - LonRange*RangeFactor/2;%West limit for plotting
% 
% zlon = []; zlat = []; ztime = []; c = []; zspeed = []; ztemp = [];
% 
% for i = 1:length(CO2Segs) 
%     name = CO2Segs(i).name;
%     [CO2Segs(i).time,CO2Segs(i).CO2] = CO2_Reader(name,CO2CompTimeLag);
%     CO2i = interp1(CO2Segs(i).time/24/3600,CO2Segs(i).CO2,time);
%     Valid = (~isnan(CO2i)) & (lon>=Wlim & lon<=Elim) & (lat>=Slim & lat<=Nlim) & ~(isnan(temp));
%     
%     CO2Segs(i).clon = lon(Valid);
%     CO2Segs(i).clat = lat(Valid);
%     CO2Segs(i).CO2i = CO2i(Valid);
%     CO2Segs(i).itime = time(Valid);
%     CO2Segs(i).speed = speed(Valid);
%     %-------------------------------
%     zspeed = [zspeed, speed(Valid)'];
%     zlon = [zlon, lon(Valid)'];
%     zlat = [zlat, lat(Valid)'];
%     ztime = [ztime, (CO2Segs(i).itime)'];
%     c = [c, (CO2Segs(i).CO2i)'];
%     ztemp = [ztemp, temp(Valid)'];
% end
% 
% if isnan(CO2_Min)
%     CO2_Min = min(c);
% end
% if isnan(CO2_Max) 
%     CO2_Max = max(c);
% end

%CO2Surf(surf,co2,co2delay)

% Default params. already set 
zodiac = CO2Surf([],[],[]);
zlon = zodiac.lon;
zlat = zodiac.lat;
zspeed = zodiac.speed;
ztime = zodiac.time;
ztemp = zodiac.temp;
c = zodiac.CO2;

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

in = DetermineStall3(zlon, zlat, zspeed, ztime, c, ztemp, markers);

for i = 1:length(in)
    set = in{i};
    flons = set(:,1);
    flats = set(:,2);
    fspeed = set(:,3);
    ftimes = set(:,4);
    co2 = set(:,5);
    ftemp = set(:,6);
    
    len = 1:length(co2);
    epsilon = ((len(end)-len(1))/(numel(len)-1))^3/16;
    pvalue = 1/(1+epsilon*3*10^5);

	[smooth,p] = csaps(len,co2, pvalue, len);
    co2 = smooth.'; 

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

for i = 1:length(in)
    set = in{i};
    flons = set(:,1);
    flats = set(:,2);
    fspeed = set(:,3);
    ftimes = set(:,4);
    co2 = set(:,5);
    ftemp = set(:,6);

    len = 1:length(co2);
    epsilon = ((len(end)-len(1))/(numel(len)-1))^3/16;
    pvalue = 1/(1+epsilon*3*10^5);

	[smooth,p] = csaps(len,co2, pvalue, len);
    sco2 = smooth.'; 

    scale = 1:length(fspeed);
    length(scale)
    length(co2)

    sco2 = (sco2-mean(sco2))/std(sco2);
    co2 = (co2-mean(co2))/std(co2);
    fspeed = (fspeed-mean(fspeed))/std(fspeed);
    ftemp = (ftemp-mean(ftemp))/std(ftemp);
    
    figure
    hold on
    plot(scale,sco2);
    plot(scale,fspeed);
    plot(scale,ftemp);
    plot(scale,co2,'.');
    legend('smoothed pCO2','Speed','Temperature','actual pCO2');
    title(['Coordinate# ' int2str(i)]);

end

% for i = 1:length(in)
%     set = in{i};
%     flons = set(:,1);
%     flats = set(:,2);
%     fspeed = set(:,3);
%     ftimes = set(:,4);
%     co2 = set(:,5);
%     ftemp = set(:,6);
% 
%     len = 1:length(co2);
%     epsilon = ((len(end)-len(1))/(numel(len)-1))^3/16;
%     pvalue = 1/(1+epsilon*2*10^5);
% 
% 	[sp,ys,rho] = spaps(len,co2,10,ones(length(co2),1)*.8);
%     sco2 = smooth.'; 
% 
%     constant = abs(diff(ftemp)) == 0;
%     flons = flons(constant);
%     flats = flats(constant);
%     fspeed = fspeed(constant);
%     ftimes = ftimes(constant);
%     sco2 = sco2(constant);
%     co2 = co2(constant);
%     ftemp = ftemp(constant);
%     ftemp(1) = ftemp(end);
% 
%     scale = 1:length(fspeed);
% 
%     sco2 = (sco2-mean(sco2))/std(sco2);
%     co2 = (co2-mean(co2))/std(co2);
%     fspeed = (fspeed-mean(fspeed))/std(fspeed);
%     ftemp = (ftemp-mean(ftemp))/std(ftemp);
% 
%     figure
%     hold on
%     plot(scale,sco2);
%     plot(scale,fspeed);
%     plot(scale,ftemp);
%     plot(scale,co2,'.');
%     legend('smoothed pCO2','Speed','Temperature','actual pCO2');
%     title(['Coordinate# ' int2str(i)]);
%     hold off
% end



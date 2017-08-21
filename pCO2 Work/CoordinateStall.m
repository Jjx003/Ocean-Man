% CO2Surf(surf_folder,co2_folder,co2delay_seconds)


zodiac = CO2Surf([],[],[]); % modify "CO2Surf.m" as needed. leaving blank will be default parameters
zlon = zodiac.lon;
zlat = zodiac.lat;
zspeed = zodiac.speed;
ztime = zodiac.time;
ztemp = zodiac.temp;
c = zodiac.CO2;

coordinates = [ % our various points of interest
    33.762902, -118.423319;
    33.760601, -118.421461;
    33.758322, -118.419645;
    33.7560950, -118.4177390;
    33.761688, -118.42448; 
    33.759372, -118.422666; 
    33.75707, -118.42085;
    33.754762, -118.419041;
];


%create markers
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

    [smooth,p] = csaps(len,co2, pvalue, len); % this is a filtering/smoothing function
    sco2 = smooth.'; 

    scale = 1:length(fspeed);


    % here, we are normalizing the values so they are easier to compare
    sco2 = (sco2-nanmean(sco2))/nanstd(sco2);
    co2 = (co2-nanmean(co2))/nanstd(co2);
    fspeed = (fspeed-nanmean(fspeed))/nanstd(fspeed);
    ftemp = (ftemp-nanmean(ftemp))/nanstd(ftemp);
    
    figure
    hold on
    plot(scale,sco2);
    plot(scale,fspeed);
    plot(scale,ftemp);
    plot(scale,co2,'.');
    legend('smoothed pCO2','Speed','Temperature','actual pCO2');
    title(['Coordinate# ' int2str(i)]);

end

disp('Done!');


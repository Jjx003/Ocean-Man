function Stalls = DetermineStall3(lons, lats, speed, time, co2, temp, markers)

    Stalls = cell(length(markers),1);
    
    count = 0;
    backtrack = 100; 
    
    ratio = pi/180;
    
    lons = lons * ratio;
    lats = lats * ratio;

    for i = 1:length(markers)
        point = markers{i};
        lon1 = point.longitude * ratio;
        lat1 = point.latitude * ratio;
        radius = point.radius;    
        count = count+1;
        started = 0;
        for i2 = 1:length(lons) 
            R = 6371; % radius of earth in km
            lat2 = lats(i2);
            lon2 = lons(i2);
            delta_lat = lat2-lat1;
            delta_lon = lon2-lon1;
            a = sin(delta_lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta_lon/2)^2;
            d = 2 * R * atan2(sqrt(a), sqrt(1-a));
            if d <= radius 
                if ~started && i2 >= backtrack % if I already retrieved my backtrack points
                    started = 1; % debounce
                    for back = 1:backtrack
                        alpha = i2-backtrack+back;
                        Stalls{count} = [Stalls{count};lon2,lat2,speed(alpha),time(alpha),co2(alpha),temp(alpha)];    
                    end 
                else
                    % this retrieves several points before the actual
                    % series
                    Stalls{count} = [Stalls{count};lon2,lat2,speed(i2),time(i2),co2(i2),temp(i2)];
                end 
            end
        end
    end
  
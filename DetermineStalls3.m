function Stalls = DetermineStalls3(lons, lats, speed, time, co2, markers, varargin)

    Stalls = cell(length(markers),1);
    
    count = 0;
    
    backtrack = 100;
    
    ratio = pi/180;
    
    lons = lons * ratio;
    lats = lats * ratio;

    for i = 1:length(markers)
        point = markers{i};
        alon = point.longitude * ratio;
        alat = point.latitude * ratio;
        arad = point.radius;    
        count = count+1;
        started = 0;
        for i2 = 1:length(lons) 
            R = 6371;
            lat1 = alat;
            lat2 = lats(i2);
            long1 = alon;
            long2 = lons(i2);
            delta_lat = lat2-lat1;
            delta_long = long2-long1;
            a = sin(delta_lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta_long/2)^2;
            d = 2 * R * atan2(sqrt(a), sqrt(1-a));
            if d <= arad 
                if ~started && i2 >= backtrack
                    started = 1;
                    for back = 1:backtrack
                        alpha = i2-backtrack+back;
                        Stalls{count} = [Stalls{count};long2,lat2,speed(alpha),time(alpha),co2(alpha)];    
                    end 
                else
                    Stalls{count} = [Stalls{count};long2,lat2,speed(i2),time(i2),co2(i2)];
                end 
            end
        end
    end
  
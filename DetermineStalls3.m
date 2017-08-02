function Stalls = DetermineStalls3(lons, lats, markers, varargin)
    extra = 1.01;
    Stalls = [];
    
    count = 0;
        
    for i = 1:length(markers)
        point = markers{i};
        alon = point.longitude;
        alat = point.latitude;
        arad = point.radius;
        flons = lons;
        flats = lats;
        for i2 = 1:length(flons) 
            R = 6371;
            lat1 = alat;
            lat2 = flats(i2);
            long1 = alon;
            long2 = flons(i2);
            delta_lat = deg2rad(lat2-lat1);
            delta_long = deg2rad(long2-long1);
            lat2 = deg2rad(lat2);
            lat1 = deg2rad(lat1);
            a = sin(delta_lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta_long/2)^2;
            d = 2 * R * atan2(sqrt(a), sqrt(1-a));
            if d <= arad 
                count = count+1;
                Stalls(count,1) = flons(i2);
                Stalls(count,2) = flats(i2);
            end
        end
    end
    
    

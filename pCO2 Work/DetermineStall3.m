% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        USAGE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Determines all data points within radii designated 
%     by "markers" (custom structure)
% 
%     Each marker contains information on its longitude, 
%     latitude, and radius.
% 
%     ~marker.m
%     longitude
%     latitude
%     radius
% 
%     ex: 
%         mymarker = marker;
%         mymarker.longitude = 99;
%         mymarker.latitude = 99;
%         mymarker.radius = 99;
%     -
% 
%     Note that the output return data is limited by 
%     the input arguments.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      ARGUMENTS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [lons, lats, speed, time, pco2, temp] - 
%         Raw provided values from dataset
%         * Should all be the same length *
% 
%     [markers] -
%         A cell containing all the designated markers.
%         * See above example set up *
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       OUTPUT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [Stalls] - 
%         Size: (markers x input_data)
%         Type: Cell
%         Values: lons...temp (subject to change)
% 
%     The output value will be a cell of size 
%     #markers x #input_data (lons..temp)
% 
%     Stalls{1} will correspond to the first marker,
%     and Stalls{n} will designated the nth marker
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       EXAMPLE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Stalls = DetermineStall3(...)
% 
%     set = Stalls{1}; % - The first marker point
%     lons = set(:,1);
%     lats = set(:,2);
%     speed = set(:,3);
%     times = set(:,4);
%     co2 = set(:,5);
%
%     * See CoordinateStall.m for better examples *
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Stalls = DetermineStall3(lons, lats, speed, time, co2, temp, markers)

    assert((length(lons)+length(lats)+length(speed)+length(time)+...
    length(co2)+length(temp))/6 == length(lons),'Size of input arguments (lons-temp) must be the same');

    assert(isa(markers,'cell'),'markers must be in cell format');
    

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
  
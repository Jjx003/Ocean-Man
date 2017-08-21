% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       USAGE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     To determine consecutive points at which the boat
%     is moving slowly or not moving at all.
%     
%     This is important becasue it allows us to assume
%     that the sampled water will have (about) the same
%     pCO2 values at certain time series. Assuming this 
%     allows us to better estimate the measured pCO2 
%     value versus the actual pCO2 value.
%     
%     ...
%     
%     There will be a maximum speed value and 
%     minimum size, where if there are consecutive 
%     points with speed below "max_speed" and 
%     #consecutive points > "min_indicies", it will 
%     insert into the "StalledIndicies" cell.
%     
%     
%     * The intended purpose seemed promising, but 
%     my tests failed to show promising results of 
%     constant pCO2 in sets of slow speed
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       ARGUMENTS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [speeds] - 
%         An array containing the speeds of the boat.
%         This can be calculated through 
%         "DirectCompile.m" or "CompileData.m"
%         
%     [varargin] - 
%         Optional arguments:
%             (1) - max_speed
%                 The max speed the boat can go before
%                 to qualify as a "Stall" point
%             (2) - min_indicies
%                 The minimum size of consecutive points
%                 before it can be considered an actual
%                 set of "stalled indicies"
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        OUTPUT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [StalledIndicies] -     
%         A cell containing the set of indicies that 
%         are found to be "stalls"
%         
%         cell{1} contains the first set (array)
%         of consecutive indexes at which the speeds 
%         stall... cell{n} contains the nth set
%         
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       EXAMPLE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     % returns sets with max 5 speed, min 30 indexes
%     zodiac = CompileData(data, 0, output_name);
%     
%     speeds = zodiac.speed;
%     lons = zodiac.lons;
%     lats = zodiac.lats;
%     
%     Stalled = DetermineStalls(myspeeds, 5, 30);
%     
%     figure
%     hold on;
%     
%     for i = 1:length(Stalled)
%         indicies = Stalled{i};
%         nlons = lons(indicies);
%         nlats = lats(indicies);
%         plot(nlons,nlats);
%     end
%     
%     % This will graph the route of all 
%     % consecutive stall points onto one graph
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
                
    
    
function StalledIndicies = DetermineStall(speeds, varargin)

    
    if ~isempty(varargin) 
        max_speed = varargin{1};
        min_indicies = varargin{2};
    else
        max_speed = 4; % maybe 4is too much...
        min_indicies = 2*65; % ~400 indicies min, where each index is ~ 1 second -> 400 seconds+ 
    end
    
    istall = (speeds < max_speed); % retuns logic table of when these speeds were below the max
    started = inf;
    StalledIndicies = {};
    count = 0;
    continuous = 0; % bool to toggle whether loop is still on a good path 
    
    for i = 1:length(istall)
        bool = istall(i);
        indicies_count = i-started;
        if bool && ~(continuous) 
            % if minimum speed is met and not already in stalled points
            %   then create one 
            started = i; % set started to current i
            continuous = 1; % toggle true
        elseif ~bool &&  indicies_count >= min_indicies && continuous
            % case occurs when the minimum indicies is met by indicies
            %   count and next index of loop is (bool = false), killing
            %   that set of stalled points
            continuous = 0; % 
            count = count + 1;
            StalledIndicies{count} = started:i-1; % started-i-1 are the specific stall indicies 
            % this inserts all the indicies of continuous stalling into the cell
        elseif ~bool && continuous && indicies_count < min_indicies 
            continuous = 0; % kill the continunity
        elseif ~bool 
            continuous = 0;
        end
    end
end

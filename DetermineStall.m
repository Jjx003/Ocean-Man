

% this function returns a cell of indicies where the boat is slowed
%   down at some miniumum speed (varargin(1)) for an extended amount of time
%   (varargin(2))

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

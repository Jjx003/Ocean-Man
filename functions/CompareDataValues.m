%load('/home/jeffxy/Downloads/SMBO/SMBO/SMBO_gridded_2003_2008.mat');
% run hydrocast.m;
% 
% 
% 
% [~, eq, ~] = CompareDataValues(salinity,alkalinity,2,depth,temperature);
% xlabel('Salinity')
% ylabel('Alkalinity');
% title('Salinity v Alkalinity');
% leg = legend('Actual Point',['Best Fit (',eq,')']); 
% leg.Interpreter = 'tex';
% h = colorbar;
% set(get(h,'title'),'string','Temperature (C)');
% 
% hold off;
% 
% % no c,d modifiers to size/color on map
% [~, eq, ~] = CompareDataValues(salinity,alkalinity,2,[],[]);
% xlabel('Salinity')
% ylabel('Alkalinity');
% title('Salinity v Alkalinity');
% leg = legend('Actual Point',['Best Fit (',eq,')']); 
% leg.Interpreter = 'tex';
% 
% hold off;
% 
% 
% 
% % pCO2 v pH
% % find relative sizes from DIC 
% max_DIC = max(DIC);
% [~, ~, ~] = CompareDataValues(pCO2, pH, 2, (max_DIC-DIC+1)*1.2, temperature);
% title('pCO2 v pH');
% xlabel('pCO2');
% ylabel('pH');
% legend('Actual Point', 'Best Fit');
% 
% hold off;
% % pCO2 v PH w/depth and temp
% [~, ~, ~] = CompareDataValues(pCO2, pH, 2, depth, temperature);
% title('pCO2 v pH');
% xlabel('pCO2');
% ylabel('pH');
% legend('Actual Point', 'Best Fit');
% 
% hold off;
% % pCO2 v PH w/depth and temp
% [~, ~, ~] = CompareDataValues(pCO2, DIC, 2, depth, temperature);
% title('pCO2 v DIC');
% xlabel('pCO2');
% ylabel('DICa');
% legend('Actual Point', 'Best Fit');





function [graphic, equation_str, error] = CompareDataValues(a, b, n, c, d)
%%% [USAGE]: To graphically compare data sets "a" and "b"
%%% 
%%% [ARGUMENTS]:
%%%     a - The data being compared on the x-axis (n x 1 array)
%%%     b - The data being compared on the y-axis (n x 1 array)
%%%     n - The order of the fitted polynomial (e.g. n=2 -> ax^2 + bx + c)
%%%     c - The third argument for the scatter function, emphasizing size
%%%         of specific point. Can be left as "[]"
%%%     d - The fourth argument for the scatter function, emphasizing color
%%%         of specific point. Can be left as "[]"
%%%
%%% [OUTPUT]:
%%%     graphic      - The new scatterplot alongside a line of best fit
%%%     equation_str - The written out string of the equation 
%%%     error        - More accurately the r^2 value



    good_indicies = ~(isnan(a) | isnan(b)); % both of these have to be true to create same sized array
    good_a = a(good_indicies);
    good_b = b(good_indicies);

    % Scatter can work with NaN, don't need "good a/b" yet
    figure
    if ~(isempty(c) && isempty(d)) % checking whether user put extra scatter arguments
        graphic = scatter(a, b, c, d); 
    else
        graphic = scatter(a, b);    
    end

    
    % setting up the string formatting of equation to display
    % not exactly efficient though...
    coefficients = polyfit(good_a, good_b, n); % retrieves coefficients of best fitted polynomial
    ystring = 'y = ';
    start = true; % start bool is toggled depending on whether it is the first number or a proceeding number
    
    for i = 1:n+1
        co = coefficients(i);
        if sign(co) == 1
            operator = '+';
        else   
            operator = ''; % negative numbers will have negative symbol alreadu
        end
        if n - i + 1 > 1 % for all values where the degree is > 1
            if start 
                ystring = [ystring,num2str(co),'x^',num2str(n - i + 1)];
                start = false;
            else
               ystring = [ystring,operator,num2str(co),'x^',num2str(n - i + 1)]; 
            end         
        elseif n - i + 1 == 1 % degree of 1
            if start 
                ystring = [ystring,num2str(co),'x'];
                start = false;
            else
                ystring = [ystring,operator,num2str(co),'x'];
            end
        elseif n - i + 1 == 0 % degree 0
            if start
                ystring = [ystring,num2str(co)];
            else
                ystring = [ystring,operator,num2str(co)]; %#ok<*AGROW>
            end
        end
    end
    
    smooth_b = polyval(coefficients, good_a);
    
    hold on % same plot
    scatter(good_a, smooth_b, 'r'); % I tried to use plot, but it gave me some wonky results
    
    % r^2 calculations
    ydif = good_b - smooth_b;
    SSresid = sum(ydif.^2);
    SStotal = (length(good_b)-1) * var(good_b);
    rsq = 1 - SSresid/SStotal;
    annotation('textbox',[.24 .5 .3 .3],'String',['R^2 = ', num2str(rsq)], 'FitBoxToText', 'on');
    
    % our return values (graphic is somewhere)
    equation_str = ystring; 
    error = rsq;
   
    

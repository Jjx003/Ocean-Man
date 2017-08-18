    

function Output = CalculateData(reference_data, data, save_to_file, output_name)
    %%% [USAGE]: Calculates missing data from data_set 
    %%%     Includes: Alkalinity, TCO2 (DIC), Omega Aragonite, pH
    %%%     Also includes flag values: alks_1, alks_2, salts, pCO2_1,
    %%%     pCO2_2
    %%%
    %%% [ARGUMENTS]: 
    %%%     reference_data - The mean value of Phosphate and Silicate are
    %%%                      used from this data (this is assuming it was 
    %%%                      missing from the original)
    %%%
    %%%     data           - The actual data (can be the raw loaded data
    %%%                      or structure data loaded from CompileData.m)
    %%%
    %%%     save_to_file   - Boolean to indicate whether or not to output
    %%%                      the new calculated data into .mat format
    %%%
    %%%     output_name    - The name of output.mat file (required field,
    %%%                      even if save_to_file = false)
    %%%
    %%% [TWEAKABLES]: Variables inside the function that you can tweek to
    %%%               your liking
    %%%               
    %%%               surface_thresh - The maximum depth to average from
    %%%               the reference data
    %%%
    %%%               presin, presout, pHScale, k1k2c, kso4c - Carbon
    %%%               system parameters
    %%%               
    
    if isa(data, 'double')
        data = CompileData(data, save_to_file, output_name);
    end
    
    data_clone = data; % create extra set
    salts = data.salts;
    good = ~(isnan(salts) & isnan(data.pCO2_1)); % we need non-NaN values 
    salts = salts(good);
    
    %%%==========MODIFY==========%%%
    
    surface_thresh = 5; % 5 meters? for surface of reference_data 

    % equations from (Variability and trends of ocean acidification...A time series from Santa Monica Bay)
    % modeled eq.
    data_clone.alks_1 = 119710.92-7050.496*salts+105.789*salts.^2;
    data_clone.alks_2 = 67905.44-3941.614*salts+59.141*salts.^2;

    par1type =   1;    
    par1     = data_clone.alks_1;    
    par2type =   4;    
    par2     =  data.pCO2_1(good);    
    presin   =    0;    % Pressure at input conditions
    presout  =    0;    % Pressure at output conditions
    pHscale  =    2;    % pH scale at which the input pH is reported ("1" means "Total Scale")
    k1k2c    =    14;   % Choice of H2CO3 and HCO3- dissociation constants K1 and K2 ("4" means "Mehrbach refit")
    kso4c    =    1;    % Choice of HSO4- dissociation constants KSO4 ("1" means "Dickson")
    
    %  (*) Each element must be an integer, 
    %      indicating that PAR1 (or PAR2) is of type: 
    %  1 = Total Alkalinity
    %  2 = DIC
    %  3 = pH
    %  4 = pCO2
    %  5 = fCO2
    
    %%%==========================%%%

    template = ones(size(data_clone.alks_1)); 
    
    % calculating a surface average of unknown variables from some sampledata 
    % need these variables in order to use CO2SYS function

    surface_temp_mean = data.temps(good); % temperatures of actual data 

    
    % reference data 
    set = reference_data.depth <= surface_thresh; %
    surface_sil_mean = nanmean(reference_data.SIL((set)))*template;
    surface_PO4_mean = nanmean(reference_data.PO4((set)))*template;


    % PAR1,PAR2,PAR1TYPE,PAR2TYPE,
    % SAL,TEMPIN,TEMPOUT,PRESIN,PRESOUT,SI,PO4,
    % pHSCALEIN,
    % K1K2CONSTANTS,KSO4CONSTANTS

    [DATA,~,~] = CO2SYS(par1,par2,par1type,par2type,...
        salts,surface_temp_mean,NaN,...
        presin,presout,...
        surface_sil_mean,surface_PO4_mean,...
        pHscale,...
        k1k2c,kso4c);

    tco2 = DATA(:,2);
    omega_arag = DATA(:,16);
    ph_total = DATA(:,33);
%   ph_total = DATA(:,34); % add this back if seawater (?)
%   temps = DATA(:,42);
    
    % creating flag values for these variables
    flags.alks_1 = template;
    flags.alks_2 = template;  
    flags.salts = template;
    flags.pCO2_1 = template;
    flags.pCO2_2 = template;
    
    names = fieldnames(flags);
    
    % first create the data structure 
    Output = struct('date_num',data.date_num(good),'lons',data.lons(good),'lats',...
        data.lats(good),'pCO2_1',data.pCO2_1(good),'pCO2_2',data.pCO2_2(good),'temps',...
        data_clone.temps(good),'salts',salts,'alks_1',data_clone.alks_1,'alks_2',data_clone.alks_2,'cons',...
        data.cons(good),'fluorescence',data_clone.fluorescence(good),'dist',data_clone.dist(good),...
        'speed',data_clone.speed(good),'TCO2',tco2,'omega_arag',omega_arag,'pH',ph_total); 
    
    % then add the flags to it
    for i = 1:length(names)
        name = char(names(i));
        actual = data_clone.(name);
        average = nanmean(actual);
        flag = ones(size(actual));
        flags3 = ~( actual > average - 2*std(actual(~isnan(actual))) & actual < average + 2*std(actual(~isnan(actual))) );
        flag(flags3) = 3; % 3 indicates bad value
        Output.([name '_flags']) = flag;
    end
    if save_to_file
        save([output_name '.mat'],'Output');
    end


% below is a graveyard 




% function zodiac2 = CalculateData(reference_data,data)
% 
%     salts = data.salts;
%     good = ~(isnan(salts) & isnan(data.pCO2_1));
%     salts = salts(good);
%     
%     %%%==========MODIFY==========%%%
% 
%     % equations from (Variability and trends of ocean acidification...A time series from Santa Monica Bay)
%     alks_1 = 119710.92-7050.496*salts+105.789*salts.^2;
%     alks_2 = 67905.44-3941.614*salts+59.141*salts.^2;
%     alks_3 = .5 * (alks_1 + alks_2); % alks_3 will be the average of these two 
% 
%     par1type =   1;    
%     par1     = alks_1;    
%     par2type =   4;    
%     par2     =  data.pCO2_1(good);    
%     presin   =    0;    % Pressure    at input conditions
%     presout  =    0;    % Pressure    at output conditions
%     pHscale  =    2;    % pH scale at which the input pH is reported ("1" means "Total Scale")
%     k1k2c    =    14;   % Choice of H2CO3 and HCO3- dissociation constants K1 and K2 ("4" means "Mehrbach refit")
%     kso4c    =    1;    % Choice of HSO4- dissociation constants KSO4 ("1" means "Dickson")
%     
%     %  (*) Each element must be an integer, 
%     %      indicating that PAR1 (or PAR2) is of type: 
%     %  1 = Total Alkalinity
%     %  2 = DIC
%     %  3 = pH
%     %  4 = pCO2
%     %  5 = fCO2
%     %%%==========================%%%
%     
%     
% 
%     template = ones(size(alks_1));
%     
%     
%     % calculating a surface average of unknown variables from some sampledata 
%     % need these variables in order to use CO2SYS function
% 
%     surface_thresh = 5; % 5 meters?
%     surface_temp_mean = data.temps(good);
% 
%     set = reference_data.depth <= surface_thresh; %
%     surface_sil_mean = nanmean(reference_data.SIL((set)))*template;
%     surface_PO4_mean = nanmean(reference_data.PO4((set)))*template;
% 
% 
%     % PAR1,PAR2,PAR1TYPE,PAR2TYPE,
%     % SAL,TEMPIN,TEMPOUT,PRESIN,PRESOUT,SI,PO4,
%     % pHSCALEIN,
%     % K1K2CONSTANTS,KSO4CONSTANTS
% 
%     [DATA,~,~]=CO2SYS(par1,par2,par1type,par2type,...
%         salts,surface_temp_mean,NaN,...
%         presin,presout,...
%         surface_sil_mean,surface_PO4_mean,...
%         pHscale,...
%         k1k2c,kso4c);
% 
%     tco2 = DATA(:,2);
%     omega_arag = DATA(:,16);
%     ph_total = DATA(:,33);
% %   ph_total = DATA(:,34); % add this back if seawater (?)
%     temps = DATA(:,42);
% 
%     pCO2_1_flags = template;
%     pCO2_2_flags = template;
%     temps_flags = template;
%     salts_flags = template;
%     alks_1_flags = template;
%     alks_2_flags = template;
%     alks_3_flags = template;
% 
%     cons_flags = template;
%     fluorescence_flags = template;
%     tco2_flags = template;
%     omega_arag_flags = template;
%     ph_total_flags = template;
%     
%     assignin('base','alks_1',alks_1);
%     assignin('base','alks_2',alks_2);
%     assignin('base','alks_3',alks_3);
%     assignin('base','tco2',tco2);
%     assignin('base','omega_arag',omega_arag);
%     assignin('base','ph_total',ph_total);
%     assignin('base','temps',temps);
%     assignin('base','alks_1_flags',alks_1_flags);
%     assignin('base','alks_2_flags',alks_2_flags);
%     assignin('base','alks_3_flags',alks_3_flags);
%     assignin('base','pCO2_1_flags',pCO2_1_flags);
%     assignin('base','pCO2_2_flags',pCO2_2_flags);
%     assignin('base','temps_flags',temps_flags);
%     assignin('base','salts_flags',salts_flags);
%     assignin('base','cons_flags',cons_flags);
%     assignin('base','fluorescence_flags',fluorescence_flags);
%     assignin('base','tco2_flags',tco2_flags)
%     assignin('base','omega_arag_flags',omega_arag_flags);
%     assignin('base','ph_total_flags',ph_total_flags);
%     
%     variables = who;
%     
%     
% 
%  
% 
%     for i = 1:length(variables) % I'm not entierly sure to why I chose this method
%         var = variables(i);
%         exp = '([\w\d]*)_flags';
%         [tokens, ~] = regexp(var,exp,'tokens','match');
%         tokens = tokens{:};
% 
%         if ~isempty(tokens) 
%             converted_token = char(tokens{1});
%             try % could either be a workspace variable or variable from the set
%                 var2 = evalin('base',converted_token);
%             catch 
%                 var2 = data.(converted_token);
%              
%             end
%             
%             converted_var = char(var);
%             average = mean(var2);
%             flag3 = ~((var2 > average - 2*std(var2)) | (var2 < average + 2*std(var2))); %[-inf bad]..[-2]..[good]..[2]..[inf bad]  
% %             flag3 = flag3(~flag2); % remove the overlapping
% %             
%             get_var = evalin('base',converted_var);
%          
%             get_var(flag3) = 3; % set these bad variables to 3
%             %get_var(flag2) = 2;
%             assignin('base',converted_var,get_var); % set the workspace _flag values to the get_var
%         end
%     end
% 
% 
%     zodiac2 = struct('date_num',data.date_num(good),'lons',data.lons(good),'lats',...
%         data.lats(good),'pCO2_1',data.pCO2_1(good),'pCO2_2',data.pCO2_2(good),'temps',...
%         temps,'salts',salts,'alks_1',alks_1,'alks_2',alks_2,'alks_3',alks_3,'cons',...
%         data.cons(good),'fluorescence',data.fluorescence(good),'dist',data.dist(good),...
%         'TCO2',tco2,'omega_arag',omega_arag,'pH',ph_total, 'pCO2_1_flags',pCO2_1_flags,...
%         'pCO2_2_flags',pCO2_2_flags,'temps_flags',temps_flags,'salts_flags',salts_flags,...
%         'alks_1_flags',alks_1_flags,'alks_2_flags',alks_2_flags,'alks_3_flags',alks_3_flags,...
%         'cons_flags',cons_flags,'fluorescence_flags',fluorescence_flags,'tco2_flags',tco2_flags,...
%         'omega_arag_flags',omega_arag_flags,'ph_total_flags',ph_total_flags); 
% 
%     save zodiac2.mat zodiac2
% 
% 
%     % plot(zodiac2.pH,zodiac2.lats,'.');
%     % figure
%     % plot(smbo.pH,smbo.latitude,'.');
%     % tic
%     % for i = 2:length(smbo.latitude)
%     %     if smbo.latitude(i-1) == smbo.latitude(i) 
%     %         smbo.latitude(i) = smbo.latitude(i) + .1;
%     %     end
%     % end
%     % toc
% 
%     % analyze_correlations(zodiac2);
%     % analyze_correlations(smbo);
%     % 
%     % figure % new figure
%     % ax1 = subplot(2,1,1); % top subplot
%     % ax2 = subplot(2,1,2); % bottom subplot
%     % plot(ax1,smbo.Omega_aragonite,smbo.pH,'.')
%     % plot(ax2,zodiac2.omega_arag,zodiac2.pH,'.');
%     % title(ax1,'/omega Aragonite v pH (SMBO)');
%     % title(ax2,'/omega Aragonite v pH (Zodiac)');
%     % 
%     % figure
%     % plot(zodiac2.pCO2_2, zodiac2.pH,'.');
%     % title('pCO2_2 v pH (Zodiac)');
%     % figure
%     % plot(zodiac2.pCO2_1, zodiac2.pH,'.');
%     % title('pCO2_1 v pH (Zodiac)');
%     % figure
%     % plot(smbo.pCO2,smbo.pH,'.');
%     % title('pCO2 v pH (SMBO)');
% end


    

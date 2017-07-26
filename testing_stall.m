SMBO = load('SMBO_named_2003_2008.mat');
Output = CalculateData(SMBO,[load('KDS_20170524T090147.txt');load('KDS_20170524T103400.txt')],0,'asd');

%Converted = nanmean_smooth(Output,'speed',1);




min_lon = -118.440;
max_lon = -118.410;
min_lat = 33.750;
max_lat = 33.770;



% Play around with 2nd and 3rd arguments 


step = .5*(3600*24)^-1;
good_indicies = find((Output.lons>=min_lon & Output.lons<=max_lon) & (Output.lats>=min_lat & Output.lats<=max_lat));
speed = Output.speed(good_indicies);

r = @(min)1/explike(6,Output.pCO2_1(cell2mat(DetermineStall(speed,1.5,min))));
min_indicies = fminbnd(r,5,400);
disp('done')
Stalls = DetermineStall(Output.speed,1,min_indicies);

pCO2 = Output.pCO2_1;



% Stalls = DetermineStall(Output.speed,1.5,156);
windowSize = 5; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
pCO2 = filter(b,a,pCO2);

for i = 1:length(Stalls)


    figure
    indicies = Stalls{i};
%     if length(indicies) > 120
%         div = ceil(length(indicies)/120);
%         if div >= 2 
%             for i2 = 0:div-2
%                 
%                 plot(Output.pCO2_1(indicies(1+i2*120:(i2+1)*120)));
%             end
%         end
%     else
%         plot(Output.pCO2_1(indicies));
%     end
    
%     pCO2 = Output.pCO2_1(indicies);
%     average = nanmean(Output.pCO2_1(indicies));
%     flags3 = ~( pCO2 > average - 2*std(pCO2(~isnan(pCO2))) & pCO2 < average + 2*std(pCO2(~isnan(pCO2))) );
%     Output.pCO2_1(flags3) = [];
    
    %t1 = Output.date_num(indicies(1));
    %t2 = Output.date_num(max(indicies));

    %t = t1:step:t2;
    %smooth = interp1nan(t,Output.pCO2_1(indicies),linspace(t1,t2,length(indicies)));
    %plot(smooth);
    plot(pCO2(indicies));
end


function obj = nanmean_smooth(obj, prop, wsize)
    %code following getsstA_V3a.m
    sh = (wsize-1) * .5;
    prop0 = obj.(prop);
    nv = size(obj.date_num,1);
    for i=wsize:nv-wsize
    obj.(prop)(i) = nanmean(prop0(i-sh:i+sh));
    end
end
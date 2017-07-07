% limitations to this:
% can't seperate separate "casts" like SMBO ?
% therefore can't create grids ?


% date_string = datenum(str2num(y),str2num(mth),str2num(d),str2num(h),str2num(m),str2num(s)));

addpath splashmay2ndco2surfacesamplerdataandscripts
addpath rectdandco2
addpath functions


data = [load('KDS_20170524T090147.txt');load('KDS_20170524T103400.txt')];

CompileData(data)
load CompiledDataSet.mat
load IndividualNames.mat

analyze_correlations(data_structure);

% hold off
% figure
% scatter(lons,lats,flour)



function CompileData(dataz)
    [x y] = size(dataz);
    date_num = zeros(x,1);
    distance = zeros(x,1);
    lons = dataz(:,4);
    lats = dataz(:,5);
    pCO2_1 = dataz(:,6);
    pCO2_2 = dataz(:,7);
    temps = dataz(:,9);
    salts = dataz(:,10);
    cons = dataz(:,11);
    flour = dataz(:,12);
    
    % what is the 8th coloumn ?? depth?

    tic
    disp('Converting dates');
    for i = 1:x
        mydate2 = num2str(dataz(i,2));
        d = str2num(mydate2(1:2)); mth = str2num(mydate2(3:4)); y = str2num(mydate2(5:6))+2000;
        mydate3 = num2str(dataz(i,3));
        h = str2num(mydate3(1:2)); 
        m = str2num(mydate3(3:4)); 
        s = 0;
        date_num(i) = datenum(y,mth,d,h,m,s);
    end
    disp('Date Conversion Done');
    toc
    % dx = cos(latr(2:nv)).*(lonr(2:nv)-lonr(1:nv-1));
    %dy =                  (latr(2:nv)-latr(1:nv-1));
     %ds = 6.37e3*sqrt(dx.^2 + dy.^2);    
    
    len = x;
    lonsr = lons * 180/pi;
    latsr = lats * 180/pi;
    
    dx = cos(latsr(2:len)) .* (lonsr(2:len) - lonsr(1:len-1));  
    dy = latsr(2:len)-latsr(1:len-1);
    ds = 6.371E3 * sqrt(dx.^2 + dy.^2);  % in km
    
    dist(1:len) = 0.00;
    
    for i = 1:len-1
        dist(i+1) = dist(i) + ds(i);
    end

    data_structure = struct('date_num',date_num,'lons',lons,'lats', ...
    lats,'pCO2_1',pCO2_1,'pCO2_2',pCO2_2,'temps',temps,'salts',salts,'cons',cons,'fluorescence',flour,'dist',dist);

    save('CompiledDataSet.mat','data_structure');
    save('IndividualNames.mat','date_num','lons','lats','pCO2_1','pCO2_2','temps','salts','cons','flour','dist');
end

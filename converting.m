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
    date_num = zeros(x, y);
    date_str = zeros(x, y);
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

    data_structure = struct('date_num',date_num,'lons',lons,'lats', ...
    lats,'pCO2_1',pCO2_1,'pCO2_2',pCO2_2,'temps',temps,'salts',salts,'cons',cons,'fluorescence',flour);

    save('CompiledDataSet.mat','data_structure');
    save('IndividualNames.mat','date_num','lons','lats','pCO2_1','pCO2_2','temps','salts','cons','flour');
end
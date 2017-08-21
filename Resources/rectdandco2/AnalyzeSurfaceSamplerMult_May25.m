

%% Inputs
saveplots = 0;
UTC2local = -7.0; %UTC to local time conversion [hr]
SurfSampFolder = '/home/jeffxy/Documents/rectdandco2/Surf/';
FluOffset = 46;%(Jan 2016 calibration) Flurometer voltage offset [mV]
FluSF = 0.006;%(Jan 2016 calibration) Flurometer Scale Factor [ml/m^3 Chl / mV]
CO2Folder = '/home/jeffxy/Documents/rectdandco2/CO2/';
CO2CompTimeLag = 0; %#hours the computer is behind local time.
TimeDiffTresh = 5; %[sec] max time difference between gps time and co2 time. If the minimal time difference is larger than the treshold, the co2 data point is dicarded
%Input D:\Research\ObservationalWork\Cruises\5-24-2017name of each segment (seg) file
% seg(1).name = 'KDS_20150427T104324.txt';
% seg(2).name = 'KDS_20150427T113908.txt';

RangeFactor = 1.5;%1.5;%1; %Factor for extended range (beyond measurements) of lat and lon in plots
AnalyzeRange = 1; % To analyze specific sub-ranges, set to 1
Tem_Min=17.3;%24;
Tem_Max=18.3;%6;%
Sal_Min = 33.45;%21;%14;%33.21;
Sal_Max = 33.52;%23;%22;%NaN;
CO2_Min = 265; %nan;
CO2_Max = 315;%nan;
Chl_Min = 0.2;
Chl_Max = 2;%1;%NaN;%15;%
%% 
seg = dir(strcat(SurfSampFolder,'*.txt'));

%% Create Vars
time = [];hour = [];mnt = [];sec = [];lat = [];lon = [];dis = [];tem = [];sal = [];con = [];Chl = [];
%% Load files and get parameters
load coast_cali % Load coast map
for i=1:length(seg)
    name =  strcat(SurfSampFolder,seg(i).name) %Load surface smapler data
    [seg(i).time,seg(i).hour,seg(i).mnt,seg(i).sec,seg(i).lat,seg(i).lon,seg(i).dis,seg(i).tem,seg(i).con,seg(i).sal,seg(i).Chl,~] = getsstA_V3b(name,UTC2local); %Get measured variables from file matrix
    time = [time;seg(i).time];hour = [hour;seg(i).hour];mnt = [mnt;seg(i).mnt];sec = [sec;seg(i).sec];con = [con;seg(i).con];
    lat = [lat;seg(i).lat];lon = [lon;seg(i).lon];dis = [dis,seg(i).dis];tem = [tem;seg(i).tem];sal = [sal;seg(i).sal]; 
    seg(i).Chl = (seg(i).Chl - FluOffset)*FluSF ;Chl = [Chl;seg(i).Chl];
end

%% Statistics
% CorTemSal = corrcoef(tem,sal)
% CorTemCon = corrcoef(tem,con)
% [CorTemSal,ProbTemSal,RLOTemSal,RUPTemSal] = corrcoef(tem,sal)
% [CorTem,P,RLO,RUP] = corrcoef(tem,con)


%% General Plots

fh = figure;
for i=1:length(seg)
    plot(24*seg(i).time(:), seg(i).tem(:));
    hold on;
end
title('Temperature vs time');ylabel('Temperature [C]');xlabel('Time [0-24]');
if saveplots==1
    figfn = strcat(SurfSampFolder,'TemperatureVsTime');
    print(fh,figfn,'-dpng','-r0');
end


fh = figure;
for i=1:length(seg)
    plot(24*seg(i).time(:), seg(i).sal(:));
    hold on;
end
title('Salinity vs time');ylabel('Salinity [psu]');xlabel('Time [0-24]');
if saveplots==1
    figfn = strcat(SurfSampFolder,'SalinityVsTime');
    print(fh,figfn,'-dpng','-r0');
end


fh = figure;
for i=1:length(seg)
    plot(24*seg(i).time(:), seg(i).Chl(:));
    hold on;
end
title('Chl vs time');ylabel('Chl [mg/m^3]');xlabel('Time [0-24]');
if saveplots==1
    figfn = strcat(SurfSampFolder,'ChlVsTime');
    print(fh,figfn,'-dpng','-r0');
end

% Range of plots:
LatRange = max(lat) - min(lat);
LonRange = max(lon) - min(lon); 
% Nlim = max(lat) + LatRange*RangeFactor;%North limit for plotting
% Slim = min(lat) - LatRange*RangeFactor;%South limit for plotting
% Elim = max(lon) + LonRange*RangeFactor;%East limit for plotting
% Wlim = min(lon) - LonRange*RangeFactor;%West limit for plotting

%The next implementation assures that the plot axes are of approximately
%the same cartesian distance, to minimize distortion.
if LonRange <= LatRange/cos(mean(lat)*pi/180)
    LonRange = LatRange/cos(mean(lat)*pi/180);
else 
    LatRange = LonRange*cos(nanmean(lat)*pi/180);
end

Nlim = (max(lat) + min(lat))/2 + LatRange*RangeFactor/2;%North limit for plotting
Slim = (max(lat) + min(lat))/2 - LatRange*RangeFactor/2;%South limit for plotting
Elim = (max(lon) + min(lon))/2 + LonRange*RangeFactor/2;%East limit for plotting
Wlim = (max(lon) + min(lon))/2 - LonRange*RangeFactor/2;%West limit for plotting

%Position and time plot
fh = figure;plot(lon,lat,'k');
for i=1:length(seg)
    hold on;
    mesh([seg(i).lon(:) seg(i).lon(:)], [seg(i).lat(:) seg(i).lat(:)], [24*seg(i).time(:) 24*seg(i).time(:)], ...
    'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
end
xlim([Wlim Elim]);ylim([Slim Nlim]);colorbar;colormap(jet(256));title('Position and hour of day');grid;
xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
if saveplots==1
    figfn = strcat(SurfSampFolder,'TimeTraj');
    print(fh,figfn,'-dpng','-r0');
    saveas(fh,strcat(figfn,'.fig'));
end

%Position and temperature plot
if isnan(Tem_Min)
    Tem_Min = min(tem);
end
if isnan(Tem_Max)
    Tem_Max = max(tem);
end
fh = figure;plot(lon,lat,'k');
for i=1:length(seg)
    hold on;
    mesh([seg(i).lon(:) seg(i).lon(:)], [seg(i).lat(:) seg(i).lat(:)], [seg(i).tem(:) seg(i).tem(:)], ...
    'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
end
xlim([Wlim Elim]);ylim([Slim Nlim]);caxis([Tem_Min,Tem_Max]);colorbar;colormap(jet(256));grid;
xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');title('Surface Temperature [C]');hold off;
if saveplots==1
    figfn = strcat(SurfSampFolder,'TemperatureTraj');
    print(fh,figfn,'-dpng','-r0');
    saveas(fh,strcat(figfn,'.fig'));
end

%Position and salinity plot
if isnan(Sal_Min)
    Sal_Min = min(sal);
end
if isnan(Sal_Max)
    Sal_Max = max(sal);
end
fh = figure;plot(lon,lat,'k');
for i=1:length(seg)
    hold on;
    mesh([seg(i).lon(:) seg(i).lon(:)], [seg(i).lat(:) seg(i).lat(:)], [seg(i).sal(:) seg(i).sal(:)], ...
    'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
end
xlim([Wlim Elim]);ylim([Slim Nlim]);caxis([Sal_Min,Sal_Max]);colorbar;colormap(jet(256));grid;
title('Surface Salinity [psu]');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
if saveplots==1
    figfn = strcat(SurfSampFolder,'SalinityTraj');
    print(fh,figfn,'-dpng','-r0');
    saveas(fh,strcat(figfn,'.fig'));
end

if isnan(Chl_Min)
    Chl_Min = min(Chl);
end
if isnan(Chl_Max)
    Chl_Max = max(Chl);
end
fh = figure;plot(lon,lat,'k');
for i=1:length(seg)
    hold on;
    mesh([seg(i).lon(:) seg(i).lon(:)], [seg(i).lat(:) seg(i).lat(:)], [seg(i).Chl(:) seg(i).Chl(:)], ...
    'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
end
xlim([Wlim Elim]);ylim([Slim Nlim]);colorbar;colormap(jet(256));grid;
caxis([Chl_Min,Chl_Max]);
title('Surface Chl [mg/m^3]');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
if saveplots==1
    figfn = strcat('ChlTraj');
end



%% CO2 Load files and get parameters

CO2segs = dir(strcat(CO2Folder,'*.txt'));

%% Create Vars
CO2 = []; CO2lat = []; CO2lon = []; CO2time = [];

for i=1:length(CO2segs)
    name = strcat(CO2Folder,CO2segs(i).name);
    [CO2segs(i).time,CO2segs(i).CO2] = CO2_Reader(name,CO2CompTimeLag);
    co2t1 = nanmin(CO2segs(i).time); co2t2 = nanmax(CO2segs(i).time);
    co2time = CO2segs(i).time;
%     interpolate co2 to gps times 
    CO2i = interp1(CO2segs(i).time/24/3600,CO2segs(i).CO2,time); %method)
    lati = lat(~isnan(CO2i)); loni = lon(~isnan(CO2i));
    timei = time(~isnan(CO2i)); 
    CO2i = CO2i(~isnan(CO2i));
    fh = figure;plot(24*timei,CO2i);
    title('Dissolved CO2 [ppm]');xlabel('Time [0-24 hours]');
    if saveplots==1
        figfn = strcat(SurfSampFolder,'CO2vst_',num2str(i));
        print(fh,figfn,'-dpng','-r0');
    end
    CO2segs(i).CO2i = CO2i'; CO2segs(i).timei = timei';
    CO2segs(i).lati = lati'; CO2segs(i).loni = loni';
    CO2 = [CO2, CO2segs(i).CO2i];
    CO2lat = [CO2lat, CO2segs(i).lati];
    CO2lon = [CO2lon, CO2segs(i).loni];
    CO2time = [CO2time, CO2segs(i).timei];
end

%Position and CO2 plot
if isnan(CO2_Min)
    CO2_Min = min(CO2);
end
if isnan(CO2_Max) 
    CO2_Max = max(CO2);
end
fh = figure;plot(lon,lat,'k');
for i=1:length(CO2segs)
    hold on;
    [CO2segs(i).CO2i(:) CO2segs(i).CO2i(:)]
    mesh([CO2segs(i).loni(:) CO2segs(i).loni(:)], [CO2segs(i).lati(:) CO2segs(i).lati(:)], [CO2segs(i).CO2i(:) CO2segs(i).CO2i(:)], ...
    'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
end
xlim([Wlim Elim]);ylim([Slim Nlim]);caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid;
title('Surface dissolved CO2 [ppm]');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
if saveplots==1
    figfn = strcat(SurfSampFolder,'CO2traj');
    print(fh,figfn,'-dpng','-r0');
    saveas(fh,strcat(figfn,'.fig'));
end

fh = figure;plot(lon,lat,'k');
for i=1:length(CO2segs)
    hold on;
    mesh([CO2segs(i).loni(:) CO2segs(i).loni(:)], [CO2segs(i).lati(:) CO2segs(i).lati(:)], [24*CO2segs(i).timei(:) 24*CO2segs(i).timei(:)], ...
    'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
end
xlim([Wlim Elim]);ylim([Slim Nlim]);%caxis([CO2_Min,CO2_Max]);
colorbar;colormap(jet(256));grid;
title('CO2 logger interpolated gps time [0-24]');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
if saveplots==1
    figfn = strcat(SurfSampFolder,'CO2timetraj');
    print(fh,figfn,'-dpng','-r0');
    saveas(fh,strcat(figfn,'.fig'));
end
% 
%     %1. find gps time closest to co2t1
%     figure;plot(time,CO2segs(i).CO2i);
%     timediff = abs(co2time(1)-time);
%     CO2segs(i).time2 = [];NT = 0;
%     for it = 1:length(co2time)
%         timediff = abs(co2time(it)-time);
%         m = min(timediff);
%         if m(1)<=TimeDiffTresh
%             NT = NT + 1;
%             ntm = find(timediff==m(1));
%             CO2segs(i).time2(NT) = time(ntm);
%             
%         end
%     end
%     %2. find gps time closest to co2t2
%     %3. interpolate co2 to gps times between the found gps times
% %     CO2time = [CO2time;CO2segs(i).time];
% %     CO2 = [CO2;CO2segs(i).CO2];


%% Analyze specific range of measurements
if AnalyzeRange==1
    limitingvar = time*24;
    lowlim = 10.9;%11.03;%9.9;
    highlim = 13.36;%12.5;%24*max(time);
    [time2,lat2,lon2,dis2,tem2,sal2,~] = LimitRange(time,lat,lon,dis,tem,sal,sal,limitingvar,lowlim,highlim) ;
    [CO2timeb,CO2latb,CO2lonb,CO2b,~,~,~] = LimitRange(CO2time,CO2lat,CO2lon,CO2,CO2time,CO2time,CO2time,CO2time*24,lowlim,highlim) ;

    % Range of plots:
    LatRange = nanmax(lat2) - nanmin(lat2);
    LonRange = nanmax(lon2) - nanmin(lon2); 

    %The next implementation assures that the plot axes are of approximately the same cartesian distance, to minimize distortion.
    if LonRange <= LatRange/cos(nanmean(lat2)*pi/180)
        LonRange = LatRange/cos(nanmean(lat2)*pi/180);
    else 
        LatRange = LonRange*cos(nanmean(lat2)*pi/180);
    end

    Nlim = (nanmax(lat2) + nanmin(lat2))/2 + LatRange*RangeFactor/2;%North limit for plotting
    Slim = (nanmax(lat2) + nanmin(lat2))/2 - LatRange*RangeFactor/2;%South limit for plotting
    Elim = (nanmax(lon2) + nanmin(lon2))/2 + LonRange*RangeFactor/2;%East limit for plotting
    Wlim = (nanmax(lon2) + nanmin(lon2))/2 - LonRange*RangeFactor/2;%West limit for plotting



    %Position and time plot
    fh = figure; mesh([lon2(:) lon2(:)], [lat2(:) lat2(:)], [24*time2(:) 24*time2(:)], ...
        'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
    xlim([Wlim Elim]);ylim([Slim Nlim]);colorbar;colormap(jet(256));
    hold on;plot(lon,lat,'k');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
    title('Position and hour of day');
    if saveplots==1
        figfn = strcat(SurfSampFolder,'FocTimeTraj');
        print(fh,figfn,'-dpng','-r0');
        saveas(fh,strcat(figfn,'.fig'));
    end
    %Position and temperature plot
    fh = figure; mesh([lon2(:) lon2(:)], [lat2(:) lat2(:)], [tem2(:) tem2(:)], ...
        'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
    xlim([Wlim Elim]);ylim([Slim Nlim]);colorbar;colormap(jet(256));
    hold on;plot(lon,lat,'k');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
    title('Surface Temperature [C]');
    if saveplots==1
        figfn = strcat(SurfSampFolder,'FocTemperatureTraj');
        print(fh,figfn,'-dpng','-r0');
        saveas(fh,strcat(figfn,'.fig'));
    end    
    %Position and salinity plot
    fh = figure; mesh([lon2(:) lon2(:)], [lat2(:) lat2(:)], [sal2(:) sal2(:)], ...
        'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
    xlim([Wlim Elim]);ylim([Slim Nlim]);caxis([Sal_Min,Sal_Max]);colorbar;colormap(jet(256));
    hold on;plot(lon,lat,'k');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
    title('Surface Salinity [psu]');
    if saveplots==1
        figfn = strcat(SurfSampFolder,'FocSalinityTraj');
        print(fh,figfn,'-dpng','-r0');
        saveas(fh,strcat(figfn,'.fig'));
    end
    fh = figure;plot(lon,lat,'k');
    mesh([CO2lon(:) CO2lon(:)], [CO2lat(:) CO2lat(:)], [CO2(:) CO2(:)], ...
        'EdgeColor', 'interp', 'FaceColor', 'none','LineWidth',2.5);view(2);
    for i=1:length(CO2segs)
        hold on;
    end
    xlim([Wlim Elim]);ylim([Slim Nlim]);caxis([CO2_Min,CO2_Max]);colorbar;colormap(jet(256));grid;
    title('Surface dissolved CO2 [ppm]');xlabel('longitude [^{\circ}]');ylabel('latitude [^{\circ}]');hold off;
    if saveplots==1
        figfn = strcat(SurfSampFolder,'FocCO2traj');
        print(fh,figfn,'-dpng','-r0');
        saveas(fh,strcat(figfn,'.fig'));
    end

    
end


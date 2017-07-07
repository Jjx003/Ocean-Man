function [time,hour,mnt,sec,lat,lon,dis,tem,con,sal,head] = getsstA_V3a(pfname,UTC2local)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                      %%
%%   Matlab code to interpolate and plot sst data       %%
%%   in real time.                                      %%
%%                                                      %%
%%                                                      %%
%%   February 2004, Jeroen Molemaker (310) 2069381      %%
%%                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Altered by Aviv S., April 28, 2015
%V2 2017-04-17 - account for changes made in surf-samp files
try
 %   f = load(pfname);
   f = importdata(pfname,',');
catch
  disp('loading file failed')
  tt = lasterr;
  time =[0:0.01:1];
  lat = time;
  lon = time;
  dis = time;
  tem = 16.0 + 0.01*time;
  sal = 33.0 + 0.01*time;
  return
end
%  Load data; 
tim = f(:,3);
lat = f(:,5); %dlat=fix(lat); lat = lat - dlat; lat = lat*100/60 + dlat;
lon = f(:,4); %dlon=fix(lon); lon = lon - dlon; lon = lon*100/60 + dlon;
tem = f(:,9);
con = f(:,11);
sal = f(:,10);
head = f(:,5);%heading

%% Remove weird coordinates
bad = find(lat<28.6 | lat>29.6 | lon<-91 | lon>-89|tem<11 | tem > 35);  
tim(bad) = [];
lon(bad) = [];
lat(bad) = [];
tem(bad) = [];
con(bad) = [];
sal(bad) = [];
head(bad) = [];


nv = size(tim,1);

%% %% If the change in value between adjacent salinity measurements
%% is too large it's most likely a outlaying point. Remove.
%for i = 1:4
%bad = find( abs(sal(3:nv)-sal(2:nv-1))>0.0025  & abs(sal(3:nv)-sal(1:nv-2))>0.0025  & ); 
%bb = bad
%tim(bad+1) = [];                               
%lon(bad+1) = [];
%lat(bad+1) = [];
%tem(bad+1) = [];
%con(bad+1) = [];
%sal(bad+1) = [];
%flu(bad+1) = [];
%nv = size(tim,1);
%end;

%% %  Running average with wsiz window size.
%  wsiz is 3 for tem and fluor
 wsiz =    3;
 sh   =  (wsiz-1)/2;
 tem0 = tem;
%  for i=wsiz:nv-wsiz
%     tem(i) = sum(tem0(i-sh:i+sh))/wsiz;
%  end
 for i=wsiz:nv-wsiz
    tem(i) = nanmean(tem0(i-sh:i+sh));
 end
 tem(tem==0) = nan;
 
%  wsiz is 5 for sal, a noisy signal
 wsiz =    3;
 sh   =  (wsiz-1)/2;
 sal0 = sal;
% for i=wsiz:nv-wsiz
%    sal(i) = sum(sal0(i-sh:i+sh))/wsiz;
%  end
 for i=wsiz:nv-wsiz
    sal(i) = nanmean(sal0(i-sh:i+sh));
 end
 sal(sal==0) = nan;
 
 %% Delay Temperature
% timedel = 20;
% tem0 = tem;
% for i=(timedel+1):nv
%     tem(i) = tem0(i-timedel);
% end;
% for i = 1:timedel
%     tem(1) = tem0(timedel+1);
% end
% sal= psal(con,tem,1);
% 
% timedel = 10;
% con0 = con;
% for i=(timedel+1):nv
%     con(i) = con0(i-timedel);
% end;
% for i = 1:timedel
%     con(1) = con0(timedel+1);
% end
% sal= psal(con,tem,1);

%% Construct time in decimal hours
  hour = floor(tim/10000);
  mnt  = floor( (tim-hour*10000)/100);
  sec  = tim - hour*10000 -mnt*100;
  hour = hour + UTC2local; %Aviv - addition: translate by the externally controlled parameter U2C2local, to account for summer time et cet.
  time = datenum(0,0,0,hour,mnt,sec);
  time(time<0) = time(time<0) + 1; %Aviv - addition: negative time is due to UTC date advancing (since then time is set to zero)
                                    %, so offset time by 1 day

%% Construct distances
%
 dis(1:nv) = 0.0;
 lonr = lon*pi/180.;
 latr = lat*pi/180.;
 dx = cos(latr(2:nv)).*(lonr(2:nv)-lonr(1:nv-1));
 dy =                  (latr(2:nv)-latr(1:nv-1));
 ds = 6.37e3*sqrt(dx.^2 + dy.^2);                   %% Units of kilometers
%
%
 for j=1:nv-1
   dis(j+1) = dis(j) + ds(j);
 end;




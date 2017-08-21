function [t,co2] = CO2_Reader(fn,CompTimeLag)

%fn = file name
%CompTimeLag = time lag [hours] of the recording computer, behind utc

f = importdata(fn,'\n');
f2 = []; nr2 = 1;
for nr = 1:length(f)
    if (length(f{nr})~=28 && length(strsplit(char(f{nr})))==13)
        f2{nr2} = f{nr};
        nr2 = nr2 + 1;
    end
end

% f = f.textdata;
co2 = zeros(size(f2));
t = co2;
for l = 1:length(f2)
    s = strsplit(char(f2(l)),' ');
    if length(s)>6
        co2(l) = str2num(s{7}); %[ppm] CO2 in gas
        p(l) = str2num(s{11}); %[mbar] cell gas pressure
%         date = s{1}; 
        time = s{3};
        Hour = str2num(time(1:2)); Minute = str2num(time(4:5)); Sec = str2num(time(7:8));
        MilSec = str2num(time(10:12));
        t(l) = ((Hour*60) + Minute)*60 + Sec + MilSec/1000; % t is currently in seconds
    end
end


P0 = 1013.25; %[mbar] standard atmospheric pressure
co2 = co2.*p/P0;
%t = t + CompTimeLag*3600;
t = t + CompTimeLag*3600;
% figure;plot((t-t(1))/3600,co2);
% xlabel('Time [hours 0-24]');ylabel('Dissolved CO2 [ppm]');
% CO2 =
% M = dlmread(fn);
% load(fn);


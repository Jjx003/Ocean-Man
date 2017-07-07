

function [time,lat,lon,dis,tem,sal,flu] = LimitRange(time,lat,lon,dis,tem,sal,flu,limitingvar,lowlim,highlim) 

bad = find(limitingvar<lowlim | limitingvar>highlim);  %% Find observations out of desired range
time(bad) = [];
lon(bad) = [];
lat(bad) = [];
tem(bad) = [];
sal(bad) = [];
flu(bad) = [];
dis(bad) = [];


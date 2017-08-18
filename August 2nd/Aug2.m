addpath('August 2nd');

fname = 'KDS_20170802T081954.txt';


SurfFolder = '/home/jeffxy/Documents/August 2nd/Surf/';
CO2Folder = '/home/jeffxy/Documents/August 2nd/CO2/';

zodiac = CO2Surf(SurfFolder,CO2Folder,[]);
plot(zodiac.lon,zodiac.lat);
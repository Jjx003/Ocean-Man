%%%
%%% loadMooringData.m
%%%
%%% Loads mooring data from .nc files into Matlab.
%%%

fname = 'mooring_2006_ctd.nc';

%%% Get information about the data stored in the file
info = ncinfo(fname);

%%% Print the names of the variables stored in the file
vars = info.Variables;
vars.Name

%%% Find out more about the 'time' variable: its Dimensions and Attributes
time_var = vars(3);
[time_var.Dimensions(1).Name ' ' num2str(time_var.Dimensions(1).Length)]
[time_var.Attributes(1).Name ' ' time_var.Attributes(1).Value]
[time_var.Attributes(2).Name ' ' time_var.Attributes(2).Value]

%%% Read in some data: the wind speed
time = ncread(fname,'time');
windspd = ncread(fname,'windspd');

%%% How big are the arrays?
size(time)
size(windspd)

%%% Wind speed is a 1 x 1 x 95823 matrix, so squeeze it so that we can make
%%% plots
windspd = squeeze(windspd);

%%% We need to convert time to datenum format to plot it
time = datenum('01-JAN-2001') + time/86400;

%%% Now we can make a plot
figure;
plot(time,windspd);
datetick('x','mmmm','keeplimits');
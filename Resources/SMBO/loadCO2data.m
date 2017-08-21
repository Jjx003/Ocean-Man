%%% From the data file - this tells us how the data are laid out
%Aggregate	d data for 	pCO2, CTD, 	and Metsys,	 allow 10 m	in [600s] o	f time diff	erence for 	closest val	ues for CTD	, and Metsy	s to match 	CO2 data
%1: Time [	s], Start 1	.1.2001, PS	T									
%2: water 	xCO2 [ppm]=	[uatm], wet	 values									
%3: air xC	O2 [ppm]=[u	atm], wet v	alues									
%4: delta 	pCO2=(air x	CO2 - water	 xCO2) [ppm	]=[uatm]								
%5: Oxygen	 saturation	 [%]										
%6: SST [d	eg C] from 	surface CTD										
%7: Salini	ty from sur	face CTD										
%8: Pressu	re [dbar] f	rom surface	 CTD									
%9: Transm	issivity [V	]										
%10: Fluor	escence [V]											
%11: Air t	emperature 	[deg C]										
%12: Barom	etric press	ure [dbar]										
%13: Winds	peed [m/s]											
%14: Windd	irection [g	rad]										
    %15: Winds	peed u-comp	onent [m/s]										
    %16: Winds	peed v-comp	onent [m/s]										

    %%% Bad data value
    bad_data_value = -99.99990;

    %%% Load the data - gives us a 1531 by 16 matrix
    load CO2_all_0810_2002_600.dat;

%%% Pull out time (in seconds since 01-01-2001) vector
time_in_s = CO2_all_0810_2002_600(:,1);
time_datenum = datenum('01 Jan 2001') + time_in_s/(60*60*24);

%%% Pull out delta-pCO2
dpCO2 = CO2_all_0810_2002_600(:,4);

%%% Pull out fluorescence
fluor = CO2_all_0810_2002_600(:,10);

%%% Remove bad data values
fluor(fluor==bad_data_value) = NaN;

%%% Make a time series plot
figure(1);
plot(time_datenum,dpCO2);
datetick('x',20,'keeplimits');
xlabel('Time');
ylabel('{\Delta}pCO2 (ppm)');
figure(2);
plot(time_datenum,fluor);
datetick('x',20,'keeplimits');
xlabel('Time');
ylabel('Fluorescence (V)');
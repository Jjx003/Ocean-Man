% Usage: 
% CalculateData(reference_data, actual_data, save_to_file_bool (1 or 0), file_name)

tic 
% we are just concatetenating these two data sets because they are from
% same day
data = [load('KDS_20170524T090147.txt');load('KDS_20170524T103400.txt')]; 
data_structure = CompileData(data,0,'Zodiac'); % 0 for don't save to file, 'Zodiac' for name of file (doesn't save anyways)
disp('Done!');

SMBO = load('SMBO_named_2003_2008.mat'); 
% this will serve as our reference data with values of silicate and
% phosphate
Output = CalculateData(SMBO, data_structure, 1, 'asdf');% 1 for save to file, and name it 'asdf'
disp('Done x2!');
toc

% *Note: For CalculateData(reference, data,...) , data does also be the raw
% loaded file ~
% CalculateData(SMBO,...
% [load('KDS_20170524T090147.txt');load('KDS_20170524T103400.txt')],...)
% This works as well (probably more convenient as well

% Since we saved it we can do this:
% load('asdf.mat');

plot(Output.pCO2_2,Output.omega_arag)

% CalculateData(reference_data, actual_data, save_to_file_bool (1 or 0),
% file_name)

tic 
% we are just concatetenating these two data sets because they are from
% same day
data = [load('KDS_20170524T090147.txt');load('KDS_20170524T103400.txt')]; 
data_structure = CompileData(data,0,'Zodiac');
disp('Done!');

SMBO = load('SMBO_named_2003_2008.mat'); 
% this will serve as our reference data with values of silicate and
% phosphate
Output = CalculateData(SMBO, data_structure, 1, 'asdf'); 
disp('Done x2!');
toc

% Since we saved it we can do this:
asdf = load('asdf.mat');

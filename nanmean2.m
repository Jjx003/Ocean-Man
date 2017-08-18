function output = nanmean2(n)
n(isnan(n)) = [];
output = mean(n);
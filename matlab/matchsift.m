function [matches] = matchsift(D1,D2,t)
dist = pdist2(D1',D2','euclidean');
[sort_dist,sort_idx] = sort(dist,2);
min1_dist = sort_dist(:,1);
min2_dist = sort_dist(:,2);
dist_r = min1_dist./min2_dist;
corr1_idx = find(dist_r < t);
corr2_idx = sort_idx(:,1);
corr2_idx = corr2_idx(corr1_idx);
matches = [corr1_idx';
           corr2_idx'];


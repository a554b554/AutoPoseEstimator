function [bestH, inliers] = ransacH2to1(keypoints1, keypoints2, matches, T, inlier_thrd)
%this function finds the best fundamental matrix H which corresponds two
%sets of keypoints using RANSAC method. 
%Input:
%   keypoints1 and keypoints2 are all 2 x N matrices saving the coordinates
%   matches is 2 x N matrix saving the correspondence indices
%Output:
%   bestH is the final fitted model
%   inliers saves the inliers indices in matrix matches after RANSAC

corr_pt1 = keypoints1(1:2,matches(1,:));
corr_pt2 = keypoints2(1:2,matches(2,:));
N = size(matches,2);
if nargin < 4
    T = 100;
    inlier_thrd = 15;
end
bestH = [];
inliers = [];
lg_cons_sz = 4;
for t = 1:T
    % random permutation for sampling
    rand_ind = randperm(N);
    % find the sample set indices (4 points for estimation H)
    smp_idx = rand_ind(1:4);
  
    smp_pt1 = corr_pt1(:,smp_idx);
    smp_pt2 = corr_pt2(:,smp_idx);
    % Estimate the model
    curr_H = computeH_norm(smp_pt1, smp_pt2);
    
    % Evaluate the model
    warpHomo_pt2 = curr_H * [corr_pt2;ones(1,N)];
    warp_corr_pt2 = warpHomo_pt2(1:2,:) ./ [warpHomo_pt2(3,:);warpHomo_pt2(3,:)];
    errs = sqrt(sum((corr_pt1 - warp_corr_pt2).^2));
    
    % Find the consensus set
    cons_idx = find(errs < inlier_thrd);
    if length(cons_idx) > lg_cons_sz
        lg_cons_sz = length(cons_idx);
        % fit the model using consensus set again
        bestH = computeH_norm(corr_pt1(:,cons_idx),corr_pt2(:,cons_idx));
        inliers = cons_idx;
    end
end
end
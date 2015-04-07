function [Hs, inliers] = sequentialRANSAC(keypoints1, keypoints2, matches)
% this function finds a set of models and associated inliers using the
% Sequential RANSAC method.
minSz = 20;
i = 1;
left_idxs = 1:size(matches,2);
left_matches = matches;
Hs = {};
inliers = {};
while(true)
    if numel(left_idxs) < minSz
        return
    end
    [H, inls] = ransacH2to1(keypoints1, keypoints2, left_matches, 3000, 10);
    map_inls = left_idxs(inls);
    if length(inls) < minSz
        break;
    end
    Hs{i} = H;
    inliers{i} = map_inls;
    i = i + 1;
    left_idxs = setdiff(left_idxs,map_inls);
    left_matches = matches(:,left_idxs);
end
end
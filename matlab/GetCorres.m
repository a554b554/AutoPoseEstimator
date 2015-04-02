function [corres_left, corres_right] = GetCorres(img_left, img_right)
% this function find the "epipolar" correspondences between two rectified
% views (images)
% the bandwidth is the error along y axis that can be tolerated between two
% correspondences.
% the corres_left and corres_right are the two N-by-2 matrices. each row is
% a point coordinate 

% extract features
[fl,desc_left] = vl_sift(single(img_left));
[fr,desc_right] = vl_sift(single(img_right));
kp_left = fl(1:2, :);
kp_right = fr(1:2, :);

% match features
matches = matchsift(desc_left, desc_right, 0.7);

% run ransac to get correspondences
[H,inliers_cell] = sequentialRANSAC(kp_left, kp_right, matches);

corres_left = [];
corres_right = [];
[h,w] = size(img_left);

for k=1:numel(inliers_cell)
    %clf;
    %imshow([uint8(img_left), uint8(img_right)]);
    %hold on
    inliers = inliers_cell{k};
    for i=1:size(inliers,2)
            %plot([kp_left(1,matches(1,inliers(i))), kp_right(1,matches(2,inliers(i))) + w], [kp_left(2,matches(1,inliers(i))), kp_right(2,matches(2,inliers(i)))], 'g');
            corres_left = [corres_left; kp_left(:,matches(1,inliers(i)))'];
            corres_right = [corres_right; kp_right(:,matches(2,inliers(i)))'];
    end
    %hold off
end
end
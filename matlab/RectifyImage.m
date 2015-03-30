function [img_rec, orig_idx, new_idx] = RectifyImage(img, R, K, d)
%% 
% Rectify an image.
% params:
%   [1] img: input image
%   [2] R: 3-by-3 rotation matrix for rectification
%   [3] K: 3-by-3 intrinsic camera matrix
%   [4] d: 5-by-1 distortion vector
%   [5] img_rec: rectified image

%% rely on the apply_distortion of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));

%%
[nr,nc] = size(img);
img_rec = 255*ones(nr,nc);

[mx,my] = meshgrid(1:nc, 1:nr);
px = reshape(mx',nc*nr,1);
py = reshape(my',nc*nr,1);

% map points back to camera reference frame
rays = inv(K)*[(px - 1)';(py - 1)';ones(1,length(px))];

% Rotation: (or affine transformation):
rays2 = R'*rays;
x = [rays2(1,:)./rays2(3,:);rays2(2,:)./rays2(3,:)];


% Add distortion:
xd = apply_distortion(x,d);
% Reconvert in pixels:

px2 = K(1,1)*xd(1,:)+ K(1,2)*xd(2,:)+K(1,3);
py2 = K(2,2)*xd(2,:)+K(2,3);


% Interpolate between the closest pixels:
px_0 = floor(px2);
py_0 = floor(py2);

good_points = find((px_0 >= 0) & (px_0 <= (nc-2)) & (py_0 >= 0) & (py_0 <= (nr-2)));

px_0 = px_0(good_points);
py_0 = py_0(good_points);

orig_idx = px_0 * nr + py_0 + 1;
new_idx = (px(good_points)-1)*nr + py(good_points);

img_rec(new_idx) = img(orig_idx);


end
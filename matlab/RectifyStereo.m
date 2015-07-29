function [R_l, R_r, S_new, K_l_new, K_r_new, d_l_new, d_r_new] = RectifyStereo(img_sz, S_old, K_l_old, K_r_old, d_l_old, d_r_old)
%% 
% Rectify a stereo system, given the transform between two views (S_old), 
% compute R_r, R_l (rotations) which need to be applied on the two views
% and the new transform of the two view (S_new).
% params:
%   * img_sz: imgage size. [img_height, img_width]
%   * S_old: 3-by-4 matrix [R_old, T_old], which discribes the original transform
%   between two views.
%   * R_r, R_l: 3-by-3 rotation matrices that will be applied on left and
%   right views to make the both camera's image plans the same plan.
%   * K_l_old, K_r_old: 3-by-3 old camera matrices of left and right
%   cameras before rectification.
%   * d_l_old, d_r_old: old distortion matrices of left and right
%   cameras before rectification.
%   * K_l_new, K_r_new: 3-by-3 new camera matrices of left and right
%   cameras after rectification.
%   * d_l_new, d_r_new: new distortion matrices of left and right
%   cameras after rectification.
%   S_new: 3-by-4 matrix [I, T_new], which discribes the new transform
%   between two views.

%% rely on the rodrigues of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));

nx = img_sz(2);
ny = img_sz(1);

%%
R_old = S_old(:, 1:3);
T_old = S_old(:, 4);
%% R_old是实际上右边相机坐标系统在左边相机坐标系统（世界坐标系）上的旋转
%% T_old是实际上右边相机的中心在世界坐标系统上的位置，它是3乘1的一个向量

rod_R_old = rodrigues(R_old);
%% 通过rodrigues函数将一个3乘3的矩阵转化程一个3乘1的向量。
%% 向量的方向代表旋转的方向，即右边相机的坐标系绕世界坐标系旋转的方向
%% 向量的大小（模长）代表旋转的角度大小

% Bring the 2 cameras in the same orientation by rotating them "minimally": 
r_r = rodrigues(-rod_R_old/2);
r_l = r_r';
t = r_r * T_old;
%% 将右边相机的坐标系统往R_old的反方向旋转一般角度，对应的rotation matrix是r_r
%% 将左边相机的坐标系统（世界坐标系）用以r_r镜像对称的旋转方式旋转，旋转矩阵是r_l
%% 到这里，两个被虚拟旋转过的坐标系统方向重合在一起
%% 现在，右边相机的中心在世界坐标系（仍然与左边相机的坐标系重合）中的位置是t

% Rotate (rr) both cameras so as to bring the translation vector in alignment with the (1;0;0) axis:
uu = [1;0;0]; % Horizontal epipolar lines
%% uu是当前新的世界坐标系（仍然与左边相机坐标系重合）x轴上的点。
if dot(uu,t)<0,
    uu = -uu; % Swtich side of the vector 
end;
ww = cross(t,uu);
%% 新的世界坐标系x轴上的点和右边相机的中心点做外积，得到和这两个点组成的平面垂直的方向ww
ww = ww/norm(ww);
%% 将ww的模长设置为1
ww = acos(abs(dot(t,uu))/(norm(t)*norm(uu)))*ww;
%% 将ww的模长变成右边相机的中心点与世界坐标系x轴的夹角大小
rr = rodrigues(ww);
%% 将ww转化成3乘3的旋转矩阵
%% 至此，我们得到了一个统一的旋转矩阵rr。把这个旋转矩阵作用于方向已经统一的左右相机坐标系统，
%% 会得到新的左右相机的坐标系统，这个新得到的坐标系统的x轴与baseline是重合的。

% Global rotations to be applied to both views:
R_r = rr * r_r;
R_l = rr * r_l;

% The resulting rigid transform between the two cameras after image rotations
R_new = eye(3);
T_new = R_r * T_old;
S_new = [R_new, T_new];

fc_left = [K_l_old(1,1), K_l_old(2,2)];
fc_right = [K_r_old(1,1), K_r_old(2,2)];
cc_left = [K_l_old(1,3), K_l_old(2,3)];
cc_right = [K_r_old(1,3), K_r_old(2,3)];
alpha_c_left = 0;
alpha_c_right = 0;
% Computation of the *new* intrinsic parameters for both left and right cameras:
% Vertical focal length *MUST* be the same for both images (here, we are trying to find a focal length that retains as much information contained in the original distorted images):
if d_l_old(1) < 0,
    fc_y_left_new = fc_left(2) * (1 + d_l_old(1)*(nx^2 + ny^2)/(4*fc_left(2)^2));
else
    fc_y_left_new = fc_left(2);
end;
if d_r_old(1) < 0,
    fc_y_right_new = fc_right(2) * (1 + d_r_old(1)*(nx^2 + ny^2)/(4*fc_right(2)^2));
else
    fc_y_right_new = fc_right(2);
end;
fc_y_new = min(fc_y_left_new,fc_y_right_new);

% For simplicity, let's pick the same value for the horizontal focal length as the vertical focal length (resulting into square pixels):
fc_left_new = round([fc_y_new;fc_y_new]);
fc_right_new = round([fc_y_new;fc_y_new]);

% Select the new principal points to maximize the visible area in the rectified images

cc_left_new = [(nx-1)/2;(ny-1)/2] - mean(project_points2([normalize_pixel([0  nx-1 nx-1 0; 0 0 ny-1 ny-1],fc_left,cc_left,d_l_old,alpha_c_left);[1 1 1 1]],rodrigues(R_l),zeros(3,1),fc_left_new,[0;0],zeros(5,1),0),2);
cc_right_new = [(nx-1)/2;(ny-1)/2] - mean(project_points2([normalize_pixel([0  nx-1 nx-1 0; 0 0 ny-1 ny-1],fc_right,cc_right,d_r_old,alpha_c_right);[1 1 1 1]],rodrigues(R_r),zeros(3,1),fc_right_new,[0;0],zeros(5,1),0),2);

% For simplivity, set the principal points for both cameras to be the average of the two principal points.
% NOTE: the principal points' Y are the SAME!
cc_y_new = (cc_left_new(2) + cc_right_new(2))/2;
cc_left_new = [cc_left_new(1);cc_y_new];
cc_right_new = [cc_right_new(1);cc_y_new];

% Of course, we do not want any skew or distortion after rectification:
d_l_new = zeros(5,1);
d_r_new = zeros(5,1);

% The resulting left and right camera matrices:
K_l_new = [fc_left_new(1) 0 cc_left_new(1);0 fc_left_new(2) cc_left_new(2); 0 0 1];
K_r_new = [fc_right_new(1) 0 cc_right_new(1);0 fc_right_new(2) cc_right_new(2); 0 0 1];

end
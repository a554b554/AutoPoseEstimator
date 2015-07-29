function [R_l, R_r, S_new] = RectifyStereo(S_old)
%% 
% Rectify a stereo system, given the transform between two views (S_old), compute R_r, R_l (rotations) which need to be applied on the two views and the new transform of the two view (S_new).
% params:
%   [1] S_old: 3-by-4 matrix [R_old, T_old], which discribes the original transform
%   between two views.
%   [2] R_r, R_l: 3-by-3 matrices
%   [3] S_new: 3-by-4 matrix [I, T_new], which discribes the new transform
%   between two views.

%% rely on the rodrigues of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));

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


end
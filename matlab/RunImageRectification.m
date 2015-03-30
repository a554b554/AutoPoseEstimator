function RunPosEst(img_basepath, calib_data_basepath, view_id, img_ids) 

% rely on the rodrigues of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));
% rely on the featrue extraction of vlfeat
addpath(genpath('../3rdparty/vlfeat'));
run('vl_setup');

if nargin == 0
    img_basepath = '/data/SSD1T/AutoRecalib/gt/feb15/RENAME';
    calib_data_basepath = '/data/SSD1T/AutoRecalib/gt/feb15/Mat';
    view_id = '3';
    img_ids = {'1','3','5','7'}
end

epi_err = 50;

left_calib_matpath = [calib_data_basepath, '/', calib_view_id, '/Calib_Results_left.mat'];
load(left_calib_matpath);
K_left = KK;
d_left = kc;
right_calib_matpath = [calib_data_basepath, '/', calib_view_id, '/Calib_Results_right.mat'];
load(right_calib_matpath);
K_right = KK;
d_right = kc;

% collect correspondences
corres_left = [];
corres_right = [];
for i = 1:numel(img_ids)
    
    left_imgpath = [img_basepath, '/', view_id, '/left', img_ids{i}, '.jpg'];
    right_imgpath = [img_basepath, '/', view_id, '/right', img_ids{i}, '.jpg'];
    % load images and data
    img_left = double(rgb2gray(imread(left_imgpath)));
    img_right = double(rgb2gray(imread(right_imgpath)));

    % get epipolar correspondeces
    [corres_left_, corres_right_] = GetCorres(img_left_rec, img_right_rec, epi_err);
    corres_left = [corres_left; corres_left_];
    corres_right = [corres_right; corres_right_];
    old_epi_err = aver_epi_err_ + old_epi_err;
end
old_epi_err = old_epi_err / numel(img_ids);
corres_count = size(corres_left, 1);

left_imgpath = [img_basepath, '/', view_id, '/left', te_img_id, '.jpg'];
right_imgpath = [img_basepath, '/', view_id, '/right', te_img_id, '.jpg'];
% load images and data
img_left = double(rgb2gray(imread(left_imgpath)));
img_right = double(rgb2gray(imread(right_imgpath)));

% calculate the correction rotation matrix
[Rc_left, Rc_right] = CorrectRotation(corres_left, corres_right, K_left, K_right);

% update the rotation matrices
R_left_new = Rc_left * R_left;
R_right_new = Rc_right * R_right;

% apply the updated rotations on the left and right images 
img_left_rec_new = RectifyImage(img_left, R_left_new, K_left, d_left);
img_right_rec_new = RectifyImage(img_right, R_right_new, K_right, d_right);

[corres_left_new, corres_right_new, new_epi_err] = FindEpiCorres(img_left_rec_new, img_right_rec_new, epi_err);

% load the correct view calibration result (i.e. ground truth) for
% evaluation
correct_calib_matpath = [calib_data_basepath, '/', view_id, '/Calib_Results_stereo.mat'];
load(correct_calib_matpath);
% the transform between two views before rectification
S_cor = [R, T];
% compute the rotations that need to be applied on the left and right
% images so that they will be rectified
[R_left_cor, R_right_cor, S_new_cor] = RectifyStereo(S_cor);
img_left_rec_cor = RectifyImage(img_left, R_left_cor, K_left, d_left);
img_right_rec_cor = RectifyImage(img_right, R_right_cor, K_right, d_right);

old_rot_err = RotationMatDist(R_left / R_right, R);
new_rot_err = RotationMatDist(R_left_new / R_right_new, R);

fprintf('The original epipolar error is: %f \n the new epipolar error is: %f\n', old_epi_err, new_epi_err);
fprintf('The original rotation error is: %f \n the new rotation error is: %f\n', old_rot_err, new_rot_err);

result_img = [uint8(img_left_rec), uint8(img_right_rec); 
               uint8(img_left_rec_new), uint8(img_right_rec_new);
               uint8(img_left_rec_cor), uint8(img_right_rec_cor)];
           
if nargin == 0           
    CheckRectification(result_img);
end

end

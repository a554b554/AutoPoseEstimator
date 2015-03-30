function RunPosEst(img_basepath, calib_data_basepath, view_id, img_ids) 

% rely on the rodrigues of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));
% rely on the featrue extraction of vlfeat
addpath(genpath('../3rdparty/vlfeat'));
run('vl_setup');

if nargin == 0
    img_basepath = '/data/autorecalib/test/feb15';
    calib_data_basepath = '/data/autorecalib/gt/feb15/Mat';
    view_id = '3';
    img_ids = {'1','3','5','7'};
end

left_calib_matpath = [calib_data_basepath, '/', view_id, '/Calib_Results_left.mat'];
load(left_calib_matpath);
K_left = KK;
d_left = kc;
right_calib_matpath = [calib_data_basepath, '/', view_id, '/Calib_Results_right.mat'];
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

    % get correspondeces
    [corres_left_, corres_right_] = GetCorres(img_left, img_right);
    corres_left = [corres_left; corres_left_];
    corres_right = [corres_right; corres_right_];
end
corres_count = size(corres_left, 1);

[R, T] = PosEstByF(corres_left, corres_right, K_left, K_right, size(img_left));


% compute the rotations that need to be applied on the left and right
% images so that they will be rectified
[R_left, R_right, S_new] = RectifyStereo([R, T]);


corres_left = [];
corres_right = [];
old_epi_err = 0;
epi_err = 50;
for i = 1:numel(img_ids)
    
    left_imgpath = [img_basepath, '/', view_id, '/left', img_ids{i}, '.jpg'];
    right_imgpath = [img_basepath, '/', view_id, '/right', img_ids{i}, '.jpg'];
    % load images and data
    img_left = double(rgb2gray(imread(left_imgpath)));
    img_right = double(rgb2gray(imread(right_imgpath)));
    
    % apply the rotations on the left and right images 
    img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
    img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);

    % find epipolar correspondeces and calculate the average epipolar error
    [corres_left_, corres_right_, aver_epi_err_] = FindEpiCorres(img_left_rec, img_right_rec, epi_err);
    corres_left = [corres_left; corres_left_];
    corres_right = [corres_right; corres_right_];
    old_epi_err = aver_epi_err_ + old_epi_err;
end

corres_count = size(corres_left, 1);


% calculate the correction rotation matrix
[Rc_left, Rc_right] = CorrectRotation(corres_left, corres_right, K_left, K_right);

% update the rotation matrices
R_left_new = Rc_left * R_left;
R_right_new = Rc_right * R_right;

% apply the updated rotations on the left and right images 
img_left_rec_new = RectifyImage(img_left, R_left_new, K_left, d_left);
img_right_rec_new = RectifyImage(img_right, R_right_new, K_right, d_right);


result_img = [uint8(img_left_rec_new), uint8(img_right_rec_new); 
               uint8(img_left), uint8(img_right);];
           
if nargin == 0           
    CheckRectification(result_img);
end

end

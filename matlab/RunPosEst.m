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
    img_ids = {'1'};
end

left_calib_matpath = [calib_data_basepath, '/', view_id, '/Calib_Results_left.mat'];
load(left_calib_matpath);
K_left = KK;
d_left = kc;
right_calib_matpath = [calib_data_basepath, '/', view_id, '/Calib_Results_right.mat'];
load(right_calib_matpath);
K_right = KK;
d_right = kc;

gt_calib_matpath = [calib_data_basepath, '/', view_id, '/Calib_Results_stereo.mat'];
load(gt_calib_matpath);
R_gt = R;
T_gt = T;


% if exist('corres.mat')
%     load('corres.mat');
% else
% collect correspondences
corres_left = [];
corres_right = [];
for i = 1:numel(img_ids)
    left_imgpath = [img_basepath, '/', view_id, '/left', img_ids{i}, '.jpg'];
    right_imgpath = [img_basepath, '/', view_id, '/right', img_ids{i}, '.jpg'];
    % load images and data
    img_left = double(rgb2gray(imread(left_imgpath)));
    img_right = double(rgb2gray(imread(right_imgpath)));
    [h,w] = size(img_left);
    % get correspondeces
    [corres_left_, corres_right_] = GetCorres(img_left, img_right);
    corres_left = [corres_left; corres_left_];
    corres_right = [corres_right; corres_right_];
end
% end
corres_count = size(corres_left, 1);

% image for testing
left_imgpath = [img_basepath, '/', view_id, '/left', img_ids{1}, '.jpg'];
right_imgpath = [img_basepath, '/', view_id, '/right', img_ids{1}, '.jpg'];
img_left = double(rgb2gray(imread(left_imgpath)));
img_right = double(rgb2gray(imread(right_imgpath)));

result_img = [ uint8(img_left), uint8(img_right)];
%[R_, T_, F_, E_, P_] = PosEstByF(corres_left, corres_right, K_left, K_right, size(img_left));
%[R, T, E, P] = PosEstByEb(corres_left, corres_right, K_left, K_right);
[Rs, Ts] = PosEstByEbRansac(corres_left, corres_right, K_left, K_right, 500, 0.05, true);

% select best {R,T} from {Rs, Ts}, in the sense that has best rectification results
[corres_left, corres_right] = GetCorres(img_left, img_right);
corres_base_count = size(corres_left, 1);
epi_err_list = zeros(numel(Rs),1);
corres_count_list = zeros(numel(Rs),1);
final_score_list = zeros(numel(epi_err_list), 1);
rect_result_imgs = {};
for i = 1:numel(Rs)
    R = Rs{i};
    T = Ts{i};
    [R_left, R_right, S_new] = RectifyStereo([R, T]);
    img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
    img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
    [corres_left, corres_right, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
    epi_err_list(i) = aver_epi_err;
    corres_count_list(i) = size(corres_left, 1);
    final_score_list(i) = 1 / aver_epi_err + size(corres_left, 1) / corres_base_count;
    rect_result_imgs{i} = [uint8(img_left_rec), uint8(img_right_rec)];
    
    %result_img = [result_img; uint8(img_left_rec), uint8(img_right_rec)];
end
% 
% [epi_errs, epi_rnk] = sort(epi_err_list, 'ascend');
% [corres_counts, corres_rnk] = sort(corres_count_list, 'descend');
% 
% for i = 1:numel(epi_rnk)
%     rank_score = 1 / i;
%     final_score_list(epi_rnk(i)) = final_score_list(epi_rnk(i)) + rank_score;
%     final_score_list(corres_rnk(i)) = final_score_list(corres_rnk(i)) + rank_score;
% end
[final_scores, final_rnk] = sort(final_score_list, 'descend');
plot_cols = 5;
plot_rows = ceil(numel(final_rnk) / plot_cols);
figure(1);
for i = 1:numel(final_rnk)
    subplot(plot_rows, plot_cols, i);
    hold on
    title(['epi_err=', num2str(epi_err_list(final_rnk(i))), ' corres_count=', num2str(corres_count_list(final_rnk(i)))]);
    imshow(rect_result_imgs{final_rnk(i)});
    hold off
end
best_Rt_idx = final_rnk(1);
fprintf('The best epipolar error is: %f \n the best correspondeces count is: %d\n', epi_err_list(best_Rt_idx), corres_count_list(best_Rt_idx));
result_img = [result_img; rect_result_imgs{best_Rt_idx}];
% ground truth rectified images
[R_left_gt, R_right_gt, S_new] = RectifyStereo([R_gt, T_gt]);

img_left_rec_gt = RectifyImage(img_left, R_left_gt, K_left, d_left);
img_right_rec_gt = RectifyImage(img_right, R_right_gt, K_right, d_right);


% 
% corres_left = [];
% corres_right = [];
% old_epi_err = 0;
% epi_err = 50;
% for i = 1:numel(img_ids)
%     
%     left_imgpath = [img_basepath, '/', view_id, '/left', img_ids{i}, '.jpg'];
%     right_imgpath = [img_basepath, '/', view_id, '/right', img_ids{i}, '.jpg'];
%     % load images and data
%     img_left = double(rgb2gray(imread(left_imgpath)));
%     img_right = double(rgb2gray(imread(right_imgpath)));
%     
%     % apply the rotations on the left and right images 
%     img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
%     img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
% 
%     % find epipolar correspondeces and calculate the average epipolar error
%     [corres_left_, corres_right_, aver_epi_err_] = FindEpiCorres(img_left_rec, img_right_rec, epi_err);
%     corres_left = [corres_left; corres_left_];
%     corres_right = [corres_right; corres_right_];
%     old_epi_err = aver_epi_err_ + old_epi_err;
% end
% 
% corres_count = size(corres_left, 1);
% 
% 
% % calculate the correction rotation matrix
% [Rc_left, Rc_right] = CorrectRotation(corres_left, corres_right, K_left, K_right);
% 
% % update the rotation matrices
% R_left_new = Rc_left * R_left;
% R_right_new = Rc_right * R_right;
% 
% % apply the updated rotations on the left and right images 
% img_left_rec_new = RectifyImage(img_left, R_left_new, K_left, d_left);
% img_right_rec_new = RectifyImage(img_right, R_right_new, K_right, d_right);


result_img = [ result_img;
               uint8(img_left_rec_gt), uint8(img_right_rec_gt)];

if nargin == 0           
    CheckRectification(result_img, 2);
end

end

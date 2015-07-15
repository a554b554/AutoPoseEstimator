function RunPosEst(img_basepath, calib_data_basepath, view_id, img_ids) 

diary('./result.txt');
diary on;
warning('off');

% rely on the rodrigues of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));
% rely on the featrue extraction of vlfeat
addpath(genpath('../3rdparty/vlfeat'));
run('vl_setup');

if nargin == 0
    img_basepath = '~/Documents/data/jun18/test';
    calib_data_basepath = '~/Documents/data/jun18/recdata';
    view_id = '3';
    img_ids = {'00100','00600','00700','00900'};
else
    img_basepath = '~/Documents/autorecalib/test/feb15/3';
    calib_data_basepath = '~/Documents/autorecalib/gt/feb15/Mat/3';
    view_id = '3';
    img_ids = {'00000'};  
end

left_calib_matpath = [calib_data_basepath, '/Calib_Results_left.mat'];
load(left_calib_matpath);
K_left = KK;
d_left = kc;
right_calib_matpath = [calib_data_basepath, '/Calib_Results_right.mat'];
load(right_calib_matpath);
K_right = KK;
d_right = kc;

gt_calib_matpath = [calib_data_basepath,  '/Calib_Results_stereo.mat'];
load(gt_calib_matpath);
R_gt = R
T_gt = T
TT = [ 0 -T(3) T(2);T(3) 0 -T(1);-T(2) T(1) 0]
E_gt = R_gt*TT


        


% if exist('corres.mat')
%     load('corres.mat');
% else
% collect correspondences
%fprintf('getting correspondences...\n');

corres_left = [];
corres_right = [];
mid_path = {'00011','00021','00022','00041','00042','00051','00052','00061','00062'};
for j = 1:numel(mid_path)
for i = 1:numel(img_ids)
    left_imgpath = [img_basepath,'/all_',mid_path{j},'_', img_ids{i},'_left.png'];
    right_imgpath = [img_basepath, '/all_', mid_path{j}, '_', img_ids{i} '_right.png'];
    % load images and data
    img_left = double(rgb2gray(imread(left_imgpath)));
    img_right = double(rgb2gray(imread(right_imgpath)));
    left_imgpath
    [h,w] = size(img_left);
    % get correspondeces
    [corres_left_, corres_right_] = GetCorres(img_left, img_right);
    %[corres_left_, corres_right_] = correspondfilter(corres_left_, corres_right_, imread(left_imgpath));
%     showMatchedFeatures(img_left,img_right,corres_left_,corres_right_,'montage');
%     waitforbuttonpress;
    corres_left = [corres_left; corres_left_];
    corres_right = [corres_right; corres_right_];


% end
corres_count = size(corres_left, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load stereoPointPairs;

fprintf('method: ransac\n');
E = findEssentialmatrixRansac(corres_left, corres_right, K_left, K_right);
M_left = [K_left,zeros(3,1)];
M_rights = E2Rts(E);
for i=1:4
    M_right=K_right*M_rights(:,:,i);
    P=triangulate(M_left, corres_left, M_right, corres_right);
    if isempty(find(P(:,3)<0))
        break
    end
end
result_img=[img_left,img_right];
R=M_rights(:,1:3,i);
T=M_rights(:,4,i);
[R_left, R_right, S_new] = RectifyStereo([R, T]);
img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
result_img = [result_img; img_left_rec, img_right_rec];
[corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
aver_epi_err

% 
% [R_left_gt, R_right_gt, S_new] = RectifyStereo([R_gt, T_gt]);
% r = makehgtform('yrotate',-pi/12);
% r = r(1:3,1:3)
% R_left_gt = r*R_left_gt;
% R_right_gt = r*R_left_gt;
% img_left_rec_gt = RectifyImage(img_left, R_left_gt, K_left, d_left);
% img_right_rec_gt = RectifyImage(img_right, R_right_gt, K_right, d_right);

% result_img = [ result_img;
%                uint8(img_left_rec_gt), uint8(img_right_rec_gt)];
% [corres_left_rec, corres_right_rec, aver_epi_err_gt] = FindEpiCorres(img_left_rec_gt, img_right_rec_gt, 50);
% aver_epi_err_gt



% [R_left_gt, R_right_gt, S_new] = RectifyStereo([R_gt, T_gt]);
% r = makehgtform('yrotate',-pi/30);
% r = r(1:3,1:3)
% R_left_gt = r*R_left_gt;
% R_right_gt = r*R_right_gt;
% img_left_rec_gt = RectifyImage(img_left, R_left_gt, K_left, d_left);
% img_right_rec_gt = RectifyImage(img_right, R_right_gt, K_right, d_right);

% result_img = [ result_img;
%                uint8(img_left_rec_gt), uint8(img_right_rec_gt)];
% [corres_left_rec, corres_right_rec, aver_epi_err_det] = FindEpiCorres(img_left_rec_gt, img_right_rec_gt, 50);
% aver_epi_err_det
% toc;



%Rot = [1 0 0; 0 0.86603 -0.5;0 0.5 0.86603];
% Rot = [0 1 0; 1 0 0;0 0 1];
% iml = rotateimg(img_left, Rot, R_left_gt, K_left, d_left);
% imr = rotateimg(img_right, Rot, R_right_gt, K_right, d_right);
% result_img = [result_img;uint8(iml),uint8(imr)];
% 
%  CheckRectification(result_img, 2);
%  return


fprintf('method: 8points\n');
f = estimateFundamentalMatrix(corres_left, corres_right,'Method', 'Norm8Point');
E = K_left'*f*K_right;
M_left = [K_left,zeros(3,1)];
M_rights = E2Rts(E);
for i=1:4
    M_right=K_right*M_rights(:,:,i);
    P=triangulate(M_left, corres_left, M_right, corres_right);
    if isempty(find(P(:,3)<0))
        break
    end
end
result_img=[img_left,img_right];
R=M_rights(:,1:3,i);
T=M_rights(:,4,i);
[R_left, R_right, S_new] = RectifyStereo([R, T]);
img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
result_img = [result_img; img_left_rec, img_right_rec];
[corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
aver_epi_err


fprintf('method: LMedS\n');
f = estimateFundamentalMatrix(corres_left, corres_right,'Method', 'LMedS');
E = K_left'*f*K_right;
M_left = [K_left,zeros(3,1)];
M_rights = E2Rts(E);
for i=1:4
    M_right=K_right*M_rights(:,:,i);
    P=triangulate(M_left, corres_left, M_right, corres_right);
    if isempty(find(P(:,3)<0))
        break
    end
end
result_img=[img_left,img_right];
R=M_rights(:,1:3,i);
T=M_rights(:,4,i);
[R_left, R_right, S_new] = RectifyStereo([R, T]);
img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
result_img = [result_img; img_left_rec, img_right_rec];
[corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
aver_epi_err

fprintf('method: MSAC\n');
f = estimateFundamentalMatrix(corres_left, corres_right,'Method', 'MSAC');
E = K_left'*f*K_right;
M_left = [K_left,zeros(3,1)];
M_rights = E2Rts(E);
for i=1:4
    M_right=K_right*M_rights(:,:,i);
    P=triangulate(M_left, corres_left, M_right, corres_right);
    if isempty(find(P(:,3)<0))
        break
    end
end
result_img=[img_left,img_right];
R=M_rights(:,1:3,i);
T=M_rights(:,4,i);
[R_left, R_right, S_new] = RectifyStereo([R, T]);
img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
result_img = [result_img; img_left_rec, img_right_rec];
[corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
aver_epi_err

fprintf('method: LTS\n');
f = estimateFundamentalMatrix(corres_left, corres_right,'Method', 'LTS');
E = K_left'*f*K_right;
M_left = [K_left,zeros(3,1)];
M_rights = E2Rts(E);
for i=1:4
    M_right=K_right*M_rights(:,:,i);
    P=triangulate(M_left, corres_left, M_right, corres_right);
    if isempty(find(P(:,3)<0))
        break
    end
end
result_img=[img_left,img_right];
R=M_rights(:,1:3,i);
T=M_rights(:,4,i);
[R_left, R_right, S_new] = RectifyStereo([R, T]);
img_left_rec = RectifyImage(img_left, R_left, K_left, d_left);
img_right_rec = RectifyImage(img_right, R_right, K_right, d_right);
result_img = [result_img; img_left_rec, img_right_rec];
[corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
aver_epi_err

%result_img = [img_left_rec, img_right_rec];

% image for testing
% fprintf('loading image for testing...\n')
% tic;
% left_imgpath = [img_basepath, '/all_00001_',img_ids{1},'_left.png'];
% right_imgpath = [img_basepath, '/all_00001_',img_ids{1} '_right.png'];
% img_left = double(rgb2gray(imread(left_imgpath)));
% img_right = double(rgb2gray(imread(right_imgpath)));
% toc;

% fprintf('pos estimation...\n');
result_img = [ uint8(img_left), uint8(img_right)];
%[R_, T_, F_, E_, P_] = PosEstByF(corres_left, corres_right, K_left, K_right, size(img_left));
%[R, T, E, P] = PosEstByEb(corres_left, corres_right, K_left, K_right);
[Rs, Ts] = PosEstByEbRansac(corres_left, corres_right, K_left, K_right, 500, 0.1, true, true);






%fprintf('scoring\n');
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
%     imshow(img_left_rec);
%     waitforbuttonpress;
%     imshow(img_right_rec);
%     waitforbuttonpress;
    [corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres(img_left_rec, img_right_rec, 50);
    epi_err_list(i) = aver_epi_err;
    corres_count_list(i) = size(corres_left_rec, 1);
    final_score_list(i) = 1 / aver_epi_err + 0.6 * size(corres_left_rec, 1) / corres_base_count;
    rect_result_imgs{i} = [uint8(img_left_rec), uint8(img_right_rec)];
    
    %result_img = [result_img; uint8(img_left_rec), uint8(img_right_rec)];
end
fprintf('method: cai');
tic;
min(epi_err_list)
% 
% [epi_errs, epi_rnk] = sort(epi_err_list, 'ascend');
% [corres_counts, corres_rnk] = sort(corres_count_list, 'descend');
% 
% for i = 1:numel(epi_rnk)
%     rank_score = 1 / i;
%     final_score_list(epi_rnk(i)) = final_score_list(epi_rnk(i)) + rank_score;
%     final_score_list(corres_rnk(i)) = final_score_list(corres_rnk(i)) + rank_score;
% end

% fprintf('showing..');
% tic;
% [final_scores, final_rnk] = sort(final_score_list, 'descend');
% plot_cols = 5;
% plot_rows = ceil(numel(final_rnk) / plot_cols);
% figure(1);
% for i = 1:numel(final_rnk)
%     subplot(plot_rows, plot_cols, i);
%     hold on
%     title(['epi_err=', num2str(epi_err_list(final_rnk(i))), ' corres_count=', num2str(corres_count_list(final_rnk(i)))]);
%     imshow(rect_result_imgs{final_rnk(i)});
%     hold off
% end
% best_Rt_idx = final_rnk(1);
% fprintf('The best epipolar error is: %f \n the best correspondeces count is: %d\n', epi_err_list(best_Rt_idx), corres_count_list(best_Rt_idx));
% result_img = [result_img; rect_result_imgs{best_Rt_idx}];

%optimize again by minimizing the reprojection error
% [R_opt, T_opt] = OptimizePos(corres_left, corres_right, K_left, K_right, Rs{best_Rt_idx}, Ts{best_Rt_idx}, 1, 10);
% [R_left_opt, R_right_opt, S_new] = RectifyStereo([R_opt, T_opt]);
% img_left_rec_opt = RectifyImage(img_left, R_left_opt, K_left, d_left);
% img_right_rec_opt = RectifyImage(img_right, R_right_opt, K_right, d_right);
% result_img = [ result_img;
%                uint8(img_left_rec_opt), uint8(img_right_rec_opt)];

%ground truth rectified images
[R_left_gt, R_right_gt, S_new] = RectifyStereo([R_gt, T_gt]);

img_left_rec_gt = RectifyImage(img_left, R_left_gt, K_left, d_left);
img_right_rec_gt = RectifyImage(img_right, R_right_gt, K_right, d_right);

result_img = [ result_img;
               uint8(img_left_rec_gt), uint8(img_right_rec_gt)];
[corres_left_rec, corres_right_rec, aver_epi_err_gt] = FindEpiCorres(img_left_rec_gt, img_right_rec_gt, 50);
aver_epi_err_gt
toc;
% detR = rotx(30);
% R_det_left = R_left_gt*detR;
% R_det_right = R_right_gt*detR;
% img_det_left = RectifyImage(img_left, R_det_left, K_left, d_left);
% img_det_right = RectifyImage(img_right, R_det_right, K_right, d_right);
% result_img = [result_img;img_det_left,img_det_right];
% 
% if nargin == 0           
%     CheckRectification(result_img, 2);
% end

end
end
dairy off;

end

function [aver_epi_err, aver_epi_err_opt, aver_epi_err_gt, csizeratio, csizeratio_opt, csizeratio_gt] = RunPosEstOneCase(img_basepath, calib_data_basepath, img_ids, mid_path, figid) 

%diary('./result.txt');
% diary on;
fid = fopen('./err22.txt','a');
% rely on the rodrigues of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));
% rely on the featrue extraction of vlfeat
addpath(genpath('../3rdparty/vlfeat'));
run('vl_setup');
aver_epi_err=0;
aver_epi_err_opt=0;
aver_epi_err_gt=0;
csizeratio=0;
csizeratio_opt=0;
csizeratio_gt=0;
errs=[];
errsransac=[];

outputtitile=[];

if nargin == 0
    %img_basepath = '~/Documents/data/jun18/test';
    %calib_data_basepath = '~/Documents/data/jun18/recdata';
    img_basepath = '../demo/data/png';
    calib_data_basepath = '../demo/data/mat';
    img_ids = '00000';
    mid_path = '00001';
    figid=314;
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


       

corres_left = [];
corres_right = [];




left_imgpath = [img_basepath,'/all_',mid_path,'_', img_ids,'_left.png'];
right_imgpath = [img_basepath, '/all_', mid_path, '_', img_ids, '_right.png'];


% load images and data
img_left = double(rgb2gray(imread(left_imgpath)));
img_right = double(rgb2gray(imread(right_imgpath)));
left_imgpath

[corres_left, corres_right] = GetCorres(img_left, img_right);
corres_count = size(corres_left, 1);
% showMatchedFeatures(img_left, img_right,corres_left,corres_right,'montage');
% waitforbuttonpress;

% fprintf('pos estimation...\n');
result_img = [ uint8(img_left), uint8(img_right)];
[Rs, Ts] = PosEstByEbRansac(corres_left, corres_right, K_left, K_right, 1000, 0.1, true, true);


corres_base_count = size(corres_left, 1);
epi_err_list = zeros(numel(Rs),1);
corres_count_list = zeros(numel(Rs),1);
final_score_list = zeros(numel(epi_err_list), 1);
rect_result_imgs = {};
rect_result_imgs_left = {};
rect_result_imgs_right = {};
ratio_list={}
for i = 1:numel(Rs)
    R = Rs{i};
    T = Ts{i};
    [R_left, R_right, S_new, K_left_new, K_right_new, d_left_new, d_right_new] = RectifyStereo(size(img_left), [R T], K_left, K_right, d_left, d_right);
    img_left_rec = RectifyImage(img_left, R_left, K_left, d_left, K_left_new);
    img_right_rec = RectifyImage(img_right, R_right, K_right, d_right, K_right_new);
    [corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres2(size(img_left_rec), corres_left, corres_right ,50, R_left, R_right, K_left, K_right, d_left, d_right, K_left_new, K_right_new);
    epi_err_list(i) = aver_epi_err;
    corres_count_list(i) = size(corres_left_rec, 1);
    final_score_list(i) = 1 / aver_epi_err + 0.6 * size(corres_left_rec, 1) / corres_base_count;
    rect_result_imgs{i} = [uint8(img_left_rec), uint8(img_right_rec)];
    rect_result_imgs_left{i} = uint8(img_left_rec);
    rect_result_imgs_right{i} = uint8(img_right_rec);
end
tic;
[err id] = min(epi_err_list);
aver_epi_err = err
csizeratio = corres_count_list(id)/corres_count;
result_img = [result_img; rect_result_imgs{id}];
outputtitile=['err_origin:',num2str(aver_epi_err),' r_origin:',num2str(csizeratio)];

img_left_rec_8p = rect_result_imgs_left{id};
img_right_rec_8p = rect_result_imgs_right{id};



outdatas={};


[R_opt, T_opt] = OptimizePos(corres_left, corres_right, K_left, K_right, Rs{id}, Ts{id}, 1, 10);

outdata=[]; %for i=1:numel(R_opt)
    [R_left_opt, R_right_opt, S_new, K_left_new, K_right_new, d_left_new, d_right_new] = RectifyStereo(size(img_left), [R_opt T_opt], K_left, K_right, d_left, d_right);
    img_left_rec_opt = RectifyImage(img_left, R_left_opt, K_left, d_left, K_left_new);
    img_right_rec_opt = RectifyImage(img_right, R_right_opt, K_right, d_right, K_right_new);
%         [R_left_opt, R_right_opt, S_new] = RectifyStereo([R_opt, T_opt]);
%         img_left_rec_opt = RectifyImage(img_left, R_left_opt, K_left, d_left);
%         img_right_rec_opt = RectifyImage(img_right, R_right_opt, K_right, d_right);
       %imwrite(uint8(img_left_rec_opt),'tool/l.jpg');
       %imwrite(uint8(img_right_rec_opt),'tool/r.jpg');
       
        result_img = [ result_img;
                       uint8(img_left_rec_opt), uint8(img_right_rec_opt)];
        [corres_left_rec_opt, corres_right_rec_opt, aver_epi_err_opt] = FindEpiCorres2(size(img_left_rec_opt), corres_left, corres_right ,50, R_left_opt, R_right_opt, K_left, K_right, d_left, d_right,K_left_new, K_right_new);
        %aver_epi_err_opts=[aver_epi_err_opts;aver_epi_err_opt_];
        aver_epi_err_opt
        csizeratio_opt=size(corres_left_rec_opt,1)/corres_count;
    %end
    %outdatas{j}=outdata;
    %[me,mid]=min(aver_epi_err_opt);
    outputtitile=[outputtitile,' lambda:','no',' err_opt:',num2str(aver_epi_err_opt),' ratio_opt:',num2str(csizeratio_opt)];

%save('fig/output','outdatas');




         
           
           
% ground truth rectified images
[R_left_gt, R_right_gt, S_new, K_left_new, K_right_new, d_left_new, d_right_new] = RectifyStereo(size(img_left), [R_gt T_gt], K_left, K_right, d_left, d_right);
img_left_rec_gt = RectifyImage(img_left, R_left_gt, K_left, d_left, K_left_new);
img_right_rec_gt = RectifyImage(img_right, R_right_gt, K_right, d_right, K_right_new);
% [R_left_gt, R_right_gt, S_new] = RectifyStereoold([R_gt, T_gt]);
% 
% img_left_rec_gt = RectifyImageold(img_left, R_left_gt, K_left, d_left);
% img_right_rec_gt = RectifyImageold(img_right, R_right_gt, K_right, d_right);

result_img = [ result_img;
               uint8(img_left_rec_gt), uint8(img_right_rec_gt)];
%[corres_left_rec, corres_right_rec, aver_epi_err_gt] = FindEpiCorres(img_left_rec_gt, img_right_rec_gt, 50);
[corres_left_rec_gt, corres_right_rec_gt, aver_epi_err_gt] = FindEpiCorres2(size(img_left_rec_gt), corres_left, corres_right ,50, R_left_gt, R_right_gt, K_left, K_right, d_left, d_right, K_left_new, K_right_new);

aver_epi_err_gt
csizeratio_gt = size(corres_left_rec_gt,1)/corres_count;
outputtitile=[outputtitile,' err_gt:',num2str(aver_epi_err_gt),' ratio_gt:', num2str(csizeratio_gt)];
CheckRectification(result_img,figid,outputtitile);
lname=['../demo/result/',mid_path,'_',img_ids,'_left.jpg'];
rname=['../demo/result/',mid_path,'_',img_ids,'_right.jpg'];
if csizeratio == 1 & csizeratio_opt ==1
    if aver_epi_err > aver_epi_err_opt
        imwrite(uint8(img_left_rec_opt),lname);
        imwrite(uint8(img_right_rec_opt),rname);
    else
        imwrite(img_left_rec_8p,lname);
        imwrite(img_right_rec_8p,rname);
    end
elseif csizeratio == 1 
    imwrite(img_left_rec_8p,lname);
    imwrite(img_right_rec_8p,rname);
else
    imwrite(uint8(img_left_rec_opt),lname);
    imwrite(uint8(img_right_rec_opt),rname);
end

imwrite(uint8(img_left_rec_gt),['./output/',mid_path,'_',img_ids,'_left_gt.jpg']);
imwrite(uint8(img_right_rec_gt),['./output/',mid_path,'_',img_ids,'_right_gt.jpg']);



end

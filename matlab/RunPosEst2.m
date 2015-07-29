function outobj = RunPosEst2(img_basepath, calib_basepath, mid_id, img_ids, fig_id)
    addpath(genpath('../3rdparty/caltech_calib'));
    % rely on the featrue extraction of vlfeat
    addpath(genpath('../3rdparty/vlfeat'));
    if nargin == 0
        img_basepath = '~/Documents/data/jun18/test';
        calib_data_basepath = '~/Documents/data/jun18/recdata';
        img_ids = {'00000','00100','00200','00300','00400','00500','00600','00700'};
        mid_path = '00001';
        fig_id = 10000;
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
    
    left_imgpath = [img_basepath,'/all_',mid_path,'_', img_ids{1},'_left.png'];
    right_imgpath = [img_basepath, '/all_', mid_path, '_', img_ids{1}, '_right.png'];
    % load images and data
    img_left = double(rgb2gray(imread(left_imgpath)));
    img_right = double(rgb2gray(imread(right_imgpath)));
    left_imgpath
    
    corres_left=[];
    corres_right=[];
    
    for i = 1:numel(img_ids)
        left_imgpath = [img_basepath,'/all_',mid_path,'_', img_ids{i},'_left.png'];
        right_imgpath = [img_basepath, '/all_', mid_path, '_', img_ids{i}, '_right.png'];
        img_left_ = double(rgb2gray(imread(left_imgpath)));
        img_right_ = double(rgb2gray(imread(right_imgpath)));
        [corres_left_, corres_right_] = GetCorres(img_left_, img_right_,mid_path,img_ids{i});
        corres_left = [corres_left;corres_left_];
        corres_right = [corres_right;corres_right_];
    end
    corres_count = size(corres_left, 1);
    result_img = [ uint8(img_left), uint8(img_right)];
    [Rs, Ts] = PosEstByEbRansac(corres_left, corres_right, K_left, K_right, 1000, 0.1, true, true);
    
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
        [corres_left_rec, corres_right_rec, aver_epi_err] = FindEpiCorres2(img_left_rec, img_right_rec, corres_left, corres_right ,50, R_left, R_right, K_left, K_right, d_left, d_right);
        epi_err_list(i) = aver_epi_err;
        corres_count_list(i) = size(corres_left_rec, 1);
        final_score_list(i) = 1 / aver_epi_err + 0.6 * size(corres_left_rec, 1) / corres_base_count;
        rect_result_imgs{i} = [uint8(img_left_rec), uint8(img_right_rec)];    
    end
    tic;
    [err id] = min(epi_err_list);
    aver_epi_err = err
    csizeratio = corres_count_list(id)/corres_count;
    result_img = [result_img; rect_result_imgs{id}];
    CheckRectification(result_img, fig_id, err, 1, 1, csizeratio, 1, 1);
    
    
end
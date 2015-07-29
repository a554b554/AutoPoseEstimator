function exec()
    warning('off');

    img_basepath = '~/Documents/data/jun18/test';
    calib_data_basepath = '~/Documents/data/jun18/recdata';
    img_ids = {'00100','00300','00600'};
   % mid_path = {'00001'};
    %img_ids = {'00000','00100','00200','00300','00400','00500','00600'};
    mid_path = {'00001','00002','00011','00012','00021','00022','00041','00042','00051','00052','00061','00062'};

    fid = 1;
    errs=[];
    errs_opt=[];
    ratios=[];
    ratios_opt=[];
    for i= 1:numel(mid_path)
        for j=1:numel(img_ids)
            [err,err_opt,err_gt,ratio,ratio_opt,ratio_gt] = RunPosEstOneCase(img_basepath, calib_data_basepath, img_ids{j}, mid_path{i}, fid);
            errs=[errs;err];
            errs_opt = [errs_opt;err_opt];
            ratios=[ratios;ratio];
            ratios_opt = [ratios_opt;ratio_opt];
            fid = fid +1;
        end
    end
    save('./fig/result.mat','errs','errs_opt','ratios','ratios_opt');
    figure(1234);
    bar(errs);
    figure(1235);
    bar(errs_opt);
    figure(1236);
    bar(ratios);
    figure(1237);
    bar(ratios_opt);
   
end
function [corres_left, corres_right, aver_epi_err] = FindEpiCorres2(img_size, origin_corres_left, origin_corres_right, bandwidth, R_left, R_right, K_left, K_right, D_left, D_right,K_left_new, K_right_new)
    nr = img_size(1);
    nc = img_size(2);
    corres_left = adjustCorres(origin_corres_left, R_left, K_left, D_left, K_left_new);
    corres_right = adjustCorres(origin_corres_right, R_right, K_right, D_right, K_right_new);
    [corres_left, corres_right] = goodcorres(corres_left, corres_right, nr, nc, bandwidth);
%     figure(2);
%     showMatchedFeatures(uint8(img_left),uint8(img_right), corres_left, corres_right, 'montage');
%     waitforbuttonpress;
    
    aver_epi_err = 0.0;
    [r c] = size(corres_left);
    for k=1:r
      aver_epi_err = aver_epi_err + abs(corres_left(k,2)-corres_right(k,2)); 
    end
    if size(corres_left)==0
        aver_epi_err = inf;
    else
        aver_epi_err = aver_epi_err/r;
        
end

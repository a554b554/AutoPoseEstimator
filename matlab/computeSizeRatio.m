function ratio = computeSizeRatio(img_left, img_right, R1, R2, K1, K2, D1, D2)
    [nr,nc] = size(img_left);
    step = 40;
    [mx,my] = meshgrid(1:step:nc, 1:step:nr);
    
    px = reshape(mx',nc*nr/step^2,1);
    py = reshape(my',nc*nr/step^2,1);

    adjustCorres(img_left, origin_corres, R, K, d)
end
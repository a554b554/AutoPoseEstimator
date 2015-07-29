function [corres_left, corres_right] = goodcorres(corres_left_origin, corres_right_origin,nr,nc,bandwidth)
    px_0 = corres_left_origin(:,1);
    py_0 = corres_left_origin(:,2);
    px_1 = corres_right_origin(:,1);
    py_1 = corres_right_origin(:,2);
    goods = find((px_0>=0) & (px_0<=nc-2) & (py_0 >= 0) & (py_0 <= nr-2) & (px_1>=0) & (px_1<=nc-2) & (py_1>=0) & (py_1<=nr-2) & abs(py_0-py_1)<bandwidth);
    corres_left = [px_0(goods) py_0(goods)];
    corres_right = [px_1(goods) py_1(goods)];
    
end
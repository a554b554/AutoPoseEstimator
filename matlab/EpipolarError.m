function [obj,J] = EpipolarError(angles, corres_left, corres_right, K_left, K_right)
    lamda = angles(1);
    beta_l = angles(2);
    beta_r = angles(3);
    alpha_l = angles(4);
    alpha_r = angles(5);
    Rc_left = AxisRotation('x', lamda / 2) * AxisRotation('z', beta_l) * AxisRotation('y', alpha_l);
    Rc_right = AxisRotation('x', -lamda / 2) * AxisRotation('z', beta_r) * AxisRotation('y', alpha_r);
    
    rc_left_2 = Rc_left(2,:);
    rc_left_3 = Rc_left(3,:);
    rc_right_2 = Rc_right(2,:);
    rc_right_3 = Rc_right(3,:);
    f_left = K_left(1, 1);
    f_right = K_right(1,1);
    K_inv_left = inv(K_left);
    K_inv_right = inv(K_right);
    KRKinv_left = Rc_left * K_inv_left; % K_left * Rc_left * K_inv_left;
    KRKinv_right = Rc_right * K_inv_right; %K_right * Rc_right * K_inv_right;
    [h, w] = size(corres_left);
    corres_left = [corres_left, ones(h,1)];
    corres_right = [corres_right, ones(h,1)];
    rc_left_2_K_inv = KRKinv_left(2, :);%rc_left_2 * K_inv;
    rc_left_3_K_inv = KRKinv_left(3, :);%rc_left_3 * K_inv;
    rc_right_2_K_inv = KRKinv_right(2,:);%rc_right_2 * K_inv;
    rc_right_3_K_inv = KRKinv_right(3,:);%rc_right_3 * K_inv;
    
    J = zeros(h,5);
    obj = zeros(h, 1);
    for i = 1:h
        err_l = (rc_left_2_K_inv * corres_left(i,:)') / (rc_left_3_K_inv * corres_left(i,:)');
        err_r = (rc_right_2_K_inv * corres_right(i,:)') / (rc_right_3_K_inv * corres_right(i,:)');
        err = f_left * err_l - f_right * err_r;
        
        if nargout > 1
            J_i = ErrorJacob(lamda, beta_l, beta_r, alpha_l, alpha_r, K(1,3), K(2,3), K(1,1), corres_left(i,1), corres_left(i,2), corres_right(i,1), corres_right(i,2));
            J(i,:) = -J_i;
        end
        obj(i,1) = err;
    end
    %obj
end
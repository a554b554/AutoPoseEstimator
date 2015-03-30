function [Rc_left, Rc_right] = CorrectRotation(corres_left, corres_right, K_left, K_right)
    %angles = fminunc(@(angles) EpipolarError(angles, corres_left, corres_right, K),[0, 0, 0, 0, 0], optimset('TolX',1e-10, 'TolFun', 1e-6, 'MaxFunEvals', 5000, 'MaxIter', 5000));
    opt = optimset('Algorithm', 'levenberg-marquardt', 'TolX',1e-20, 'TolFun', 1e-20, 'MaxFunEvals', 20000, 'MaxIter', 20000);
    tic;
    angles = lsqnonlin(@(angles) EpipolarError(angles, corres_left, corres_right, K_left, K_right),[0, 0, 0, 0, 0], [], [], opt);
    toc
    lamda = angles(1);
    beta_l = angles(2);
    beta_r = angles(3);
    alpha_l = angles(4);
    alpha_r = angles(5);
    Rc_left = AxisRotation('x', lamda / 2) * AxisRotation('z', beta_l) * AxisRotation('y', alpha_l);
    Rc_right = AxisRotation('x', -lamda / 2) * AxisRotation('z', beta_r) * AxisRotation('y', alpha_r);
end
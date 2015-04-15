function [R_opt, T_opt] = OptimizePose(X1_o, X2_o, K1, K2, R, T, thrd_iter, max_iter)
% this code optimize the camera pose by minimizing the reprojection errors
% it follows the algorithm described in 5.2.3 in Yi Ma's book (an invitation to 3D vision)
% params: 
% X1_o, X2_o are N-by-3 matrices ("o" represents the observed data, "m" means model/read data)
% R, T are initial estimates of rotation and translation given by eight
% point algorithm.
% thrd_iter and max_iter are the stop criteria 
% R_opt, T_opt are optimized rotation and translation

% initialization
N = size(X1_o, 1);
X1_o = K1 \ [X1_o'; ones(1, N)];
X2_o = K2 \ [X2_o'; ones(1, N)];
X1_m = X1_o;
X2_m = X2_o;

iter_count = 0;
err_old = -thrd_iter;

while iter_count < max_iter
    % update R,T (minimize the X_m to corresponding epipolar line distance)
    [R_opt, T_opt] = UpdatePose(X1_m, X2_m, X1_o, X2_o, R, T);
    % update X1_m, X2_m (minimize the X_o to X_m distance)
    [X1_m, X2_m, err] = UpdateModel(X1_o, X2_o, R_opt, T_opt);
    iter_count = iter_count + 1;
    R = R_opt;
    T = T_opt;
    err
    if abs(err - err_old) < thrd_iter
        break;
    end
    err_old = err;
end

end

function [R_opt, T_opt] = UpdatePose(X1_m, X2_m, X1_o, X2_o, R, T)
    rt_init = [rodrigues(R); T];
    T_norm = norm(T);
    opt = optimset('Algorithm', 'levenberg-marquardt', 'TolX',1e-20, 'TolFun', 1e-20, 'MaxFunEvals', 20000, 'MaxIter', 20000);
    rt_new = lsqnonlin(@(rt_new) Xm2EpiLineError(rt_new, X1_m, X2_m, X1_o, X2_o, T_norm), rt_init, [], [], opt);
    R_opt = rodrigues(rt_new(1:3));
    T_opt = rt_new(4:6) / norm(rt_new(4:6)) * T_norm;
end

function [obj] = Xm2EpiLineError(rt, X1_m, X2_m, X1_o, X2_o, T_norm)
    r = rt(1:3);
    t = rt(4:6) / norm(rt(4:6)) * T_norm;
    R = rodrigues(r);
    T_s = Skew(t);
    e3_s = Skew([0, 0, 1]);
    N = size(X1_m, 1);
    obj = zeros(N, 1);
    TsR = T_s * R;
    e3sTsR = e3_s * TsR;
    TsRe3sT = TsR * e3_s';
    for i = 1:N
        x1_m = X1_m(:, i);
        x2_m = X2_m(:, i);
        x1_o = X1_o(:, i);
        x2_o = X2_o(:, i);
        obj(i) = (x2_o' * TsR * x1_m)^2 / norm(e3sTsR * x1_m)^2 + ...
                 (x2_m' * TsR * x1_o)^2 / norm(x2_m' * TsRe3sT)^2;
    end
    sum(obj)
end

function [X1_m, X2_m, err] = UpdateModel(X1_o, X2_o, R, T)
    err = 0;
    E = Skew(T)*R;
    % the epipole of the right camera (e2' * E = 0)
    e2 = null(E');
    e2 = e2 / norm(e2);
    e3 = [0;0;1];
    e3_s = Skew(e3);
    % get N1, N2 (the bases in right camera)
    while(1)
        a = rand(1);
        b = rand(1);
        c = -(e2(1)*a + e2(2)*b) / e2(3);
        N1 = [a; b; c];
        N1 = N1 / norm(N1);
        if N1 ~= e2
            N2 = cross(e2, N1);
            break;
        end
    end
    X1_m = zeros(3,size(X1_o, 2));
    X2_m = zeros(3,size(X2_o, 2));
    B = e3_s' * e3_s;
    D = e3_s' * e3_s;
    % triagulate for each point
    for i = 1:size(X1_o, 2)
        x1_o = X1_o(:, i);
        x2_o = X2_o(:, i);
        x1_s = Skew(x1_o);
        x2_s = Skew(x2_o);
        A = eye(3) - (e3_s * x2_o * x2_o' * e3_s' + x2_s * e3_s + e3_s * x2_s);
        C = eye(3) - (e3_s * x1_o * x1_o' * e3_s' + x1_s * e3_s + e3_s * x1_s);
        % get the boundary
        l2_b1 = cross(e2, x2_o);
        l2_b2 = cross(e2, R * x1_o);
        l2_b1 = l2_b1 / norm(l2_b1);
        l2_b2 = l2_b2 / norm(l2_b2);
        theta_b1 = acos(l2_b1' * N1);
        theta_b2 = acos(l2_b2' * N1);
        theta = fminbnd(@(theta) Xm2XoError(theta, A, B, C, D, N1, N2, R),min(theta_b1, theta_b2), ...
                                            max(theta_b1, theta_b2), ...
                                            optimset('TolX',1e-12, 'MaxFunEvals', 10000, 'MaxIter', 10000));
                                        
        l2 = cos(theta) * N1 + sin(theta) * N2;
        l1 = R' * l2;
        l2_s = Skew(l2);
        l1_s = Skew(l1);
        x1_m = (e3_s * l1 * l1' * e3_s' * x1_o + l1_s' * l1_s * e3) / (e3' * l1_s' * l1_s * e3);
        x2_m = (e3_s * l2 * l2' * e3_s' * x2_o + l2_s' * l2_s * e3) / (e3' * l2_s' * l2_s * e3);
        x1_m = x1_m / x1_m(3);
        x2_m = x2_m / x2_m(3);
        X1_m(:,i) = x1_m;
        X2_m(:,i) = x2_m;
        err = err + norm(x1_m - x1_o) + norm(x2_m - x2_o);
    end
end



function [obj] = Xm2XoError(theta, A, B, C, D, N1, N2, R)
    l2 = cos(theta) * N1 + sin(theta) * N2;
    obj = (l2' * A * l2) / (l2' * B * l2) + ... 
          (l2' * R * C  * R' * l2) / (l2' * R * D  * R' * l2);
end
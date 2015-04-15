function R = e2R(w, theta)
% w: the rotate direction, 3-by-1 vector
% theta: the rotation angle size,(0 , 2\pi)

% get w skew
w_s = Skew(w);
% get rotation R = e^(w_s* theta)
R = eye(3) + w_s * sin(theta) + w_s * w_s * (1 - cos(theta));
end
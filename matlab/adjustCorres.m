function adjusted_corres = adjustCorres(origin_corres, R, K, d, K_new)

%% rely on the apply_distortion of caltech toolbox
addpath(genpath('../3rdparty/caltech_calib'));

%%
% img_rec = 255*ones(nr,nc);
% 
% [mx,my] = meshgrid(1:nc, 1:nr);
[r0,c0] = size(origin_corres);
px = origin_corres(:,1);
py = origin_corres(:,2);

% map points back to camera reference frame
rays = inv(K)*[px';py';ones(1,length(px))];
  
% Rotation: (or affine transformation):
rays2 = R*rays;
x = [rays2(1,:)./rays2(3,:);rays2(2,:)./rays2(3,:)];


% Add distortion:
xd = apply_distortion(x,d);
% Reconvert in pixels:

px2 = K_new(1,1)*xd(1,:)+ K_new(1,2)*xd(2,:)+K_new(1,3);
py2 = K_new(2,2)*xd(2,:)+K_new(2,3);


% Interpolate between the closest pixels:


% good_points = find((px_0 >= 0) & (px_0 <= (nc-2)) & (py_0 >= 0) & (py_0 <= (nr-2)));
% 
% px_0 = px_0(good_points);
% py_0 = py_0(good_points);

adjusted_corres=[px2' py2'];

end


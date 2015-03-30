function F = eightpointF(pts1, pts2, M)
%This code estimates the fundamental matrix using 8-points algorithm. 
%Inputs:
%   pts1 and pts2 are N x 2 matrices saving correspondense in two images,
%   where N is the number of correspondences.
%   M is the scaling factor for point coordinate normalization. 

%normalization
norm_pts1 = pts1 / M;
norm_pts2 = pts2 / M;

% min_{f} = ||Af||^2 by finding the eigenvector of A'A corresponding to the minimum eigenvalue
u1 = norm_pts1(:,1);
v1 = norm_pts1(:,2);
u2 = norm_pts2(:,1);
v2 = norm_pts2(:,2);
A = [u1.*u2, u1.*v2, u1, v1.*u2, v1.*v2, v1, u2, v2, ones(length(v1),1)];
[U,D,V]=svd(A);
f=V(:,9);
F=reshape(f,3,3);

% sigularize F by setting the smallest sigular value of F to zero.
[A,D,B]=svd(F);
D(3,3) = 0;
F=A*D*B';

% refine F by using local minimization
F = refineF(F,norm_pts1,norm_pts2);

% unscaling F
T=diag([1/M;1/M;1]);
F=T'*F*T;
end
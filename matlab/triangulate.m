function Ps = triangulate(M1, p1, M2, p2)
N = size(p1,1);
Ps = zeros(N,3);
opt = optimset('Algorithm', 'levenberg-marquardt', 'TolX',1e-10, 'TolFun', 1e-10, 'MaxFunEvals', 100, 'MaxIter', 100);
err = 0;
for i=1:N
    ps = [p1(i,:);p2(i,:)];
    Ms(:,:,1) = M1;
    Ms(:,:,2) = M2;
    P_init=algebraTriangulate(ps,Ms);
    %obj =  GeoErr(ps,Ms,[P_init;1]);
    %P = geoTriangulate(ps,Ms,[P_init;1], opt);
%     err = err + GeoErr(ps,Ms,P);
    %obj =  GeoErr(ps,Ms,P);
    %Ps(i,:) = P(1:3);
    Ps(i,:) = P_init(1:3);
end
end
function P = algebraTriangulate(ps,Ms)
    A=[];
    for i=1:size(ps,1)
        u=ps(i,1);
        v=ps(i,2);
        M=Ms(:,:,i);
        A=[A;u*M(3,:)-M(1,:);u*M(3,:)-M(2,:)];
    end
    U=A(:,1:3);
    b=A(:,4);
    %psudo inverse
    P=-U\b;
end

function P = geoTriangulate(ps,Ms,init, opt)
    
    %[P,obj] = fminsearch(@(P) GeoErr(ps,Ms,P),init);
    P = lsqnonlin(@(P) GeoErr(ps,Ms,P),init, [], [], opt);
    P = P./P(4);
end

function err = GeoErr(ps,Ms,P)
    err = zeros(size(ps,1),1);
    for i=1:size(ps,1)
        err(i) = sqrt((ps(i,1)-Ms(1,:,i)*P/(Ms(3,:,i)*P))^2 + (ps(i,2)-Ms(2,:,i)*P/(Ms(3,:,i)*P))^2);
    end
end

% function f = reproject(ps,Ms,P)
%     f =0;
%     for i=1:size(ps,1)
%         f = f + (ps(i,1)-Ms(1,:,i)*P/(Ms(3,:,i)*P))^2 + (ps(i,2)-Ms(2,:,i)*P/(Ms(3,:,i)*P))^2;
%     end
% end
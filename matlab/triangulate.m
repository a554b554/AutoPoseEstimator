function Ps = triangulate(M1, p1, M2, p2)
N = size(p1,1);
Ps = zeros(N,3);

err = 0;
for i=1:N
    ps = [p1(i,:);p2(i,:)];
    Ms(:,:,1) = M1;
    Ms(:,:,2) = M2;
    P_init=algebraTriangulate(ps,Ms);
    %obj =  GeoErr(ps,Ms,[P_init;1]);
%     P = geoTriangulate(ps,Ms,[P_init;1]);
%     err = err + GeoErr(ps,Ms,P);
    %obj =  GeoErr(ps,Ms,P);
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

function P = geoTriangulate(ps,Ms,init)
    [P,obj] = fminsearch(@(P) GeoErr(ps,Ms,P),init);
    P = P./P(4);
end

function err = GeoErr(ps,Ms,P)
    err =0;
    for i=1:size(ps,1)
        err = err + (ps(i,1)-Ms(1,:,i)*P/(Ms(3,:,i)*P))^2 + (ps(i,2)-Ms(2,:,i)*P/(Ms(3,:,i)*P))^2;
    end
end

% function f = reproject(ps,Ms,P)
%     f =0;
%     for i=1:size(ps,1)
%         f = f + (ps(i,1)-Ms(1,:,i)*P/(Ms(3,:,i)*P))^2 + (ps(i,2)-Ms(2,:,i)*P/(Ms(3,:,i)*P))^2;
%     end
% end
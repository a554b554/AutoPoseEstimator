function [rot,t] = decompose(E, K_right, K_left)
    [U,S,V] = svd(E);
    m = (S(1,1)+S(2,2))/2;
    E = U*[m,0,0;0,m,0;0,0,0]*V';
    [U,S,V] = svd(E);
    W = [0,-1,0;1,0,0;0,0,1];

    % Make sure we return rotation matrices with det(R) == 1
    if (det(U*W*V')<0)
        W = -W;
    end
    M_left = [K_left,zeros(3,1)];
    
    M2s = zeros(3,4,4);
    M2s(:,:,1) = [U*W*V',U(:,3)./max(abs(U(:,3)))];
    M2s(:,:,2) = [U*W*V',-U(:,3)./max(abs(U(:,3)))];
    M2s(:,:,3) = [U*W'*V',U(:,3)./max(abs(U(:,3)))];
    M2s(:,:,4) = [U*W'*V',-U(:,3)./max(abs(U(:,3)))];
    
    for i=1:4
        M_right=K_right*M_rights(:,:,i);
        P=triangulate(M_left, corres_left, M_right, corres_right);
        if isempty(find(P(:,3)<0))
            break
        end
    end
    rot = M_rights(:,1:3,i);
    t = M_rights(:,4,i);
end
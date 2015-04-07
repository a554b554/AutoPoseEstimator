function [R, T, E, P] = PosEstByEb(corres_left, corres_right, K_left, K_right)
    M = max(img_sz);
    N = size(corres_left,1);
    corres_left_norm = K_left \ [corres_left'; ones(1,N)];
    corres_right_norm = K_right \ [corres_right'; ones(1,N)];
    E = eightpointE(corres_left_norm', corres_right_norm');
    M_rights = E2Rts(E);
    M_left = [K_left,zeros(3,1)];
    for i=1:4
        M_right=K_right*M_rights(:,:,i);
        P=triangulate(M_left, corres_left, M_right, corres_right);
        if isempty(find(P(:,3)<0))
            break
        end
    end
    R = M_rights(:,1:3,i);
    T = M_rights(:,4,i);

end
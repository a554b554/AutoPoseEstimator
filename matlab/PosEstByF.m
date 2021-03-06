function [R, T, F, E, P] = PosEstByF(corres_left, corres_right, K_left, K_right, img_sz)
    M = max(img_sz);
    F = eightpointF(corres_left, corres_right, M)
    E = essentialMatrix(F, K_left, K_right);
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
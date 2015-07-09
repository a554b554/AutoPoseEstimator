function [Rs, Ts] = PosEstByEbRansac(corres_left, corres_right, K_left, K_right, ransac_num, ransac_radius, force_neg_Tx, force_max_Tx)
    % NOTE: if force_neg_Tx be true, then all the T with negative X
    % dimension (Tx) be rejected. The rational behind this is, since we know
    % the second camera must locate to the right of first camera,
    % (i.e. the first camera's center must be on the negative side of second
    % camera's X-axis), then Tx must be negative! HOWEVER, this might not
    % be always true, if first camera is facing the opposite direction!
    % NOTE: force_max_Tx be true, it forces the absolute value of x dimension in T must be
    % the largest compared to y and z in T.  
    
    N = size(corres_left,1);
    if N < 8
        error('Error: no enough correspondences!');
    end
    smp_N = 8;%max(floor(0.2 * N), 8);
    
    corres_left_norm = K_left \ [corres_left'; ones(1,N)];
    corres_right_norm = K_right \ [corres_right'; ones(1,N)];
    Rs_cand = {};
    Ts_cand = {};
    M_left = [K_left,zeros(3,1)];
    valid_idx = 1;
    for t = 1:ransac_num
        % random permutation for sampling
        rand_ind = randperm(N);
        % find the sample set indices
        smp_idx = rand_ind(1:smp_N);
        smp_pt_left = corres_left_norm(:,smp_idx);
        smp_pt_right = corres_right_norm(:,smp_idx);
        % Estimate the model
        E = eightpointE(smp_pt_left', smp_pt_right');
        M_rights = E2Rts(E);
        for i=1:4
            M_right=K_right*M_rights(:,:,i);
            P=triangulate(M_left, corres_left, M_right, corres_right);
            if isempty(find(P(:,3)<0))
                break
            end
        end
        if force_neg_Tx && M_rights(1,4,i) > 0
            continue;
        end
        if force_max_Tx
            [ig, max_idx] = max(abs(M_rights(:,4,i)));
            if max_idx ~= 1
                continue;
            end
        end
        Rs_cand{valid_idx} = M_rights(:,1:3,i);
        Ts_cand{valid_idx} = M_rights(:,4,i);
        valid_idx = valid_idx + 1;
    end
    topK = min(floor(0.2 * numel(Rs_cand)), 50);
    [Rs, Ts] = GetBestRT(Rs_cand, Ts_cand, ransac_radius, topK);
end

function [Rs, Ts] = GetBestRT(Rs_cand, Ts_cand, radius, topK)
    Rs_rod = [];
    Ts_mat = [];
    for i = 1:numel(Rs_cand)
        r = rodrigues(Rs_cand{i});
        Rs_rod(i, :) = r';
        Ts_mat(i, :) = Ts_cand{i}';
    end
    D = pdist2(Rs_rod, Rs_rod);
    nbgh_sz_list = zeros(size(D,1),1);
    
    for i = 1: size(D,1)
        nbgh_idx = find(D(i,:) < radius);
        nbgh_sz = numel(nbgh_idx);
        nbgh_sz_list(i) = nbgh_sz;
%         figure(1);
%         hold on
%         title(['R nbgh_sz = ', num2str(nbgh_sz)]);
%         scatter3(Rs_rod(:,1),Rs_rod(:,2),Rs_rod(:,3),'b');
%         scatter3(Rs_rod(nbgh_idx,1),Rs_rod(nbgh_idx,2),Rs_rod(nbgh_idx,3),'r');
%         hold off;
%         figure(2);
%         hold on
%         scatter3(Ts_mat(:,1),Ts_mat(:,2),Ts_mat(:,3),'b');
%         scatter3(Ts_mat(nbgh_idx,1),Ts_mat(nbgh_idx,2),Ts_mat(nbgh_idx,3), 'r');
%         hold off;
%         figure(1)
%         cla;
%         figure(2)
%         cla;
%         if nbgh_sz > max_nbgh
%             max_nbgh = nbgh_sz;
%             best_id = i;
%             best_nbgh_idx = nbgh_idx;
%         end
    end
    [ig, top_idx] = sort(nbgh_sz_list, 'descend');
    %r_ave = mean(Rs_rod(best_nbgh_idx, :));
    %t_ave = mean(Ts_mat(best_nbgh_idx, :));
    %R = rodrigues(r_ave);
    %T = t_ave'/max(abs(t_ave));
    Rs = Rs_cand(top_idx(1:topK));
    Ts = Ts_cand(top_idx(1:topK));
end

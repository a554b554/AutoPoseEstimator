function E = findEssentialmatrixRansac(corres_left, corres_right, K_left, K_right)
    fRANSAC = estimateFundamentalMatrix(corres_left, corres_right,'Method', 'RANSAC', 'NumTrials', 20000, 'DistanceThreshold', 0.1);
    E = K_left'*fRANSAC*K_right;
end

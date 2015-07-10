function E = findEssentialmatrixRansac(corres_left, corres_right, K_left, K_right)
    load stereoPointPairs
    fRANSAC = estimateFundamentalMatrix(corres_left, corres_right,'Method', 'Norm8Point')%, 'NumTrials', 2000, 'DistanceThreshold', 1e-4)
    E = K_left'*fRANSAC*K_right;
end

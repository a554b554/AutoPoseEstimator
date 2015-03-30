function err = RotationMatDist(R1, R2)
    err = 0;
    [h, w] = size(R1);
    for i = 1 : w
        for j = i + 1 : w
            r1_i = R1(:, i) / norm(R1(:, i));
            r2_i = R2(:, i) / norm(R2(:, i));
            r1_j = R1(:, j) / norm(R1(:, j));
            r2_j = R2(:, j) / norm(R2(:, j));
            err_i = abs(acos(r1_i' * r2_i));
            err_j = abs(acos(r1_j' * r2_j));
            err = err + err_i + err_j;
        end
    end
    err = err / (w * (w - 1) / 2);
end
function rotated = rotateimg(img, rotm, R, K, D)
    R = rotm*R;
    rotated = RectifyImage(img, R, K, D);
end
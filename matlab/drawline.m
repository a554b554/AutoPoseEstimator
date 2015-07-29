function drawline(img)
    [nr nc] = size(img);
    imshow(img);
    hold on;
    %cc = 1:50:nr;
    for i = 1:50:nr
        line([1, nc],[i, i], 'Color', [0, 1.0, 0]);
    end
    hold off;
end
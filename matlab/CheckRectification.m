function CheckRectification(result_img, fig_idx)
    if nargin == 1
        fig_idx = 1;
    end
    if ischar(result_img)
        result_img = imread(result_img);
    end
    figure(fig_idx);
    imshow(result_img);
    hold on
    [h, w] = size(result_img);
    while(1)
        [x,y,button] = ginput(1);
        if button == 3
            break;
        elseif button == 2
            clf;
            imshow(result_img);
            continue;
        end
        line([1, w],[y y], 'Color', [0, 1.0, 0]);
    end
    hold off
end
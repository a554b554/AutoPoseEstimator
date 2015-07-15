function [corres_left_filtered, corres_right_filtered] = correspondfilter(corres_left, corres_right, img_left)
    figure(100);
    imshow(img_left);
    hold on;
    plot(corres_left(:,1),corres_left(:,2),'o');
    isset = 0;
    x0 = 0;
    y0 = 0;
    rois = {};
    id = 1;
    while(1)
        [x,y,button] = ginput(1);
        if(button == 'q')
            break
        end
        if(button == 1)
            if(isset == 0)
                isset = 1;
                x0 = x;
                y0 = y;
            elseif(isset == 1)
                isset = 0;
                rect = [x0,y0,x,y];
                rectangle('position',[x0,y0,x-x0,y-y0]);
                rois{id} = rect
                id = id + 1;
            end
        end
    end
    hold off;
    corres_left_filtered = [];
    corres_right_filtered = [];
    %begin to filter
    [r h]= size(corres_left);
    for i = 1:r
        isgood = false;
        for j = 1:length(rois)
            roi = rois{j};
            if(validpoint(corres_left(i,:),roi))
                isgood = true;
                break;
            end
        end
        
        if(isgood)
            corres_left_filtered = [corres_left_filtered; corres_left(i,:)];
            corres_right_filtered = [corres_right_filtered; corres_right(i,:)];
        end
    end     
end
function CheckRectification2(result_img, fig_idx, R,T,K,D)
    
    if nargin<4
        R=[0 0 0];
        T=[0 0 0];
    end
    result_img = double(result_img);
    o = result_img;
    imshow(uint8(result_img));
    hold on;
    while(1)
        [x,y,bt]=ginput(1)
        if bt==28
            R=[R(1),R(2)-0.01,R(3)];
        elseif bt==29
            R=[R(1),R(2)+0.01,R(3)];
        elseif bt==30
            R=[R(1)+0.01,R(2),R(3)];  
        elseif bt==31
            R=[R(1)-0.01,R(2),R(3)];
        end
        result_img = RectifyImageold(o,rodrigues(R), K, D);
        imshow(uint8(result_img));
        
    end
    hold off;
end
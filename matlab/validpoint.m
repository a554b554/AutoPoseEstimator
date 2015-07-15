function ans = validpoint(pt,rect)
    x = pt(1);
    y = pt(2);
    x0 = rect(1);
    y0 = rect(2);
    x1 = rect(3);
    y1 = rect(4);
    if(x>x0&&x<x1&&y>y0&&y<y1)
        ans = true;
    else
        ans = false;
    end
end
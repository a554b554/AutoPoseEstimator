function visualize(path)
    path = 'err3.txt';
    [names, x, no,no,no,no,no,no] = textread('err3.txt', '%s %f %s %s %s %s %s %s', 100);
   % ~/Documents/data/jun18/test/all_00001_00100_left.png 2.138512  0 7.568520 0.755167 1.5124100.015736 0.069596 0.142469
   bar(x);
    
end
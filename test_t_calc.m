function test_t_calc

failure = 0;
for e = 0:8192
    t_1 = t_calc(e);
    t_2 = t_calc_1(e);
    t_3 = t_calc_optimized(e);
    
    if t_1 ~= t_2
        disp('wrong value.');
        disp(e);
        failure = 1;
        break;
    end
    
    if t_1 ~= t_3
        disp('wrong value.');
        disp(e);
        failure = 2;
        break;
    end
end

if failure == 0
  disp('test t_calc_optimized passed.');
else
  disp('test t_calc_optimized failed.');
end

end
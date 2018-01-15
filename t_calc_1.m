function t = t_calc_1(e)

if e > 8192 || e < 0
  error('e is out side of scope.');    
end

t = ceil((sqrt(1+8*e) - 1)/2);

end
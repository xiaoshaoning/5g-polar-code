function t = t_calc(e)

if e > 8192 || e < 0
  error('e is out side of scope.');    
end

for t = 0:128
    if t * (t+1)/2 >= e
        break;
    end
end

end



function t = t_calc_optimized(e)
% TS 38.211 subclause 5.4.1.3 interleaving of coded bits
% t is the smallest integer such that t*(t+1)/2 >= e

if e > 8192 || e < 0
  error('e is out side of scope.');    
end

k_list = zeros(1, 129);
for k = 0:128
    k_list(k+1) = k*(k-1)/2 + 1;
end

if e == 0
    t = 0;
else
  [~, t] = find(k_list <= e, 1, 'last');
  t = t-1;
end

end
function t = t_calc_2(e)

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
function u = multiply_by_S(v)

n = length(v);

if bitand(n, 1) == 1
    error('length of v shall be an even number');
end

u = zeros(1, n);
for index = 1:n/2
  u(2*index-1) = mod(v(2*index-1) + v(2*index), 2);
  u(2*index) = v(2*index); 
end

end
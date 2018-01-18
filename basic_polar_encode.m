function u = basic_polar_encode(u)

N = length(u);
n = log2(N);

if n ~= floor(n)
    error('wrong length of input');
end

S = kron(eye(N/2), [1, 0; 1, 1]);

for index = 1:n
%   u = multiply_by_S(shuffle(u));    
  v = shuffle(u);
  u = mod(v*S, 2);  
end

end
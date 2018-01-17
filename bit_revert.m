function result = bit_revert(x, n)

result = zeros(1, length(x));
for index = 1:length(x)
  result(index) = bitget(x(index), 1:n) * 2.^((n-1):-1:0).';
end

end
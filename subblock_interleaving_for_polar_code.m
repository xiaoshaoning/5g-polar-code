function output_bits = subblock_interleaving_for_polar_code(input_bits, N)

if length(input_bits) ~= N
    error('wrong size of the input bits.');
end

if 2^floor(log2(N)) ~= N
  eror('wrong value of N.');    
end

subblock_interleaver_pattern = [0, 1, 2, 4, ...
    3, 5, 6, 7, ...
    8, 16, 9, 17, ...
    10, 18, 11, 19, ...
    12, 20, 13, 21, ...
    14, 22, 15, 23, ...
    24, 25, 26, 28, ...
    27, 29, 30, 31];

first_row = subblock_interleaver_pattern * (N/32);

full_subblock_interleaver_pattern = zeros(N/32, 32);

for index = 0:(N/32 -1)
  full_subblock_interleaver_pattern(index+1, :) = first_row + index;
end

full_subblock_interleaver_pattern = (full_subblock_interleaver_pattern(:)).';

output_bits = input_bits(full_subblock_interleaver_pattern + 1);

end
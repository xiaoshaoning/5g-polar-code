function test_subblock_interleaving_for_polar_code

failure = 0;

for N = [32, 64, 128, 256, 512, 1024, 2048]      
    output_bits = subblock_interleaving_for_polar_code(0:(N-1), N);
    for index = 0:(N-1)
      if output_bits(index+1) ~= j_permutate(index, N)
          failure = 1;
          break;
      end
    end
end

if failure == 0
  disp('test subblocking_interleaving for polar code passed.');
else
  disp('test failed.');
end

end
function selected_bits = bit_select_for_polar_code(subblock_interleaved_bits, K, N, E)

selected_bits = zeros(1, E);

if E>=N % repetition    
  for k = 0:(E-1)
      selected_bits(k+1) = subblock_interleaved_bits(mod(k, N)+1);
  end  
else
    if K/E <= 7/16 % puncturing
      for k = 0:(E-1)
          selected_bits(k+1) = subblock_interleaved_bits(k+N-E+1);
      end
    else
      selected_bits = subblock_interleaved_bits(1:E);
    end % end of if K/E <= 7/16
end

end
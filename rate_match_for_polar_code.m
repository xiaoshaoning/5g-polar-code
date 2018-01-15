function rate_matched_bits = rate_match_for_polar_code(coded_block, K, N, E, I_BIL)
% rate matching, 3gpp TS 38.212, subclause 5.4

subblock_interleaved_bits = subblock_interleaving_for_polar_code(coded_block, N);
  
selected_bits = bit_select_for_polar_code(subblock_interleaved_bits, K, N, E);
  
rate_matched_bits = coded_bits_interleave_for_polar_code(selected_bits, E, I_BIL);

end
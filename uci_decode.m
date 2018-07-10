function rx_payload = uci_decode(encoded_uci, K, N, E, I_seg, I_BIL, q_info_list, q_pc_list, crc_length, payload_size)

% de-concatenation
if I_seg == 1
    code_block_number = 2;
    rx_rate_match_bits = cell(1, code_block_number);
    
    rx_rate_match_bits{1} = encoded_uci(1:length(encoded_uci)/2);
    rx_rate_match_bits{2} = encoded_uci((1+length(encoded_uci)/2):end);
    
else
    code_block_number = 1;
    rx_rate_match_bits{1} = encoded_uci;
    
end

rate_matching_pattern = rate_match_for_polar_code(1:N, K, N, E, I_BIL);

de_rate_matched_bits = cell(1, code_block_number);
% de-rate-match
for code_block_index = 1:code_block_number
    current_de_rx_match_bits = ones(1, N);
    current_de_rx_match_bits(rate_matching_pattern) = rx_rate_match_bits{code_block_index};
    de_rate_matched_bits{code_block_index} = current_de_rx_match_bits;
end

% polar decoding
frozen_bits_indicator = zeros(1, N);
frozen_bits_indicator(setdiff(1:N, q_info_list+1)) = 1;

q_info_list_without_pc = setdiff(q_info_list, q_pc_list);

n = log2(N);
bit_reverted_list = bit_revert(0:(N-1), n) + 1;
rx_code_block = cell(1, code_block_number);

% parameter for SCL decoding
info_pattern_indicator = zeros(1, N);
info_pattern_indicator(q_info_list_without_pc+1) = 1;
path_number = 8;
P2 = 3;

for code_block_index = 1:code_block_number
    rx_code_block_prime = polar_decode(de_rate_matched_bits{code_block_index}, frozen_bits_indicator(bit_reverted_list));        
    bit_reverted_code_block = rx_code_block_prime(bit_reverted_list);
    rx_code_block{code_block_index} = bit_reverted_code_block(sort(q_info_list_without_pc+1));
    
%     rx_code_block_tilt = polar_scl_decode(de_rate_matched_bits{code_block_index}, N, info_pattern_indicator, crc_length, path_number, P2, K);
%     
%     if isequal(rx_code_block{code_block_index}, rx_code_block_tilt)
%       disp('SC and SCL decoding get the same result.');
%     else
%       disp('SC and SCL decoding get different results.');
%     end    
    
    crc_result = crc_for_5g(rx_code_block{code_block_index}, num2str(crc_length));
    
    if isequal(crc_result, zeros(1, crc_length))
        fprintf('crc passed for the code block %d\n', code_block_index);
    else
        fprintf('crc failed for the code block %d\n', code_block_index);
    end    
end

rx_payload = de_segment_for_polar_code(rx_code_block, code_block_number, crc_length, payload_size);

end

function [code_blocks, code_block_number, K] = code_block_segment_and_crc_attach_for_polar_code(payload, I_seg, crc_length)

A = length(payload);

if crc_length == 6
    crc_type = '6';
elseif crc_length == 11
    crc_type = '11';
else
    error('wrong crc length.');
end

if A > 1706
    error('The length of payload shall not be greater than 1706.');
end

if I_seg == 1
    code_block_number = 2;
    
    code_blocks = cell(1, code_block_number);
    
    if bitand(A, 1) == 1
        A_prime = A+1;
        payload_prime = [0, payload];
    else
        A_prime = A;
        payload_prime = payload;
    end
    
    code_block_length = bitshift(A_prime, -1);
    payload_prime_first_part = payload_prime(1:code_block_length);
    payload_prime_second_part = payload_prime((code_block_length+1):end);
    
    code_blocks{1} = [payload_prime_first_part, crc_for_5g(payload_prime_first_part, crc_type)];
    code_blocks{2} = [payload_prime_second_part, crc_for_5g(payload_prime_second_part, crc_type)];
    K = length(code_blocks{1});
else
    code_block_number = 1;
    code_blocks = cell(1, code_block_number);
    code_blocks{1} = [payload, crc_for_5g(payload, crc_type)];
    K = length(code_blocks{1});
end

end
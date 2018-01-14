function uci_encode(payload, E)

payload_size = length(payload);

if payload_size >= 360 && E >= 1088
    I_seg = 1;
else
    I_seg = 0;
end

n_max = 10;
I_IL = 0;

if payload_size >= 12 && payload_size <= 19
    crc_length = 6;
    n_pc = 3;
    
    K_0 = payload_size + crc_length; % no segmentation for payload_size <= 19
    
    if E-K_0+3>192
        n_wm_pc = 1;
    elseif E-K_0+3<=192
        n_wm_pc = 0;
    end
    
elseif payload_size >= 20
    crc_length = 11;
    n_pc = 0;
    n_wm_pc = 0;
elseif payload_size <= 11
    % Reed Muller encoding
end

[code_blocks, code_block_number, K] = code_block_segment_and_crc_attach_for_polar_code(payload, I_seg, crc_length);

coded_blocks = cell(1, code_block_number);
for code_block_index = 1:code_block_number
    coded_blocks{code_block_index} = polar_coding_process(code_blocks{code_block_index}, K, E, n_max, I_IL, n_pc, n_wm_pc);
end

% rate matching, 3gpp TS 38.212, subclause 5.4

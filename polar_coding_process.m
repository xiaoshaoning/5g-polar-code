function [coded_block, N, q_info_list, q_pc_list] = polar_coding_process(code_block, K, E, n_max, I_IL, n_pc, n_wm_pc)

if E <= (9/8) * 2^(ceil(log2(E))-1) && K/E < 9/16
    n_1 = ceil(log2(E))-1;
else
    n_1 = ceil(log2(E));
end

% R_min = 1/8;

n_2 = ceil(log2(K)) + 3; % n_2 = ceil(log2(K/R_min))

n_min = 5;

n = max([min([n_1, n_2, n_max]), n_min]);

N = 2^n;

code_block_prime = interleave_in_polar_code(code_block, K, I_IL);

[q_info_list, q_pc_list, G] = polar_encoding_calculate(E, N, K, n_pc, n_wm_pc);

coded_block = polar_encoding_implement(code_block_prime, q_info_list, q_pc_list, G, N, n_pc);

end
function [q_info_list, q_pc_list, G] = polar_encoding_calculate(E, N, K, n_pc, n_wm_pc)
% n_pc: number of parity check bit

load polar_sequence

q_list = polar_sequence(polar_sequence < N);

q_info_list = info_list_calculate(E, K, n_pc, q_list, N);

n = log2(N);

G = 1;
for index = 1:n
    G = kron(G, [1 0; 1 1]);
end

row_weights = sum(G, 2);

q_info_size = length(q_info_list);

q_tilt_list = q_info_list(n_pc+1:q_info_size); % |q_info_size - n_pc| most reliable indices in q_info_list

row_weights_valid = row_weights(q_tilt_list+1);
min_row_weights = min(row_weights_valid);

if n_wm_pc == 1
    q_pc_list_part = q_info_list(1:(n_pc-1));
    
    wm_pc_index = find(row_weights_valid == min_row_weights, 1, 'last');
    wm_pc_entry = q_tilt_list(wm_pc_index);
    
    q_pc_list = [q_pc_list_part; wm_pc_entry];    
else % n_wm_pc == 0
    q_pc_list = q_info_list(1:n_pc);
end

end
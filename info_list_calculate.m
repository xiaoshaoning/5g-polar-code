function [q_info_list, q_frozen_list] = info_list_calculate(E, K, n_pc, q_list, N)

q_frozen_list_tmp = [];

if E < N
    if K/E <= 7/16 % puncture
        for n = 0:(N-E-1)
            q_frozen_list_tmp = [q_frozen_list_tmp, j_permutate(n, N)]; %#ok<AGROW>
        end
        
        if E >= 3 * N/4
            q_frozen_list_tmp = [q_frozen_list_tmp, 0:(ceil(3*N/4 - E/2) -1)];
        else
            q_frozen_list_tmp = [q_frozen_list_tmp, 0:(ceil(9*N/16 - E/4) -1)];
        end
    else % shortening
        for n = E:(N-1)
            q_frozen_list_tmp = [q_frozen_list_tmp, j_permutate(n, N)];   %#ok<AGROW>
        end
    end % end if K/E <= 7/16
end % end if E < N

q_info_list_tmp = setdiff(q_list, q_frozen_list_tmp, 'stable');

q_info_list_tmp_size = length(q_info_list_tmp);

q_info_list = q_info_list_tmp((q_info_list_tmp_size-(K+n_pc)+1):q_info_list_tmp_size);

q_frozen_list = setdiff(q_list, q_info_list, 'stable');

end
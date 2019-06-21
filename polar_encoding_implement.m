function coded_block = polar_encoding_implement(code_block_prime, q_info_list, q_pc_list, G, N, n_pc)

% generate u
u = zeros(1, N);

k = 0;

if n_pc > 0
    y_0 = 0;
    y_1 = 0;
    y_2 = 0;
    y_3 = 0;
    y_4 = 0;

    for index = 0:(N-1)
        y_t = y_0;
        y_0 = y_1;
        y_1 = y_2;
        y_2 = y_3;
        y_3 = y_4;
        y_4 = y_t;

        if ~isempty(find(q_info_list == index, 1))
            if ~isempty(find(q_pc_list == index, 1))
                u(index+1) = y_0;
            else
                u(index+1) = code_block_prime(k+1);
                k = k + 1;
                y_0 = mod(y_0+u(index+1), 2);
            end
        else
            u(index+1) = 0;
        end
    end % end for index
else
    for index = 0:(N-1)
        if ~isempty(find(q_info_list == index, 1))
            u(index+1) = code_block_prime(k+1);
            k = k+1;
        else
            u(index+1) = 0;
        end % end of if
    end % end for
end % end if n_pc > 0

% coded_block = mod(u * G, 2);
coded_block = basic_polar_encode(u);

end

function rate_matched_bits = coded_bits_interleave_for_polar_code(selected_bits, E, I_BIL)
% 3gpp TS 38.212 subclause 5.4.1.3 interleaving of coded bits

if I_BIL == 1
    
    T = t_calc_optimized(E);
    interleaving_matrix = -1 * ones(T, T);
    
    k = 0;
    for ii = 0:(T-1)
        for jj = 0:(T-1-ii)
            if k < E
                interleaving_matrix(ii+1, jj+1) = selected_bits(k+1);
            else
                interleaving_matrix(ii+1, jj+1) = -1;
            end
            k = k+1;
        end
    end
    
    k = 0;
    rate_matched_bits = -1 * ones(1, E);
    
    for jj = 0:(T-1)
        for ii = 0:(T-1-jj)
            if interleaving_matrix(ii+1, jj+1) ~= -1
                rate_matched_bits(k+1) = interleaving_matrix(ii+1, jj+1);
                k = k+1;
            end
        end
    end
else
    rate_matched_bits = selected_bits;
end

end
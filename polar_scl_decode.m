% The function polar_scl_decode is adapted from CA_polar_decoder.m and its
% author is Rob Maunder of University of Southamption.
% It is originally located at
% https://github.com/robmaunder/polar-3gpp-matlab
% There are some minor modifications made by Xiao, Shaoning. 

function a_hat = polar_scl_decode(d_tilde, N, info_bit_pattern, crc_length, L, P2, K, PC_bit_pattern, frozen_bits_indicator)

global bits
global bits_updated
global llrs
global llrs_updated

bits = zeros(N, log2(N)+1); % Initialse all bits to zero. The left-most column corresponds to the decoded information, CRC and frozen bits
bits_updated = [~info_bit_pattern',false(N,log2(N))]; % The zero values that have initialised the frozen bits are known to be correct
llrs = [zeros(N,log2(N)),d_tilde']; % Initialse the LLRs. The right-most column corresponds to the received LLRS
llrs_updated = [false(N,log2(N)),true(N,1)]; % The received LLRs have been updated.

PM = zeros(1,1,1); % Initialise the path metrics
L_prime = 1; % Initialise the list size to 1. This will grow as the decoding proceeds

PC_circular_buffer_length = 5;
y = zeros(1, PC_circular_buffer_length);

P = crc_length-1;

if crc_length == 6
  crc_polynomial_pattern = [1 1 0 0 0 0 1]; 
else
  crc_polynomial_pattern = [1 1 1 0 0 0 1 0 0 0 0 1];
end

% Consider each bit in turn
for i = 1:N
    
    % Rotate the PC bit generators
    y = [y(1, 2:end, :), y(1, 1, :)];
    
    % Make recursive function calls to perform the XOR, g and f functions
    % necessary to obtain the corresponding LLR
    update_llr(i,1);

    if frozen_bits_indicator(i) == 1 % Frozen bit        
        PM = phi(PM, llrs(i,1,:), 0);
    elseif PC_bit_pattern(i) == 1 % PC bit    
        bits(i, 1, :) = y(1, 1, :);
        PM = phi(PM, llrs(i, 1, :), bits(i, 1, :));
        bits_updated(i, 1) = true;
    else % Information or CRC bit
        % Double the list size, using 0-valued bits for the first half and 1-valued bits for the other half
        PM = cat(3,phi(PM, llrs(i,1,:), 0), phi(PM, llrs(i,1,:), 1));
        llrs = cat(3,llrs,llrs);
        bits = cat(3,bits,bits);
        bits(i,1,1:L_prime) = 0;
        bits(i,1,L_prime+1:2*L_prime) = 1;
        bits_updated(i,1) = true;
        
        % Update the PC bit generators
        y = cat(3, y, y);
        y(1, 1, :) = xor(y(1, 1, :), bits(i, 1, :));
        
        % If the list size has grown above L, then we need to find and keep only the best L entries in the list
        L_prime = size(bits,3);        
        if L_prime > L
            [~,max_indices] = sort(PM,3);
            PM = PM(:,:,max_indices(1:L));
            bits = bits(:,:,max_indices(1:L));
            llrs = llrs(:,:,max_indices(1:L));
            y = y(:, :, max_indices(1:L));
            L_prime = L;
        end
    end
end

% % Information bit extraction

% If the CRC doesn't pass then return an empty vector.
a_hat = [];

% We use the list entry with a passing CRC that has the best metric. But we
% only consider the best min(L,2^P2) entries in the list, to avoid
% degrading the CRC's error detection capability.
[~,max_indices] = sort(PM,3);
for list_index = 1:min(L,2^P2)
    % Consider the next best list entry.
    u_hat = bits(:,1,max_indices(list_index))';
    
    % Extract the information bits from the output of the polar decoder 
    % kernal.
    b_hat = u_hat(info_bit_pattern == 1);
    
%     a_hat = b_hat;
%     % Check the CRC.
    G_P = get_crc_generator_matrix(K,crc_polynomial_pattern);    
    if isequal(mod(b_hat*G_P,2), zeros(1,P+1))
        % If it passes, remove the CRC and output the information bits.
        a_hat = b_hat;
        return;
    end
end

end
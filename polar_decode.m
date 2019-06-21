function [u, v] = polar_decode(y, frozen_bits_indicator)

N = length(y);

if N == 2

    L_u_1 = f(y(1), y(2));

    u = zeros(1, 2);
    if frozen_bits_indicator(1) == 1
        u(1) = 0;
    elseif L_u_1 >= 0
        u(1) = 0;
    else
        u(1) = 1;
    end

    L_u_2 = g(y(1), y(2), u(1));

    if frozen_bits_indicator(2) == 1
        u(2) = 0;
    elseif L_u_2 >= 0
        u(2) = 0;
    else
        u(2) = 1;
    end

    v = zeros(1, 2);
    v(1) = bitxor(u(1), u(2));
    v(2) = u(2);

else

    L_w_odd = zeros(1, N/2);
    for index = 1:(N/2)
        L_w_odd(index) = f(y(2*index-1), y(2*index));
    end

    frozen_bits_indicator_1 = frozen_bits_indicator(1:(N/2));

    [u_1, v_1] = polar_decode(L_w_odd, frozen_bits_indicator_1);

    L_w_even = zeros(1, N/2);
    for index = 1:(N/2)
        L_w_even(index) = g(y(2*index-1), y(2*index), v_1(index));
    end

    frozen_bits_indicator_2 = frozen_bits_indicator((N/2 +1):N);

    [u_2, v_2] = polar_decode(L_w_even, frozen_bits_indicator_2);

    u = [u_1, u_2];

    v = zeros(1, N);
    for index = 1:(N/2)
        v(2*index-1) = bitxor(v_1(index), v_2(index));
        v(2*index) = v_2(index);
    end

end

end

function v_shuffled = shuffle(v)

n = length(v);

if bitand(n, 1) == 1
    error('length of v shall be an even number');
end

v_prime = [v(1:n/2); v(n/2+1:n)];

v_shuffled = (v_prime(:)).';

end
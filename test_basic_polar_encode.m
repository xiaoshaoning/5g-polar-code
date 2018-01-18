function test_basic_polar_encode

N = 16;

n = log2(N);

u = randi([0, 1], 1, N);

G = 1;
for index = 1:n
    G = kron(G, [1 0; 1 1]);
end

coded_block_1 = mod(u * G, 2);
coded_block_2 = basic_polar_encode(u);

if isequal(coded_block_1, coded_block_2)
    disp('test passed.');
else
    disp('test failed.');
end

end

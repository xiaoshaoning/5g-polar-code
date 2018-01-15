function test_uci_encode

payload_size = 360; 

payload = randi([0, 1], 1, payload_size);

E = 1088;

I_BIL = 1;

uci_encode(payload, E, I_BIL);

end
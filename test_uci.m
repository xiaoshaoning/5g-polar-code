function test_uci

rng('default')

payload_size = 19; 

payload = randi([0, 1], 1, payload_size);

E = 216;

I_BIL = 1;

[encoded_uci, K, N, I_seg, q_info_list, q_pc_list, crc_length] = uci_encode(payload, E, I_BIL);

rx_encoded_uci = 1-2*encoded_uci;

rx_payload = uci_decode(rx_encoded_uci, K, N, E, I_seg, I_BIL, q_info_list, q_pc_list, crc_length, payload_size);

if isequal(payload, rx_payload)
  disp('test uci passed.');
else
  disp('test uci failed.');
end

end
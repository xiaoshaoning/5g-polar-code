function rx_uci = de_segment_for_polar_code(rx_code_block, code_block_number, crc_length, payload_size)

if code_block_number == 1
    rx_uci_with_crc = rx_code_block{1};
    rx_uci = rx_uci_with_crc(1:end-crc_length);
elseif code_block_number == 2
      
    rx_uci_part_1_with_crc = rx_code_block{1};
    rx_uci_part_2_with_crc = rx_code_block{2};
      
    if bitand(payload_size, 1) == 0  
      rx_uci_part_1 = rx_uci_part_1_with_crc(1:end-crc_length);     
      rx_uci_part_2 = rx_uci_part_2_with_crc(1:end-crc_length);
      
      rx_uci = [rx_uci_part_1, rx_uci_part_2];
    else
      rx_uci_part_1 = rx_uci_part_1_with_crc(2:end-crc_length);     
      rx_uci_part_2 = rx_uci_part_2_with_crc(1:end-crc_length);
      
      rx_uci = [rx_uci_part_1, rx_uci_part_2];        
    end
end
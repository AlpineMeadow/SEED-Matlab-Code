function [crc_out, crc_out_msb,crc_out_lsb]=crcCCIT_16(data,crc_in)
%Calculates the CRC/CCIT 16 for data
temp_crc = crc_in;
input = bitand(data,2^8-1);

% temp_crc = ((temp_crc<<8)+(temp_crc>>8)^(input);
a1 = bitand(bitshift(temp_crc,8),2^16-1);
a2 = bitshift(temp_crc,-8);
a3 = a1+a2;
temp_crc = bitxor(a3,input);

% temp_crc ^=(temp_crc & 0x00FF)>>4;
a1 = bitand(temp_crc,255);
a2 = bitshift(a1,-4);
temp_crc = bitxor(a2,temp_crc);

% temp_crc ^=((((temp_crc &0x00FF)<<8)+((temp_crc & 0c00FF) >>8))<<4)^((temp_crc & 0x00FF)<<5);
a1=bitand(temp_crc,255);
a2=bitand(bitshift(a1,8),2^16-1);
a3=bitshift(a1,-8);
a4=a3+a2; 
a2=bitand(bitshift(a4,4),2^16-1);
a3=bitand(bitshift(a1,5),2^16-1);
a1 = bitxor(a2,a3);
temp_crc = bitxor(temp_crc,a1);

crc_out = temp_crc;
crc_out_msb = bitshift(temp_crc,-8);
crc_out_lsb = bitand(temp_crc,255);
end

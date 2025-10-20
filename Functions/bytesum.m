function [sumbytes] = bytesum(inputarray, littleendian)
% BYTESUM Sums a cell of bytes
%   inputarray is an array of N bytes (each element value 0-255)
%   littleendian = 0 (big endian) or 1 (little endian)
%   sumbytes returns an unsigned integer of 8*N bits
%
%   Example usage
%   >> bytesum([1,2],0)
%   ans = 258
%   >> bytesum([1,2],1)
%   ans = 513

len = length(inputarray);
if len>4
    inputarray = uint64(inputarray);
    sumbytes = uint64(0);
else
    inputarray = uint32(inputarray);
    sumbytes = uint32(0); 
end
if littleendian
    inputarray = fliplr(inputarray);
end
for i=1:len
    sumbytes = sumbytes + inputarray(i) * 256^(len-i);
end

end


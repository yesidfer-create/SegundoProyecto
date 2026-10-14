function g = bin_a_gray(b)
% BIN_A_GRAY  Convierte índices binarios a índices en código Gray.
g = bitxor(b, bitshift(b, -1));
end
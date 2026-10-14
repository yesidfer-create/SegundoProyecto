function [simbolos, bits_tx, k] = mapeo_psk(M, N)
% MAPEO_PSK  Genera bits aleatorios y los mapea a símbolos M-PSK.
%
%   M:        orden (potencia de 2: 2, 4, 8, 16...)
%   N:        número de símbolos a generar
%
%   simbolos: vector columna N x 1 con los símbolos (energía unitaria)
%   bits_tx:  vector columna con los bits transmitidos (k*N bits)
%   k:        bits por símbolo = log2(M)

k = log2(M);

% Generar bits
total_bits = k * N;
bits_tx = randi([0 1], total_bits, 1);

% Agrupar en filas de k bits
bits_mat = reshape(bits_tx, k, N)';

% Convertir a índices 0..M-1
idx = bits_a_dec(bits_mat);

% Mapeo PSK: fase equiespaciada
fase = 2*pi * idx / M;
simbolos = exp(1j * fase);
end
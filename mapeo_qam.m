function [simbolos, bits_tx, k] = mapeo_qam(M, N)
% MAPEO_QAM  Genera bits aleatorios y los mapea a símbolos M-QAM.
%
%   M:        orden de modulación (debe ser potencia de 4: 4, 16, 64, 256...)
%   N:        número de símbolos a generar
%
%   simbolos: vector columna N x 1 con los símbolos complejos (energía unitaria)
%   bits_tx:  vector columna con los bits transmitidos (k*N bits)
%   k:        bits por símbolo = log2(M)

% --- 1. Validar entrada ---
k = log2(M);
if mod(k, 2) ~= 0 || k < 2
    error('M debe ser potencia de 4 (4, 16, 64, 256...)');
end

% --- 2. Generar bits aleatorios ---
total_bits = k * N;
bits_tx = randi([0 1], total_bits, 1);

% --- 3. Agrupar bits en filas de k bits ---
% reshape llena por columnas, así que transponemos después
bits_mat = reshape(bits_tx, k, N)';    % N x k

% --- 4. Separar en rama I (primeros k/2 bits) y rama Q (últimos k/2) ---
bits_I = bits_mat(:, 1:k/2);
bits_Q = bits_mat(:, k/2+1:end);

% --- 5. Convertir cada grupo a índice decimal ---
idx_I = bits_a_dec(bits_I);    % índices de 0 a sqrt(M)-1
idx_Q = bits_a_dec(bits_Q);

% --- 6. Mapear índices a niveles PAM ---
L = sqrt(M);                       % niveles por rama
niveles = -(L-1) : 2 : (L-1);      % ej. L=4 → [-3 -1 1 3]
I = niveles(idx_I + 1).';          % +1 porque MATLAB indexa desde 1
Q = niveles(idx_Q + 1).';

% --- 7. Formar símbolos complejos y normalizar energía ---
E_avg = mean(niveles.^2);          % energía promedio por rama
simbolos = (I + 1j*Q) / sqrt(2 * E_avg);
end
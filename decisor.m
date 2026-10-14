function [bits_rx, idx_rx] = decisor(muestras, C, k)
% DECISOR  Decide qué símbolo se recibió y devuelve los bits estimados.
%
%   muestras: vector columna con las muestras recibidas (con ruido)
%   C:        vector con la constelación de referencia (de constelacion.m)
%   k:        bits por símbolo = log2(M)
%
%   bits_rx:  vector columna con los bits estimados
%   idx_rx:   vector columna con los índices decididos (0 a M-1)

% Asegurar vectores columna
muestras = muestras(:);
C = C(:);

% Dimensiones
N = length(muestras);
M = length(C);

% --- 1. Calcular distancia a cada símbolo de la constelación ---
% dist(n, m) = |muestra(n) - C(m)|^2
dist = zeros(N, M);
for m = 1:M
    dist(:, m) = abs(muestras - C(m)).^2;
end

% --- 2. Encontrar el índice más cercano para cada muestra ---
[~, idx_rx] = min(dist, [], 2);   % devuelve índices 1..M
idx_rx = idx_rx - 1;              % convertir a 0..M-1

% --- 3. Convertir índices a bits ---
bits_mat = dec_a_bits(idx_rx, k);   % matriz N x k
bits_rx = reshape(bits_mat.', [], 1);   % vector columna
end
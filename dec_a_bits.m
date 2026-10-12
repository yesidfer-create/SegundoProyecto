function bits = dec_a_bits(d, k)
% DEC_A_BITS  Convierte números decimales a su representación binaria.
%
%   d:    vector de enteros (cada uno entre 0 y 2^k - 1)
%   k:    número de bits por símbolo
%   bits: matriz de tamaño N x k  (N = length(d)), cada fila son k bits
%
%   Ejemplo:
%       d = [11; 2; 15];
%       bits = dec_a_bits(d, 4);
%       % bits = [1 0 1 1;
%       %         0 0 1 0;
%       %         1 1 1 1]

% Asegurar que d sea vector columna
d = d(:);

% Cuántos números hay
N = length(d);

% Preasignar la matriz de bits
bits = zeros(N, k);

% Extraer bit por bit (del más significativo al menos significativo)
for i = 1:k
    % Desplazar a la derecha y quedarse con el bit menos significativo
    bits(:, i) = bitand(bitshift(d, -(k-i)), 1);
end
end
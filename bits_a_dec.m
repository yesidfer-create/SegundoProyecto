function d = bits_a_dec(bits)
% BITS_A_DEC  Convierte grupos de bits a su valor decimal.
%
%   bits: matriz de tamaño N x k  (N filas, cada una con k bits)
%   d:    vector columna de tamaño N x 1 con el valor decimal de cada fila
%
%   Ejemplo:
%       bits = [1 0 1 1;   % → 11
%               0 0 1 0;   % →  2
%               1 1 1 1];  % → 15
%       d = bits_a_dec(bits)   % d = [11; 2; 15]

% Cuántos bits por fila
k = size(bits, 2);

% Pesos binarios: el primer bit pesa 2^(k-1), el último pesa 2^0
pesos = 2.^(k-1:-1:0);     % Ej. para k=4: [8 4 2 1]

% Producto matricial → suma ponderada de cada fila
d = bits * pesos';         % Resultado: vector columna N x 1
end
function x_up = mi_upsample(x, L)
% MI_UPSAMPLE  Inserta L-1 ceros entre cada muestra de x.
%
%   x:    vector de entrada (columna)
%   L:    factor de sobremuestreo (sps = samples per symbol)
%
%   x_up: vector columna con longitud length(x)*L
%
%   Ejemplo:
%       x = [1; 2; 3];
%       x_up = mi_upsample(x, 4);
%       % x_up = [1; 0; 0; 0; 2; 0; 0; 0; 3; 0; 0; 0]

% Asegurar que x sea columna
x = x(:);

% Crear vector de ceros con el tamaño final
x_up = zeros(length(x) * L, 1);

% Colocar los valores de x en las posiciones 1, L+1, 2L+1, ...
x_up(1:L:end) = x;
end
function C = constelacion(M, tipo)
% CONSTELACION  Devuelve todos los símbolos ideales de una constelación.
%
%   M:     orden de modulación (potencia de 2; para QAM, potencia de 4)
%   tipo:  'QAM', 'PAM' o 'PSK' (string)
%
%   C:     vector columna con los M símbolos complejos, ordenados por índice
%          (es decir, C(1) corresponde al índice 0, C(2) al índice 1, etc.)
%
%   La normalización es la misma que en las funciones de mapeo para que
%   las distancias en el decisor tengan sentido físico.

tipo = upper(tipo);

switch tipo
    case 'PAM'
        % Niveles equiespaciados (1 dimensión)
        niveles = -(M-1) : 2 : (M-1);
        E_avg = mean(niveles.^2);
        C = (niveles / sqrt(E_avg)).';

    case 'PSK'
        % Fases equiespaciadas sobre el círculo unitario
        idx = 0:M-1;
        C = exp(1j * 2*pi*idx / M).';

    case 'QAM'
        % Cuadrícula L×L (L = sqrt(M))
        L = sqrt(M);
        if mod(L, 1) ~= 0
            error('Para QAM, M debe ser potencia de 4 (4, 16, 64, 256...)');
        end
        niveles = -(L-1) : 2 : (L-1);
        E_avg = mean(niveles.^2);

        % Generar todas las combinaciones (I, Q)
        [I_grid, Q_grid] = meshgrid(niveles, niveles);
        C = (I_grid(:) + 1j*Q_grid(:)) / sqrt(2 * E_avg);

    otherwise
        error('Tipo de modulación no reconocido: %s', tipo);
end
end
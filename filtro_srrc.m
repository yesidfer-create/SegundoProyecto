function h = filtro_srrc(beta, span, sps)
% FILTRO_SRRC  Genera la respuesta al impulso de un filtro SRRC.
%
%   beta: factor de roll-off (0 <= beta <= 1)
%   span: duración del filtro en símbolos (típico: 6 u 8)
%   sps:  muestras por símbolo (típico: 4, 8, 16)
%
%   h:    vector columna con las muestras del filtro (normalizado, energía 1)

% --- 1. Validar entrada ---
if beta < 0 || beta > 1
    error('beta debe estar entre 0 y 1');
end

% --- 2. Construir el eje temporal ---
N = span * sps;                        % número total de muestras
t = (-N/2 : N/2)' / sps;               % tiempo normalizado por Ts

% --- 3. Calcular h(t) muestra por muestra ---
h = zeros(size(t));

for i = 1:length(t)
    ti = t(i);

    if abs(ti) < 1e-8
        % Caso t = 0 (evita división por cero)
        h(i) = 1 - beta + 4*beta/pi;

    elseif beta > 0 && abs(abs(ti) - 1/(4*beta)) < 1e-6
        % Caso t = ±1/(4β) (evita división por cero en el denominador)
        % CORREGIDO: signo + en el término del coseno
        h(i) = beta/sqrt(2) * ( (1 + 2/pi)*sin(pi/(4*beta)) + ...
            (1 - 2/pi)*cos(pi/(4*beta)) );
    else
        % Caso general
        num = sin(pi*ti*(1-beta)) + 4*beta*ti*cos(pi*ti*(1+beta));
        den = pi*ti*(1 - (4*beta*ti)^2);
        h(i) = num / den;
    end
end

% --- 4. Normalizar energía ---
h = h / sqrt(sum(h.^2));
end
function y = canal_awgn(x, EbNo_dB, k)
% CANAL_AWGN  Agrega ruido blanco gaussiano a la señal.
%   Si x es real (pasa banda), agrega ruido real.
%   Si x es compleja (banda base), agrega ruido complejo.

EbNo_lin = 10^(EbNo_dB/10);
EsNo_lin = EbNo_lin * k;
N0 = 1 / EsNo_lin;

if isreal(x)
    % Ruido real para pasa banda. 
    % Al modular con coseno, la potencia de la señal real es la mitad (1/2),
    % por lo que la varianza del ruido debe ajustarse a N0/2.
    ruido = sqrt(N0/2) * randn(size(x)); 
else
    % Ruido complejo para banda base
    ruido = sqrt(N0/2) * (randn(size(x)) + 1j*randn(size(x)));
end

y = x + ruido;
end
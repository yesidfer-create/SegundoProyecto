function y = canal_awgn(x, EbNo_dB, k)
% CANAL_AWGN  Agrega ruido blanco gaussiano a la señal x.
%
%   x:        señal de entrada (real o compleja)
%   EbNo_dB:  relación Eb/N0 en dB
%   k:        bits por símbolo (log2(M))
%
%   y:        señal recibida = x + ruido
%
%   Asume que x tiene energía/potencia unitaria (normalizada).

% Convertir Eb/N0 de dB a lineal
EbNo_lin = 10^(EbNo_dB/10);

% Relación Es/N0 (energía por símbolo / densidad de ruido)
EsNo_lin = EbNo_lin * k;

% Densidad espectral de ruido (para señal con potencia 1)
N0 = 1 / EsNo_lin;

% Generar ruido complejo con varianza N0/2 por componente
ruido = sqrt(N0/2) * (randn(size(x)) + 1j*randn(size(x)));

% Sumar a la señal
y = x + ruido;
end
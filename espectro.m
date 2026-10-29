%% espectro.m — Espectro en banda base y pasa banda (Sin Toolbox)
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 16;
tipo    = 'QAM';
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 5000;
EbNo_dB = 15;
fc      = 0.15;

%% ============ MAPEO Y TX ============
switch upper(tipo)
    case 'PAM', [simbolos, ~, k] = mapeo_pam(M, N);
    case 'QAM', [simbolos, ~, k] = mapeo_qam(M, N);
    case 'PSK', [simbolos, ~, k] = mapeo_psk(M, N);
end

h = filtro_srrc(beta, span, sps);
sen_bb = conv(mi_upsample(simbolos, sps), h, 'full');

%% ============ MODULACIÓN PASA BANDA (CORREGIDA) ============
n = (0:length(sen_bb)-1)';
% Modulación correcta I/Q: I*cos - Q*sin
sen_pb = real(sen_bb .* exp(1j*2*pi*fc*n)); 

%% ============ CANAL AWGN EN PASA BANDA ============
% Para que el gráfico sea realmente "Rx", agregamos ruido a la señal pasa banda.
EsNo_lin = 10^(EbNo_dB/10) * k;
N0 = 1 / EsNo_lin;
ruido_pb = sqrt(N0/4) * randn(size(sen_pb)); % Ruido real (varianza N0/2 en pasabanda)
sen_pb_rx = sen_pb + ruido_pb;

%% ============ CÁLCULO DE PSD MANUAL (Sin Toolbox) ============
N_fft = 4096;
L = length(sen_bb);

% Ventana de Hann manual
win = 0.5 * (1 - cos(2*pi*(0:L-1)'/(L-1)));

% FFT banda base
X_bb = fftshift(fft(sen_bb .* win, N_fft));
PSD_bb = abs(X_bb).^2 / (N_fft * sum(win.^2));
PSD_bb_dB = 10*log10(PSD_bb / max(PSD_bb));
f_bb = (-N_fft/2 : N_fft/2-1) / N_fft;

% FFT pasa banda
X_pb = fftshift(fft(sen_pb_rx .* win, N_fft));
PSD_pb = abs(X_pb).^2 / (N_fft * sum(win.^2));
PSD_pb_dB = 10*log10(PSD_pb / max(PSD_pb));
f_pb = (-N_fft/2 : N_fft/2-1) / N_fft;

%% ============ GRÁFICAS ============
figure('Position', [200 100 1000 450]);

subplot(1, 2, 1);
plot(f_bb, PSD_bb_dB, 'b', 'LineWidth', 1.2); grid on;
xlabel('Frecuencia normalizada'); ylabel('PSD (dB)');
title('Espectro en banda base (Tx)');
xlim([-0.5 0.5]); ylim([-80 5]);

subplot(1, 2, 2);
plot(f_pb, PSD_pb_dB, 'r', 'LineWidth', 1.2); grid on;
xlabel('Frecuencia normalizada'); ylabel('PSD (dB)');
title(sprintf('Espectro en pasa banda (Rx, f_c = %.2f)', fc));
xlim([-0.5 0.5]); ylim([-80 5]);
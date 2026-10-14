%% espectro.m — Espectro en banda base y pasa banda
% Calcula y grafica la densidad espectral de potencia (PSD) de:
%   1) La señal en banda base (transmisión)
%   2) La señal en pasa banda (recepción, modulada)
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 16;         % Orden de modulación
tipo    = 'QAM';
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 5000;
EbNo_dB = 15;         % Alto para que la señal se vea limpia
fc      = 0.15;       % Frecuencia portadora (normalizada, ciclos/muestra)

%% ============ FILTRO ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

%% ============ MAPEO ============
switch upper(tipo)
    case 'PAM', [simbolos, ~, k] = mapeo_pam(M, N);
    case 'QAM', [simbolos, ~, k] = mapeo_qam(M, N);
    case 'PSK', [simbolos, ~, k] = mapeo_psk(M, N);
end

%% ============ SEÑAL EN BANDA BASE ============
simb_up = mi_upsample(simbolos, sps);
sen_bb  = conv(simb_up, h, 'full');       % Banda base (compleja)

%% ============ MODULACIÓN A PASA BANDA ============
% Tomamos la parte real de la banda base y la multiplicamos por cos(2π·fc·t)
% (en la práctica sería Re{s(t)·e^(j2π·fc·t)} )
n    = (0:length(sen_bb)-1)';
port = cos(2*pi*fc*n);
sen_pb = real(sen_bb) .* port;            % Pasa banda (real)

%% ============ CÁLCULO DE LA PSD ============
% Método: FFT del módulo al cuadrado (periodograma) con ventana de Hann
Nfft = 4096;

% --- PSD banda base ---
ventana = hann(length(sen_bb));
[PSD_bb, f_bb] = periodogram(sen_bb, ventana, Nfft, 1, 'centered');
PSD_bb_dB = 10*log10(PSD_bb / max(PSD_bb));   % Normalizado a 0 dB

% --- PSD pasa banda ---
ventana2 = hann(length(sen_pb));
[PSD_pb, f_pb] = periodogram(sen_pb, ventana2, Nfft, 1, 'centered');
PSD_pb_dB = 10*log10(PSD_pb / max(PSD_pb));

%% ============ GRÁFICAS ============
figure('Name', 'Espectro — banda base y pasa banda', ...
    'Position', [200 100 1100 500]);

% --- Banda base ---
subplot(1, 2, 1);
plot(f_bb, PSD_bb_dB, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Frecuencia normalizada (ciclos/muestra)', 'FontSize', 11);
ylabel('PSD (dB, normalizada)', 'FontSize', 11);
title('Espectro en banda base (Tx)', 'FontSize', 12);
xlim([-0.5 0.5]);
ylim([-80 5]);
xline(0.5*(1+beta)/sps, 'r--', '\alpha');
xline(-0.5*(1+beta)/sps, 'r--', '-\alpha');

% --- Pasa banda ---
subplot(1, 2, 2);
plot(f_pb, PSD_pb_dB, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frecuencia normalizada (ciclos/muestra)', 'FontSize', 11);
ylabel('PSD (dB, normalizada)', 'FontSize', 11);
title(sprintf('Espectro en pasa banda (Rx, f_c = %.2f)', fc), 'FontSize', 12);
xlim([-0.5 0.5]);
ylim([-80 5]);
xline(fc, 'k--', 'f_c');
xline(-fc, 'k--', '-f_c');

sgtitle(sprintf('%d-%s (\\beta = %.2f, sps = %d)', M, tipo, beta, sps), ...
    'FontSize', 13, 'FontWeight', 'bold');
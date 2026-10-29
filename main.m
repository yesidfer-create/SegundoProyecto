%% main.m — Sistema completo de comunicaciones digitales (Pasa Banda Real)
clear; clc; close all;
rng(42);   % Semilla fija para reproducibilidad

%% ============ PARÁMETROS ============
M       = 16;       % Orden de modulación
tipo    = 'QAM';    % 'PAM', 'QAM' o 'PSK'
beta    = 0.35;     % Factor de roll-off
span    = 6;        % Duración del filtro SRRC (en símbolos)
sps     = 8;        % Muestras por símbolo
N       = 5000;     % Número de símbolos
EbNo_dB = 10;       % Relación Eb/N0 (dB)
fc      = 0.15;     % Frecuencia portadora normalizada (ciclos/muestra)

%% ============ 1. MAPEO (Banda Base) ============
switch upper(tipo)
    case 'PAM', [simbolos, bits_tx, k] = mapeo_pam(M, N);
    case 'QAM', [simbolos, bits_tx, k] = mapeo_qam(M, N);
    case 'PSK', [simbolos, bits_tx, k] = mapeo_psk(M, N);
    otherwise, error('Tipo no reconocido');
end

fprintf('===========================================\n');
fprintf('  Sistema Real (Pasa Banda) %d-%s\n', M, tipo);
fprintf('===========================================\n');
fprintf('  Bits por símbolo:  %d\n', k);
fprintf('  Total bits:        %d\n', length(bits_tx));
fprintf('  Eb/N0:             %d dB\n', EbNo_dB);

%% ============ 2. TRANSMISOR ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

% Conformación de pulsos en banda base
simbolos_up = mi_upsample(simbolos, sps);
sen_bb_tx = conv(simbolos_up, h, 'full');

% --- MODULACIÓN A PASA BANDA ---
n = (0:length(sen_bb_tx)-1)';
% Tomamos la parte real para generar la onda física
sen_pb_tx = real(sen_bb_tx .* exp(1j*2*pi*fc*n));

% -- Modulación a Pasa Banda --
n_pb = (0:length(sen_tx)-1)';
sen_pb_tx = real(sen_tx .* exp(1j*2*pi*fc*n_pb));

% -- Canal AWGN (Ruido real) --
sen_pb_rx = canal_awgn(sen_pb_tx, EbNo_dB, k);

% Demodulación I/Q (Receptor Físico)
I_rx = 2 * sen_pb_rx .* cos(2*pi*fc*n);
Q_rx = -2 * sen_pb_rx .* sin(2*pi*fc*n);
sen_bb_rx = I_rx + 1j*Q_rx;

% --- FILTRO PASABAJOS EXTRA (Anti-2fc) ---
% Un promediado de sps muestras elimina la alta frecuencia
sen_bb_rx = filter(ones(1, sps)/sps, 1, sen_bb_rx);

% Filtro Rx (SRRC) y Muestreo
sen_fil = conv(sen_bb_rx, h, 'full');
% Ajustamos el retardo por el filtro extra (aprox sps/2)
muestras = sen_fil(retardo+1 : sps : retardo + N*sps);

%% ============ 4. RECEPTOR ============
% --- DEMODULACIÓN A BANDA BASE ---
% Multiplicamos por la portadora local (sincronía perfecta)
sen_bb_rx = sen_pb_rx .* exp(-1j*2*pi*fc*n);

% --- FILTRO RECEPTOR (Matched Filter) ---
% El filtro SRRC también actúa como pasabajos eliminando la portadora
sen_filtrada = conv(sen_bb_rx, h, 'full');

% --- MUESTREO ---
idx_muestreo = retardo + 1 : sps : retardo + N*sps;
muestras = sen_filtrada(idx_muestreo);

%% ============ 5. DECISIÓN Y BER ============
C = constelacion(M, tipo);
[bits_rx, ~] = decisor(muestras, C, k);

num_errores = sum(bits_tx ~= bits_rx);
BER = num_errores / length(bits_tx);

fprintf('\n========== RESULTADOS ==========\n');
fprintf('  Errores:    %d / %d\n', num_errores, length(bits_tx));
fprintf('  BER:        %.4e\n', BER);
fprintf('================================\n');

%% ============ 6. GRÁFICAS ============
% 1. Constelación Rx
figure('Name', 'Constelación Rx', 'Position', [100 100 500 500]);
plot(real(muestras), imag(muestras), 'bo', 'MarkerSize', 3);
hold on; plot(real(C), imag(C), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
grid on; axis equal; title(sprintf('Constelación Rx %d-%s (Real)', M, tipo));

% 2. Diagrama del ojo (Señal Filtrada en Rx)
figure('Name', 'Diagrama del ojo', 'Position', [650 100 500 500]);
sen_ojo = sen_filtrada(retardo+1 : end-retardo);
L = 2*sps;
num_seg = min(floor((length(sen_ojo) - L)/sps), 400);
hold on;
for i = 1:num_seg
    plot((0:L-1)/sps, real(sen_ojo((i-1)*sps+1 : (i-1)*sps+L)), 'Color', [0.6 0.6 0.9]);
end
xline(1, 'r--', 'LineWidth', 2); grid on;
title(sprintf('Diagrama del ojo (%.0f dB)', EbNo_dB)); xlim([0 2]);

% 3. Espectro Tx y Rx (Opcional, para confirmar)
figure('Name', 'Señales en el tiempo', 'Position', [100 650 800 300]);
subplot(2,1,1); plot(real(sen_pb_tx(1:200)), 'b'); title('Señal Tx (Pasa Banda)');
subplot(2,1,2); plot(real(sen_pb_rx(1:200)), 'r'); title('Señal Rx (Pasa Banda con ruido)');
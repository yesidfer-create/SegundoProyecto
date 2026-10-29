%% metricas.m — Cálculo de métricas del sistema (RF4)
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 16;
tipo    = 'QAM';
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 10000;
EbNo_dB = 15;      

%% ============ MAPEO ============
switch upper(tipo)
    case 'PAM', [simbolos, ~, k] = mapeo_pam(M, N);
    case 'QAM', [simbolos, ~, k] = mapeo_qam(M, N);
    case 'PSK', [simbolos, ~, k] = mapeo_psk(M, N);
end

%% ============ TRANSMISIÓN ============
h = filtro_srrc(beta, span, sps);
simb_up = mi_upsample(simbolos, sps);
sen_bb  = conv(simb_up, h, 'full');       % banda base compleja

%% ============ MODULACIÓN A PASA BANDA ============
fc  = 0.15;
n   = (0:length(sen_bb)-1)';
% CORREGIDO: Se usa la señal compleja completa, no solo la parte real
sen_pb = real(sen_bb .* exp(1j*2*pi*fc*n));

%% ============ CÁLCULO DE MÉTRICAS ============
eta = k / (1 + beta);
Es = mean(abs(simbolos).^2);
Rs = 1;
BW = Rs * (1 + beta);
P_pb = mean(abs(sen_pb).^2);
P_bb = mean(abs(sen_bb).^2);

%% ============ MOSTRAR RESULTADOS ============
fprintf('\n============================================\n');
fprintf('  MÉTRICAS — %d-%s\n', M, tipo);
fprintf('============================================\n');
fprintf('  a) Eficiencia espectral:  %.4f  bits/s/Hz\n', eta);
fprintf('  b) Energía de símbolo:    %.4f  (normalizada)\n', Es);
fprintf('  c) Ancho de banda:        %.4f  (pasa banda)\n', BW);
fprintf('  d) Potencia señal modulada: %.4f\n', P_pb);
fprintf('============================================\n');
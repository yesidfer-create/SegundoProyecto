%% metricas.m — Cálculo de métricas del sistema (RF4)
% Calcula las 4 métricas requeridas para un esquema de modulación dado.
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 16;
tipo    = 'QAM';
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 10000;
EbNo_dB = 15;      % Alto para que el ruido no distorsione las métricas

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
sen_pb = real(sen_bb) .* cos(2*pi*fc*n);  % pasa banda real

%% ============ CÁLCULO DE MÉTRICAS ============
% --- a) Eficiencia espectral ---
% η = k / (1 + β)   [bits/s/Hz]  (pasa banda)
eta = k / (1 + beta);

% --- b) Energía de símbolo ---
Es = mean(abs(simbolos).^2);

% --- c) Ancho de banda (pasa banda, bilateral) ---
% Suponiendo Rs = 1 símbolo/segundo (normalizado)
Rs = 1;
BW = Rs * (1 + beta);

% --- d) Potencia de la señal modulada ---
P_pb = mean(abs(sen_pb).^2);

% (Extra) Potencia de la señal en banda base
P_bb = mean(abs(sen_bb).^2);

%% ============ MOSTRAR RESULTADOS ============
fprintf('\n============================================\n');
fprintf('  MÉTRICAS — %d-%s\n', M, tipo);
fprintf('============================================\n');
fprintf('  Parámetros:\n');
fprintf('    M (orden):              %d\n', M);
fprintf('    k (bits/símbolo):       %d\n', k);
fprintf('    β (roll-off):           %.2f\n', beta);
fprintf('    Rs (tasa símbolos):     %.2f (normalizada)\n', Rs);
fprintf('\n  Métricas (RF4):\n');
fprintf('  a) Eficiencia espectral:  %.4f  bits/s/Hz\n', eta);
fprintf('  b) Energía de símbolo:    %.4f  (normalizada)\n', Es);
fprintf('  c) Ancho de banda:        %.4f  (pasa banda, bilateral)\n', BW);
fprintf('  d) Potencia señal modulada: %.4f\n', P_pb);
fprintf('\n  Extra:\n');
fprintf('     Potencia banda base:   %.4f\n', P_bb);
fprintf('============================================\n');

%% ============ COMPARACIÓN ENTRE ESQUEMAS ============
fprintf('\n\n========= COMPARACIÓN DE MÉTRICAS =========\n');
fprintf('  Esquema  |   k  |  η (bits/s/Hz) |  BW (pasa banda)\n');
fprintf('-----------+------+----------------+-----------------\n');

for Mtest = [4, 16, 64]
    for tipoTest = {'PAM','QAM','PSK'}
        t = tipoTest{1};
        kk = log2(Mtest);
        if strcmp(t,'QAM') && mod(kk,2) ~= 0, continue; end
        eta_t = kk / (1 + beta);
        BW_t  = 1 * (1 + beta);
        fprintf(' %3d-%-3s  |  %d   |     %.4f     |     %.4f\n', ...
            Mtest, t, kk, eta_t, BW_t);
    end
end
fprintf('===========================================\n');
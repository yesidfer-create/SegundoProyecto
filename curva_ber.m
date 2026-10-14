%% curva_ber.m — Curva BER vs Eb/N0 para 4-PAM, 4-QAM y 4-PSK
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 4;                   % Orden (4 para comparar justamente)
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 100000;               % Símbolos por simulación
EbNo_dB = 0:1:14;              % Barrido de 0 a 14 dB en pasos de 1

tipos = {'PAM', 'QAM', 'PSK'};
colores = {'b', 'r', 'g'};
marcadores = {'o', 's', '^'};

%% ============ FILTRO (común a todos) ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

%% ============ SIMULACIÓN ============
figure('Name', 'Curva BER vs Eb/N0', 'Position', [200 100 800 600]);
hold on; grid on;

ber_resultados = zeros(length(EbNo_dB), length(tipos));

for t = 1:length(tipos)
    tipo = tipos{t};
    ber = zeros(size(EbNo_dB));

    fprintf('\nSimulando %d-%s...\n', M, tipo);

    % --- 1. Mapeo (UNA sola vez para todos los Eb/N0) ---
    switch tipo
        case 'PAM'
            [simbolos, bits_tx, k] = mapeo_pam(M, N);
        case 'QAM'
            [simbolos, bits_tx, k] = mapeo_qam(M, N);
        case 'PSK'
            [simbolos, bits_tx, k] = mapeo_psk(M, N);
    end

    C = constelacion(M, tipo);

    % --- 2. Transmisión (UNA sola vez para todos los Eb/N0) ---
    simbolos_up = mi_upsample(simbolos, sps);
    senal_tx = conv(simbolos_up, h, 'full');

    % --- 3. Barrido de Eb/N0 ---
    for i = 1:length(EbNo_dB)
        % Canal (diferente cada Eb/N0)
        senal_rx = canal_awgn(senal_tx, EbNo_dB(i), k);

        % Filtro receptor
        senal_filtrada = conv(senal_rx, h, 'full');

        % Muestreo
        idx_muestreo = retardo + 1 : sps : retardo + N*sps;
        muestras = senal_filtrada(idx_muestreo);

        % Decisión
        [bits_rx, ~] = decisor(muestras, C, k);

        % BER
        ber(i) = sum(bits_tx ~= bits_rx) / length(bits_tx);
    end

    ber_resultados(:, t) = ber;

    % Graficar (reemplazando ceros por un valor mínimo para escala log)
    ber_plot = ber;
    ber_plot(ber_plot == 0) = 1e-6;   % suelo artificial para visualización

    semilogy(EbNo_dB, ber_plot, [colores{t} marcadores{t} '-'], ...
        'LineWidth', 2, 'MarkerSize', 8, ...
        'DisplayName', sprintf('%d-%s', M, tipo));

    fprintf('  Listo. Última BER = %.2e\n', ber(end));
end

%% ============ ESTILO ============
set(gca, 'YScale', 'log');
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
title(sprintf('Curva BER vs E_b/N_0 — %d-PAM / %d-QAM / %d-PSK', M, M, M), ...
    'FontSize', 13);
legend('Location', 'southwest', 'FontSize', 11);
ylim([1e-6 1]);
xlim([0 14]);

%% ============ TABLA EN CONSOLA ============
fprintf('\n\n========= TABLA DE BER =========\n');
fprintf('  Eb/N0 |   4-PAM   |   4-QAM   |   4-PSK\n');
fprintf('--------+-----------+-----------+----------\n');
for i = 1:length(EbNo_dB)
    fprintf('  %3d dB | %.2e | %.2e | %.2e\n', ...
        EbNo_dB(i), ber_resultados(i,1), ...
        ber_resultados(i,2), ber_resultados(i,3));
end
fprintf('================================\n');
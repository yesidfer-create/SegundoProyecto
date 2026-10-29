%% curva_ber.m — Curva BER vs Eb/N0 (Simulada y Teórica)
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 4;
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 100000;               
EbNo_dB = 0:1:14;              
tipos = {'PAM', 'QAM', 'PSK'};
colores = {'b', 'r', 'g'};
marcadores = {'o', 's', '^'};

%% ============ FILTRO ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

%% ============ SIMULACIÓN ============
figure('Name', 'Curva BER vs Eb/N0', 'Position', [200 100 800 600]);
hold on; grid on;

for t = 1:length(tipos)
    tipo = tipos{t};
    ber = zeros(size(EbNo_dB));
    fprintf('Simulando %d-%s...\n', M, tipo);

    switch tipo
        case 'PAM', [simbolos, bits_tx, k] = mapeo_pam(M, N);
        case 'QAM', [simbolos, bits_tx, k] = mapeo_qam(M, N);
        case 'PSK', [simbolos, bits_tx, k] = mapeo_psk(M, N);
    end
    C = constelacion(M, tipo);

    simbolos_up = mi_upsample(simbolos, sps);
    senal_tx = conv(simbolos_up, h, 'full');

    for i = 1:length(EbNo_dB)
        senal_rx = canal_awgn(senal_tx, EbNo_dB(i), k);
        senal_filtrada = conv(senal_rx, h, 'full');
        muestras = senal_filtrada(retardo+1 : sps : retardo + N*sps);
        [bits_rx, ~] = decisor(muestras, C, k);
        ber(i) = sum(bits_tx ~= bits_rx) / length(bits_tx);
    end

    % --- Gráfica Simulada (usando NaN en lugar de 1e-6) ---
    ber_plot = ber;
    ber_plot(ber_plot == 0) = NaN; 
    semilogy(EbNo_dB, ber_plot, [colores{t} marcadores{t} '-'], ...
        'LineWidth', 2, 'MarkerSize', 8, ...
        'DisplayName', sprintf('%d-%s (Sim)', M, tipo));

    % --- Gráfica Teórica ---
    ber_teo = zeros(size(EbNo_dB));
    for i = 1:length(EbNo_dB)
        EbNo_lin = 10^(EbNo_dB(i)/10);
        if strcmp(tipo, 'PAM')
            ber_teo(i) = 0.75 * 0.5 * erfc(sqrt(0.8 * EbNo_lin) / sqrt(2));
        else
            ber_teo(i) = 0.5 * erfc(sqrt(2 * EbNo_lin) / sqrt(2));
        end
    end
    semilogy(EbNo_dB, ber_teo, [colores{t} '--'], ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('%d-%s (Teo)', M, tipo));
end

%% ============ ESTILO ============
set(gca, 'YScale', 'log');
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
title(sprintf('Curva BER vs E_b/N_0 — %d-PAM / %d-QAM / %d-PSK', M, M, M));
legend('Location', 'southwest', 'FontSize', 10);
ylim([1e-6 1]);
xlim([0 14]);
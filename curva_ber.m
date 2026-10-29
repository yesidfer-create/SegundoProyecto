%% curva_ber.m — Curva BER vs Eb/N0 (Sistema Real en Pasa Banda)
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 4;                   
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 100000;              
EbNo_dB = 0:1:14;              
fc      = 0.15;                

tipos = {'PAM', 'QAM', 'PSK'};
colores = {'b', 'r', 'g'};
marcadores = {'o', 's', '^'};

%% ============ FILTRO ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

%% ============ SIMULACIÓN ============
figure('Name', 'Curva BER vs Eb/N0 (Sistema Real I/Q)', 'Position', [200 100 800 600]);
hold on; grid on;

for t = 1:length(tipos)
    tipo = tipos{t};
    ber_sim = zeros(size(EbNo_dB));

    fprintf('\nSimulando %d-%s...\n', M, tipo);

    % 1. Mapeo y Transmisión (Una sola vez por esquema)
    switch tipo
        case 'PAM', [simbolos, bits_tx, k] = mapeo_pam(M, N);
        case 'QAM', [simbolos, bits_tx, k] = mapeo_qam(M, N);
        case 'PSK', [simbolos, bits_tx, k] = mapeo_psk(M, N);
    end
    C = constelacion(M, tipo);

    % Filtro Tx
    simb_up = mi_upsample(simbolos, sps);
    sen_tx = conv(simb_up, h, 'full');

    % Modulación a Pasa Banda (Onda Física)
    n = (0:length(sen_tx)-1)';
    sen_pb_tx = real(sen_tx .* exp(1j*2*pi*fc*n));

    % 2. Barrido de Eb/N0
    for i = 1:length(EbNo_dB)
        % Canal AWGN (Ruido Real)
        sen_pb_rx = canal_awgn(sen_pb_tx, EbNo_dB(i), k);

        % Demodulación I/Q (Receptor Físico)
        I_rx = 2 * sen_pb_rx .* cos(2*pi*fc*n);
        Q_rx = -2 * sen_pb_rx .* sin(2*pi*fc*n);
        sen_bb_rx = I_rx + 1j*Q_rx;

        % Filtro Rx (SRRC) y Muestreo
        sen_fil = conv(sen_bb_rx, h, 'full');
        muestras = sen_fil(retardo+1 : sps : retardo + N*sps);

        % Decisión
        [bits_rx, ~] = decisor(muestras, C, k);
        ber_sim(i) = sum(bits_tx ~= bits_rx) / length(bits_tx);
    end

    % --- Gráfica Simulada ---
    ber_plot = ber_sim;
    ber_plot(ber_plot == 0) = NaN; 
    semilogy(EbNo_dB, ber_plot, [colores{t} marcadores{t} '-'], ...
        'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', sprintf('%d-%s (Sim)', M, tipo));

    % --- Gráfica Teórica ---
    ber_teo = zeros(size(EbNo_dB));
    for i = 1:length(EbNo_dB)
        EbNo_lin = 10^(EbNo_dB(i)/10);
        if strcmp(tipo, 'PAM')
            % Fórmula exacta con Gray para 4-PAM
            ber_teo(i) = 0.5 * erfc(sqrt(0.8 * EbNo_lin) / sqrt(2)); 
        else
            ber_teo(i) = 0.5 * erfc(sqrt(2 * EbNo_lin) / sqrt(2));
        end
    end
    semilogy(EbNo_dB, ber_teo, [colores{t} '--'], ...
        'LineWidth', 1.5, 'DisplayName', sprintf('%d-%s (Teo)', M, tipo));
end

%% ============ ESTILO ============
set(gca, 'YScale', 'log');
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
title('Curva BER vs E_b/N_0 (Simulación Pasa Banda)');
legend('Location', 'southwest', 'FontSize', 9);
ylim([1e-6 1]);
xlim([0 14]);
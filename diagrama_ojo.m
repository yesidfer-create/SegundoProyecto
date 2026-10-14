%% diagrama_ojo.m — Diagrama del ojo en recepción
% Genera el diagrama del ojo para dos valores de Eb/N0, mostrando
% cómo la calidad del ojo empeora con más ruido.
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 16;         % Orden de modulación
tipo    = 'QAM';      % 'PAM', 'QAM' o 'PSK'
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 2000;       % Símbolos (menos que en BER, no necesitamos muchos)

%% ============ FILTRO ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

%% ============ MAPEO ============
switch upper(tipo)
    case 'PAM', [simbolos, ~, k] = mapeo_pam(M, N);
    case 'QAM', [simbolos, ~, k] = mapeo_qam(M, N);
    case 'PSK', [simbolos, ~, k] = mapeo_psk(M, N);
end

% Tx (una sola vez, la señal es la misma)
simb_up = mi_upsample(simbolos, sps);
sen_tx  = conv(simb_up, h, 'full');

%% ============ DOS ESCENARIOS ============
EbNo_lista = [10, 16];   % dB — poco ruido y mucho ruido
titulos    = {'Eb/N_0 = 10 dB (calidad media)', ...
    'Eb/N_0 = 16 dB (buena calidad)'};

figure('Name', 'Diagrama del ojo', 'Position', [200 100 900 500]);

for esc = 1:2
    EbNo_dB = EbNo_lista(esc);

    % Canal
    sen_rx = canal_awgn(sen_tx, EbNo_dB, k);

    % Filtro Rx
    sen_fil = conv(sen_rx, h, 'full');

    % Recortar la parte "útil" (evitar bordes del filtro)
    sen_fil = sen_fil(retardo+1 : end-retardo);

    % --- Construir el diagrama del ojo ---
    % Cada segmento tiene 2*sps muestras (2 símbolos)
    L = 2 * sps;

    % Alinear segmentos al instante de muestreo (centro del ojo)
    % El primer símbolo está en la posición 1
    inicio = 1;
    num_seg = floor((length(sen_fil) - L) / sps);

    % Matriz de segmentos: cada fila es un segmento
    segmentos = zeros(num_seg, L);
    for i = 1:num_seg
        segmentos(i, :) = sen_fil(inicio + (i-1)*sps : inicio + (i-1)*sps + L - 1).';
    end

    % --- Graficar ---
    subplot(1, 2, esc);
    hold on;
    t_ojo = (0:L-1) / sps;   % eje en unidades de símbolo

    % Graficar todos los segmentos en gris claro
    for i = 1:num_seg
        plot(t_ojo, real(segmentos(i, :)), 'Color', [0.7 0.7 0.9]);
    end

    % Marcar el instante de muestreo (centro del ojo)
    xline(1, 'r--', 'LineWidth', 2, 'Label', 'Muestreo');

    grid on;
    xlabel('Tiempo (símbolos)', 'FontSize', 11);
    ylabel('Amplitud (parte real)', 'FontSize', 11);
    title(titulos{esc}, 'FontSize', 12);
    xlim([0 2]);
end

sgtitle(sprintf('Diagrama del ojo — %d-%s (\\beta = %.2f)', M, tipo, beta), ...
    'FontSize', 13, 'FontWeight', 'bold');
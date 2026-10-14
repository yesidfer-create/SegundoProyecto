%% tabla_informe.m — Genera la tabla del informe con ΔEb/N0
% Simula 4-PAM, 4-QAM y 4-PSK con código Gray, calcula la curva BER
% y luego interpola/extrapola para llenar la tabla comparativa.
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS ============
M       = 4;
beta    = 0.35;
span    = 6;
sps     = 8;
N       = 500000;         % 500 mil símbolos por esquema
EbNo_dB = 0:0.5:13;       % Barrido fino de 0 a 13 dB

tipos = {'PAM', 'QAM', 'PSK'};

%% ============ FILTRO ============
h = filtro_srrc(beta, span, sps);
retardo = span * sps;

%% ============ SIMULACIÓN ============
ber_mat = zeros(length(EbNo_dB), 3);

for t = 1:3
    tipo = tipos{t};
    fprintf('Simulando %d-%s (N = %d)...\n', M, tipo, N);
    
    switch tipo
        case 'PAM', [simb, bits_tx, k] = mapeo_pam(M, N);
        case 'QAM', [simb, bits_tx, k] = mapeo_qam(M, N);
        case 'PSK', [simb, bits_tx, k] = mapeo_psk(M, N);
    end
    C = constelacion(M, tipo);
    
    simb_up = mi_upsample(simb, sps);
    sen_tx  = conv(simb_up, h, 'full');
    
    for i = 1:length(EbNo_dB)
        sen_rx    = canal_awgn(sen_tx, EbNo_dB(i), k);
        sen_fil   = conv(sen_rx, h, 'full');
        muestras  = sen_fil(retardo+1 : sps : retardo + N*sps);
        [bits_rx, ~] = decisor(muestras, C, k);
        ber_mat(i, t) = sum(bits_tx ~= bits_rx) / length(bits_tx);
    end
    fprintf('  Listo.\n');
end

%% ============ INTERPOLACIÓN / EXTRAPOLACIÓN ============
BER_objetivo = [1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7];
EbNo_tabla = nan(length(BER_objetivo), 3);

for t = 1:3
    ber  = ber_mat(:, t);
    ebno = EbNo_dB(:);
    
    % Quedarnos solo con valores > 0
    mask = ber > 0;
    ber_v  = ber(mask);
    ebno_v = ebno(mask);
    
    log_ber = log10(ber_v);
    
    % Eliminar duplicados (promediando ebno_v para valores repetidos)
    [log_ber, ~, ic] = unique(log_ber);
    ebno_v = accumarray(ic, ebno_v, [], @mean);
    
    % Ahora log_ber y ebno_v tienen la misma longitud NUEVA
    n = length(log_ber);
    ber_min = 10^min(log_ber);
    ber_max = 10^max(log_ber);
    
    for j = 1:length(BER_objetivo)
        log_obj = log10(BER_objetivo(j));

        if BER_objetivo(j) >= ber_min && BER_objetivo(j) <= ber_max
            % --- Interpolación dentro del rango medido ---
            EbNo_tabla(j, t) = interp1(log_ber, ebno_v, log_obj, 'linear');
        else
            % --- Extrapolación usando la región de cascada ---
            % log_ber y ebno_v YA están alineados (misma longitud)
            % Filtrar por log_ber (que es log10 de la BER) entre -5 y -2
            mask_fit = log_ber >= -5 & log_ber <= -2;
            if sum(mask_fit) >= 2
                p = polyfit(log_ber(mask_fit), ebno_v(mask_fit), 1);
            else
                % Fallback: usar todos los puntos disponibles
                p = polyfit(log_ber, ebno_v, 1);
            end
            EbNo_tabla(j, t) = polyval(p, log_obj);
        end
    end
end

%% ============ TABLA 1: Eb/N0 por esquema ============
fprintf('\n\n========= TABLA DE Eb/N0 (dB) =========\n');
fprintf('  BER    |  Eb/N0 4-PAM |  Eb/N0 4-QAM |  Eb/N0 4-PSK\n');
fprintf('---------+--------------+--------------+--------------\n');
for j = 1:length(BER_objetivo)
    fprintf(' 10^%-3d  |    %6.2f    |    %6.2f    |    %6.2f\n', ...
            round(log10(BER_objetivo(j))), ...
            EbNo_tabla(j,1), EbNo_tabla(j,2), EbNo_tabla(j,3));
end
fprintf('=======================================\n');

%% ============ TABLA 2: Diferencias ΔEb/N0 ============
fprintf('\n\n===== TABLA DE DIFERENCIAS ΔEb/N0 (dB) =====\n');
fprintf('  BER    | 4PAM-4QAM | 4PSK-4QAM | 4QAM-4PAM\n');
fprintf('---------+-----------+-----------+-----------\n');
for j = 1:length(BER_objetivo)
    d1 = EbNo_tabla(j,1) - EbNo_tabla(j,2);   % 4PAM - 4QAM
    d2 = EbNo_tabla(j,3) - EbNo_tabla(j,2);   % 4PSK - 4QAM
    d3 = EbNo_tabla(j,2) - EbNo_tabla(j,1);   % 4QAM - 4PAM
    fprintf(' 10^%-3d  |   %+6.2f  |   %+6.2f  |   %+6.2f\n', ...
            round(log10(BER_objetivo(j))), d1, d2, d3);
end
fprintf('============================================\n');

%% ============ GRÁFICA ============
figure('Name', 'Curva BER con tabla del informe', 'Position', [200 100 800 600]);
hold on; grid on;

colores = {'b', 'r', 'g'};
marcadores = {'o', 's', '^'};

for t = 1:3
    ber_plot = ber_mat(:, t);
    ber_plot(ber_plot == 0) = 1e-7;   % para visualización en log
    semilogy(EbNo_dB, ber_plot, [colores{t} marcadores{t} '-'], ...
             'LineWidth', 2, 'MarkerSize', 8, ...
             'DisplayName', sprintf('%d-%s', M, tipos{t}));
end

% Marcar los puntos de la tabla con líneas horizontales
for j = 1:length(BER_objetivo)
    yline(BER_objetivo(j), 'k:', 'HandleVisibility', 'off');
end

set(gca, 'YScale', 'log');
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
title('Curva BER vs E_b/N_0 — Tabla del informe', 'FontSize', 13);
legend('Location', 'southwest', 'FontSize', 11);
ylim([1e-7 1]);
xlim([0 13]);
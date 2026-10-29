%% tabla_informe.m — Tabla del informe y validación (Pasa Banda)
clear; clc; close all;
rng(42);

%% ============ PARÁMETROS GLOBALES ============
beta  = 0.35;
span  = 6;
sps   = 8;
M     = 4;
fc    = 0.15; % Frecuencia portadora
BER_obj = [1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7];

%% ============ CÁLCULO TEÓRICO ============
Qinv = @(p) sqrt(2) * erfcinv(2*p);

% 4-QAM y 4-PSK (Gray)
EbNo_QAM = 10*log10( Qinv(BER_obj).^2 / 2 );
EbNo_PSK = EbNo_QAM;

% 4-PAM (Gray, aproximación del vecino más cercano)
EbNo_PAM = 10*log10( Qinv(BER_obj/0.75).^2 / 0.8 );

% Matriz con los 3 esquemas: columnas = [4-PAM, 4-QAM, 4-PSK]
EbNo_tabla = [EbNo_PAM(:), EbNo_QAM(:), EbNo_PSK(:)];

%% ============ TABLA 1: Eb/N0 Teórico ============
fprintf('\n\n========= TABLA DE Eb/N0 TEÓRICO (dB) =========\n');
fprintf('  BER    |  Eb/N0 4-PAM |  Eb/N0 4-QAM |  Eb/N0 4-PSK\n');
fprintf('---------+--------------+--------------+--------------\n');
for j = 1:length(BER_obj)
    fprintf(' 10^%-3d  |    %6.2f    |    %6.2f    |    %6.2f\n', ...
        round(log10(BER_obj(j))), ...
        EbNo_tabla(j,1), EbNo_tabla(j,2), EbNo_tabla(j,3));
end
fprintf('===============================================\n');

%% ============ TABLA 2: Diferencias ΔEb/N0 ============
fprintf('\n\n============ TABLA DE DIFERENCIAS ΔEb/N0 (dB) ============\n');
fprintf('  BER    | 4PAM-4QAM | 4PSK-4QAM | 4PSK-4PAM\n');
fprintf('---------+-----------+-----------+-----------\n');
for j = 1:length(BER_obj)
    d1 = EbNo_tabla(j,1) - EbNo_tabla(j,2);   % 4PAM - 4QAM
    d2 = EbNo_tabla(j,3) - EbNo_tabla(j,2);   % 4PSK - 4QAM
    d3 = EbNo_tabla(j,3) - EbNo_tabla(j,1);   % 4PSK - 4PAM
    fprintf(' 10^%-3d  |   %+6.2f  |   %+6.2f  |   %+6.2f\n', ...
        round(log10(BER_obj(j))), d1, d2, d3);
end
fprintf('==========================================================\n');

%% ============ GRÁFICA DE BARRAS ============
figure('Name', 'Tabla ΔEb/N0', 'Position', [200 200 800 450]);
Delta = [EbNo_tabla(:,1) - EbNo_tabla(:,2), ...   
         EbNo_tabla(:,3) - EbNo_tabla(:,2), ...   
         EbNo_tabla(:,3) - EbNo_tabla(:,1)];      

b = bar(Delta, 'grouped');
grid on;
b(1).FaceColor = [0.2 0.4 0.8];
b(2).FaceColor = [0.2 0.7 0.3];
b(3).FaceColor = [0.8 0.2 0.2];

set(gca, 'XTickLabel', ...
    {'10^{-2}','10^{-3}','10^{-4}','10^{-5}','10^{-6}','10^{-7}'}, ...
    'FontSize', 11);
xlabel('BER', 'FontSize', 12);
ylabel('\Delta E_b/N_0 (dB)', 'FontSize', 12);
title('Diferencias de E_b/N_0 entre esquemas', 'FontSize', 13);
legend({'4PAM - 4QAM', '4PSK - 4QAM', '4PSK - 4PAM'}, ...
    'Location', 'best');
yline(0, 'k-', 'LineWidth', 1);

%% ============ TABLA 3: VALIDACIÓN POR SIMULACIÓN ============
fprintf('\n\nValidando por simulación (N = 500000 símbolos por esquema)...\n');

N_val = 500000; 
tipos_val = {'PAM', 'QAM', 'PSK'};
N_validar = 3; % Validar solo 1e-2, 1e-3, 1e-4
BER_sim = nan(N_validar, 3);

h = filtro_srrc(beta, span, sps);
retardo = span * sps;

for t = 1:3
    switch tipos_val{t}
        case 'PAM', [simb, bits_tx, k] = mapeo_pam(M, N_val);
        case 'QAM', [simb, bits_tx, k] = mapeo_qam(M, N_val);
        case 'PSK', [simb, bits_tx, k] = mapeo_psk(M, N_val);
    end
    C  = constelacion(M, tipos_val{t});
    
    % 1. Conformación en Banda Base
    sen_bb_tx = conv(mi_upsample(simb, sps), h, 'full');
    
    % 2. Modulación a Pasa Banda
    n = (0:length(sen_bb_tx)-1)';
    sen_pb_tx = real(sen_bb_tx .* exp(1j*2*pi*fc*n));
    
    for j = 1:N_validar
        % 3. Canal AWGN Real
        sen_pb_rx = canal_awgn(sen_pb_tx, EbNo_tabla(j,t), k);
        
        % 4. Demodulación I/Q
        I_rx = 2 * sen_pb_rx .* cos(2*pi*fc*n);
        Q_rx = -2 * sen_pb_rx .* sin(2*pi*fc*n);
        sen_bb_rx = I_rx + 1j*Q_rx;
        
        % 5. Filtro Rx y Muestreo
        filtrada = conv(sen_bb_rx, h, 'full');
        muestras = filtrada(retardo+1 : sps : retardo + N_val*sps);
        
        % 6. Decisión
        [bits_rx, ~] = decisor(muestras, C, k);
        BER_sim(j,t) = sum(bits_tx ~= bits_rx) / length(bits_tx);
    end
end

fprintf('\n===== BER SIMULADA vs BER OBJETIVO =====\n');
fprintf('  BER obj |  4-PAM sim  |  4-QAM sim  |  4-PSK sim\n');
fprintf('----------+-------------+-------------+------------\n');
for j = 1:N_validar
    fprintf('  %.0e  |  %.2e  |  %.2e  |  %.2e\n', ...
        BER_obj(j), BER_sim(j,1), BER_sim(j,2), BER_sim(j,3));
end
fprintf('========================================\n');
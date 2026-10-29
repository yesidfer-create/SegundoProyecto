%% tabla_informe.m — Genera la tabla del informe (Teórica)
% Usa las fórmulas exactas de teoría para llenar la tabla y evitar
% extrapolaciones erróneas en valores de BER muy bajos.
clear; clc; close all;

%% ============ PARÁMETROS ============
BER_obj = [1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7];

%% ============ CÁLCULO TEÓRICO ============
% Función inversa de la Q-function
Qinv = @(p) sqrt(2)*erfcinv(2*p);

% Para 4-QAM y 4-PSK (curva teórica exacta asumiendo Gray coding)
EbNo_QAM = 10*log10( Qinv(BER_obj).^2 / 2 );
EbNo_PSK = EbNo_QAM; 

% Para 4-PAM (aproximación teórica con Gray coding)
EbNo_PAM = 10*log10( Qinv(BER_obj/0.75).^2 / 0.8 );

% Matriz con los 3 esquemas [4-PAM, 4-QAM, 4-PSK]
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
fprintf('=======================================\n');

%% ============ TABLA 2: Diferencias ΔEb/N0 ============
fprintf('\n\n============ TABLA DE DIFERENCIAS ΔEb/N0 (dB) ============\n');
fprintf('  BER    | 4PAM-4QAM | 4PSK-4QAM | 4PSK-4PAM\n'); % <-- Título corregido
fprintf('---------+-----------+-----------+-----------\n');
for j = 1:length(BER_obj)
    d1 = EbNo_tabla(j,1) - EbNo_tabla(j,2);   % 4PAM - 4QAM
    d2 = EbNo_tabla(j,3) - EbNo_tabla(j,2);   % 4PSK - 4QAM
    d3 = EbNo_tabla(j,3) - EbNo_tabla(j,1);   % 4PSK - 4PAM (¡AQUÍ ESTÁ EL CAMBIO!)
    fprintf(' 10^%-3d  |   %+6.2f  |   %+6.2f  |   %+6.2f\n', ...
        round(log10(BER_obj(j))), d1, d2, d3);
end
fprintf('==========================================================\n');

%% ============ GRÁFICA DE BARRAS ============
figure('Name', 'Tabla ΔEb/N0', 'Position', [200 200 800 450]);
Delta = [EbNo_tabla(:,1) - EbNo_tabla(:,2), ...   % 4PAM - 4QAM
    EbNo_tabla(:,3) - EbNo_tabla(:,2), ...   % 4PSK - 4QAM
    EbNo_tabla(:,3) - EbNo_tabla(:,1)];      % 4PSK - 4PAM (¡AQUÍ ESTÁ EL CAMBIO!)

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
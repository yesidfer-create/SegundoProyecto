%% main.m — Sistema completo de comunicaciones digitales
% Simula un sistema M-PAM, M-QAM o M-PSK end-to-end.
clear; clc; close all;
rng(42);   % Semilla fija para reproducibilidad (RNF3)

%% ============ PARÁMETROS ============
M       = 16;       % Orden de modulación (potencia de 2; QAM: potencia de 4)
tipo    = 'QAM';    % 'PAM', 'QAM' o 'PSK'
beta    = 0.35;     % Factor de roll-off (0 a 1)
span    = 6;        % Duración del filtro SRRC (en símbolos)
sps     = 8;        % Muestras por símbolo
N       = 5000;     % Número de símbolos a transmitir
EbNo_dB = 10;       % Relación Eb/N0 (dB)

%% ============ 1. MAPEO ============
switch upper(tipo)
    case 'PAM'
        [simbolos, bits_tx, k] = mapeo_pam(M, N);
    case 'QAM'
        [simbolos, bits_tx, k] = mapeo_qam(M, N);
    case 'PSK'
        [simbolos, bits_tx, k] = mapeo_psk(M, N);
    otherwise
        error('Tipo de modulación no reconocido: %s', tipo);
end

fprintf('===========================================\n');
fprintf('  Sistema %d-%s\n', M, tipo);
fprintf('===========================================\n');
fprintf('  Bits por símbolo:  %d\n', k);
fprintf('  Símbolos:          %d\n', N);
fprintf('  Total bits:        %d\n', length(bits_tx));
fprintf('  Eb/N0:             %d dB\n', EbNo_dB);
fprintf('  Roll-off (beta):   %.2f\n', beta);
fprintf('  Muestras/símbolo:  %d\n', sps);
fprintf('===========================================\n');

%% ============ 2. CONFORMACIÓN DE PULSOS ============
% Filtro SRRC (el mismo se usa en Tx y en Rx)
h = filtro_srrc(beta, span, sps);

% Sobremuestreo: insertar ceros entre símbolos
simbolos_up = mi_upsample(simbolos, sps);

% Filtrar con SRRC en transmisión (convolución 'full')
senal_tx = conv(simbolos_up, h, 'full');

%% ============ 3. CANAL AWGN ============
senal_rx = canal_awgn(senal_tx, EbNo_dB, k);

%% ============ 4. FILTRO RECEPTOR (matched filter) ============
senal_filtrada = conv(senal_rx, h, 'full');

%% ============ 5. MUESTREO ============
% El retardo total es span*sps (mitad del filtro en Tx + mitad en Rx)
retardo = span * sps;
idx_muestreo = retardo + 1 : sps : retardo + N*sps;
muestras = senal_filtrada(idx_muestreo);

%% ============ 6. DECISIÓN ============
C = constelacion(M, tipo);
[bits_rx, ~] = decisor(muestras, C, k);

%% ============ 7. CÁLCULO DE BER ============
num_errores = sum(bits_tx ~= bits_rx);
BER = num_errores / length(bits_tx);

fprintf('\n========== RESULTADOS ==========\n');
fprintf('  Errores:    %d / %d\n', num_errores, length(bits_tx));
fprintf('  BER:        %.4e\n', BER);
fprintf('================================\n');

%% ============ 8. GRÁFICAS ============
% --- Constelación transmitida ---
figure('Name', 'Constelación Tx', 'Position', [100 100 500 500]);
plot(real(simbolos), imag(simbolos), 'bo', 'MarkerSize', 3);
hold on;
plot(real(C), imag(C), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
grid on; axis equal;
xlabel('I'); ylabel('Q');
title(sprintf('Constelación transmitida %d-%s', M, tipo));
legend('Símbolos Tx', 'Constelación ideal', 'Location', 'best');

% --- Constelación recibida ---
figure('Name', 'Constelación Rx', 'Position', [650 100 500 500]);
plot(real(muestras), imag(muestras), 'bo', 'MarkerSize', 3);
hold on;
plot(real(C), imag(C), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
grid on; axis equal;
xlabel('I'); ylabel('Q');
title(sprintf('Constelación recibida %d-%s (Eb/N0 = %d dB)', M, tipo, EbNo_dB));
legend('Símbolos Rx', 'Constelación ideal', 'Location', 'best');

% --- Señal transmitida (primeros símbolos) ---
figure('Name', 'Señal Tx', 'Position', [100 650 800 300]);
t = (0:length(senal_tx)-1) / sps;
plot(t, real(senal_tx), 'b');
grid on;
xlabel('Tiempo (símbolos)'); ylabel('Amplitud');
title('Señal transmitida en banda base (parte real)');
xlim([0 30]);
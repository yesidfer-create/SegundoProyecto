# Proyecto II — Sistema de Comunicaciones Digitales M-PAM, M-QAM, M-PSK

Simulación completa de un sistema de comunicaciones digitales en MATLAB, con interfaz gráfica interactiva en App Designer, que analiza el desempeño de los esquemas de modulación M-PAM, M-QAM y M-PSK mediante simulación Monte Carlo y validación teórica.

---

## 📋 Descripción

El proyecto implementa, desde cero (sin uso de funciones de alto nivel del Communications Toolbox), un sistema de comunicaciones digitales que incluye:

- **Mapeo** de bits a símbolos con codificación Gray.
- **Conformación de pulsos** mediante filtro SRRC (raíz de coseno alzado).
- **Modulación** analógica a pasa banda (I/Q).
- **Canal AWGN** con parámetros configurables (Eb/N0).
- **Filtro receptor** (matched filter).
- **Decisión** por mínima distancia euclidiana.
- **Cálculo de BER** para curvas de desempeño y validación estadística.

Todo integrado en una **interfaz gráfica** que permite modificar parámetros en tiempo real y visualizar los resultados al instante.

---

## 👥 Integrantes

- **Yesid Fernando Ruiz**
- Curso: Comunicaciones Digitales
- Universidad del Cauca, 2026

---

## 🗂️ Estructura del proyecto

### 1. Utilidades y Módulos del Sistema (Backend)
| Archivo | Descripción |
|---------|-------------|
| `bits_a_dec.m` | Conversión de grupos de bits a decimal. |
| `dec_a_bits.m` | Conversión de decimal a grupos de bits. |
| `bin_a_gray.m` | Conversión de binario a código Gray. |
| `mapeo_pam.m` | Mapeo de bits a símbolos M-PAM. |
| `mapeo_qam.m` | Mapeo de bits a símbolos M-QAM. |
| `mapeo_psk.m` | Mapeo de bits a símbolos M-PSK. |
| `constelacion.m` | Genera la constelación ideal de referencia. |
| `filtro_srrc.m` | Diseño del filtro raíz de coseno alzado. |
| `mi_upsample.m` | Sobremuestreo manual (inserción de ceros). |
| `canal_awgn.m` | Canal con ruido blanco gaussiano. |
| `decisor.m` | Decisión por mínima distancia euclidiana. |

### 2. Scripts de Análisis
| Archivo | Descripción |
|---------|-------------|
| `main.m` | Script principal de simulación end-to-end. |
| `curva_ber.m` | Generación de curvas BER (simuladas vs teóricas). |
| `tabla_informe.m` | Cálculo teórico de la tabla ΔEb/N0 y validación por simulación. |
| `diagrama_ojo.m` | Visualización del diagrama del ojo en recepción. |
| `espectro.m` | Cálculo de PSD en banda base y pasa banda (sin toolbox). |
| `metricas.m` | Cálculo de eficiencia espectral, energía, BW y potencia. |

### 3. Interfaz Gráfica
| Archivo | Descripción |
|---------|-------------|
| `proyecto_gui.mlapp` | App Designer: interfaz completa e interactiva. |

---

## 🚀 Cómo ejecutar

### Requisitos
- **MATLAB R2020b o superior** (probado en R2026a).
- ❌ **NO** requiere Communications Toolbox (cumple RNF2).
- ⚠️ **NO** requiere Signal Processing Toolbox para la PSD (se implementó con `fft` puro).

### Ejecución rápida
1. Abrir MATLAB y navegar a la carpeta del proyecto.
2. Ejecutar `proyecto_gui.mlapp` para abrir la interfaz gráfica.
3. Para generar los datos del informe escrito, ejecutar `tabla_informe.m` en la Command Window.

---

## 🎨 Características de la GUI

La interfaz (App Designer) permite modificar en tiempo real:
- **Esquema:** M-PAM, M-QAM o M-PSK.
- **Orden (M):** Potencias de 2 (con validación especial para QAM).
- **Factor de roll-off (β):** 0 a 1.
- **Eb/N0:** 0 a 40 dB.
- **N:** Número de símbolos simulados.

**Visualizaciones:**
1. **Constelación** en recepción.
2. **Diagrama del ojo**.
3. **Curva BER** vs Eb/N0.
4. **Espectro** en banda base (Tx).
5. **Espectro** en pasa banda (Rx).
6. **Panel de métricas** (η, Es, BW, P).
7. **Tabla ΔEb/N0** generada al instante.

**Características adicionales (RNF1):**
- Validación estricta de errores (ej. β > 1 o M inválido).
- Advertencia teórica si se selecciona QAM > 16 (por la aproximación del código Gray en 2D).

---

## 📊 Resultados principales (Teóricos)

### Tabla de Diferencias ΔEb/N0
Los valores se calcularon usando la función inversa de Q (\(Q^{-1}\)) asumiendo codificación Gray.

| BER | 4PAM − 4QAM | 4PSK − 4QAM | 4PSK − 4PAM |
|-----|-------------|-------------|-------------|
| 10⁻² | +3.56 dB | +0.00 dB | −3.56 dB |
| 10⁻³ | +3.73 dB | +0.00 dB | −3.73 dB |
| 10⁻⁴ | +3.81 dB | +0.00 dB | −3.81 dB |
| 10⁻⁵ | +3.85 dB | +0.00 dB | −3.85 dB |
| 10⁻⁶ | +3.87 dB | +0.00 dB | −3.87 dB |
| 10⁻⁷ | +3.89 dB | +0.00 dB | −3.89 dB |

*(Nota: 4-PSK y 4-QAM dan diferencia nula porque son la misma constelación rotada 45°).*

### Validación Teórica vs Simulación
El script `tabla_informe.m` demuestra que la simulación con 500,000 símbolos coincide con la teoría:
- Para un objetivo de `1e-02`, la simulación arrojó `9.84e-03` en 4-PAM y `1.00e-02` en QAM/PSK.
- El límite de simulación confiable es `10⁻⁴` (requerir simular \(10^8\) bits para medir \(10^{-7}\)).

---

## 📐 Fundamento teórico

- **Código Gray:** Garantiza que símbolos adyacentes difieran en un solo bit, reduciendo la BER a la mitad ante errores de decisión.
- **Filtro SRRC:** La cascada Tx + Rx produce un coseno alzado completo (cero ISI en el muestreo).
- **Banda Base Equivalente:** Para el cálculo de BER se usa el modelo equivalente en banda base, mientras que la modulación a pasa banda (I/Q) se implementó para el análisis espectral (RF3.d).

---

## ✅ Cumplimiento de requerimientos

| Requerimiento | Estado |
|---------------|:------:|
| RF1 (Interfaz gráfica) | ✅ |
| RF2 (Selección de esquema y roll-off) | ✅ |
| RF3.a (Diagrama del ojo) | ✅ |
| RF3.b (Constelación en recepción) | ✅ |
| RF3.c (Curva BER vs Eb/N0) | ✅ |
| RF3.d (Espectro BB y PB separados) | ✅ |
| RF4 (Métricas) | ✅ |
| RNF1 (Validación de errores) | ✅ |
| RNF2 (Sin toolbox de comunicaciones) | ✅ |
| RNF3 (Reproducibilidad) | ✅ |

---

## 📚 Referencias

- Proakis, J. G., & Salehi, M. (2008). *Digital Communications* (5th ed.). McGraw-Hill.
- Sklar, B. (2001). *Digital Communications: Fundamentals and Applications* (2nd ed.). Prentice Hall.
- Haykin, S. (2014). *Digital Communication Systems*. Wiley.

---
*Proyecto académico — Universidad del Cauca, 2026.*

function [inicioMuestra, finMuestra] = deteccion_extremos_energia(senal, fs, tamVentana, desplazamiento, umbralRelativo, margenMuestras)
%DETECCION_EXTREMOS_ENERGIA Localiza el inicio y fin de voz mediante energía.
%   [inicioMuestra, finMuestra] = deteccion_extremos_energia(senal, fs, tamVentana, desplazamiento, umbralRelativo, margenMuestras)
%   devuelve los índices de muestra (1-based) que acotan la región con voz.
%
%   Parametros opcionales:
%     - fs: frecuencia de muestreo en Hz. Por defecto 8000.
%     - tamVentana: tamaño de ventana (muestras). Por defecto 240 (~30 ms a 8 kHz).
%     - desplazamiento: salto entre ventanas (muestras). Por defecto 120 (~15 ms a 8 kHz).
%     - umbralRelativo: factor de umbral respecto a la energía máxima. Por defecto 0.1.
%     - margenMuestras: muestras añadidas a cada extremo. Por defecto 160.
%
%   Si no se detecta energía suficiente, se devuelven 1 y length(senal).

    if nargin < 2 || isempty(fs)
        fs = 8000;
    end
    if nargin < 3 || isempty(tamVentana)
        tamVentana = 240; % 30 ms
    end
    if nargin < 4 || isempty(desplazamiento)
        desplazamiento = 120; % 15 ms
    end
    if nargin < 5 || isempty(umbralRelativo)
        umbralRelativo = 0.1;
    end
    if nargin < 6 || isempty(margenMuestras)
        margenMuestras = round(0.02 * fs); % 20 ms
    end

    senal = senal(:)'; % fila
    numMuestras = numel(senal);

    if numMuestras < tamVentana
        inicioMuestra = 1;
        finMuestra = numMuestras;
        return;
    end

    indices = 1:desplazamiento:(numMuestras - tamVentana + 1);
    numVentanas = numel(indices);
    energia = zeros(1, numVentanas);

    for i = 1:numVentanas
        idx = indices(i):(indices(i) + tamVentana - 1);
        ventana = senal(idx);
        energia(i) = sum(ventana .^ 2);
    end

    energiaSuavizada = movmean(energia, 3);
    umbral = umbralRelativo * max(energiaSuavizada + eps);

    voz = energiaSuavizada > umbral;
    if ~any(voz)
        inicioMuestra = 1;
        finMuestra = numMuestras;
        return;
    end

    idxVoz = find(voz);
    inicioFrame = idxVoz(1);
    finFrame = idxVoz(end);

    inicioMuestra = max(1, indices(inicioFrame) - margenMuestras);
    finMuestra = min(numMuestras, indices(finFrame) + tamVentana - 1 + margenMuestras);
end

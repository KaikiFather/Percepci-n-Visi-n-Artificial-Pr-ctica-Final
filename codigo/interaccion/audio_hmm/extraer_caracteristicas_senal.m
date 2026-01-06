function caracteristicas = extraer_caracteristicas_senal(senal, fs, opciones)
%EXTRAER_CARACTERISTICAS_SENAL Obtiene MFCC + deltas a partir de una señal temporal.
%   caracteristicas = extraer_caracteristicas_senal(senal, fs, opciones)
%   devuelve una matriz numFrames x numCaracteristicas.
%
%   Opciones admitidas (struct):
%     - tamVentana (muestras)
%     - desplazamiento (muestras)
%     - numCoefMEL
%     - aplicarPreEnfasis (bool)
%     - umbralVAD (0-1 relativo a energía)
%
%   Si no se detecta voz se devuelve [].

    if nargin < 2 || isempty(fs)
        fs = 8000;
    end

    if nargin < 3
        opciones = struct();
    end

    tamVentana = obtener_opcion(opciones, 'tamVentana', 240);
    desplazamiento = obtener_opcion(opciones, 'desplazamiento', 120);
    numCoefMEL = obtener_opcion(opciones, 'numCoefMEL', 13);
    aplicarPreEnfasis = obtener_opcion(opciones, 'aplicarPreEnfasis', true);
    umbralVAD = obtener_opcion(opciones, 'umbralVAD', 0.1);

    senal = double(senal);
    if size(senal, 2) > 1
        senal = mean(senal, 2); % mono
    end

    if aplicarPreEnfasis
        senal = filter([1 -0.97], 1, senal);
    end

    [inicio, fin] = deteccion_extremos_energia(senal, fs, tamVentana, desplazamiento, umbralVAD);
    senal = senal(inicio:fin);

    if numel(senal) < tamVentana
        caracteristicas = [];
        return;
    end

    caracteristicasMFCC = calcular_mfcc_seguro(senal, fs, tamVentana, desplazamiento, numCoefMEL);
    if isempty(caracteristicasMFCC)
        caracteristicas = [];
        return;
    end

    delta1 = calcular_delta(caracteristicasMFCC);
    delta2 = calcular_delta(delta1);

    caracteristicas = [caracteristicasMFCC, delta1, delta2];
end

function valor = obtener_opcion(opciones, nombre, defecto)
    if isfield(opciones, nombre) && ~isempty(opciones.(nombre))
        valor = opciones.(nombre);
    else
        valor = defecto;
    end
end

function caracteristicasMFCC = calcular_mfcc_seguro(senal, fs, tamVentana, desplazamiento, numCoefMEL)
    hop = tamVentana - desplazamiento;
    try
        caracteristicasMFCC = mfcc(senal, fs, ...
            'WindowLength', tamVentana, ...
            'OverlapLength', hop, ...
            'NumCoeffs', numCoefMEL, ...
            'LogEnergy', 'Ignore');
    catch
        % Fallback manual usando melSpectrogram + DCT
        try
            [S, ~] = melSpectrogram(senal, fs, ...
                'WindowLength', tamVentana, ...
                'OverlapLength', hop, ...
                'NumBands', 26, ...
                'FFTLength', max(256, 2 ^ nextpow2(tamVentana)));
            S = log(S + eps);
            dctBase = dctmtx(size(S, 1));
            caracteristicasMFCC = (dctBase(1:numCoefMEL, :) * S).';
        catch
            warning('No se pudo calcular MFCC: la función mfcc/melSpectrogram no está disponible.');
            caracteristicasMFCC = [];
        end
    end
end

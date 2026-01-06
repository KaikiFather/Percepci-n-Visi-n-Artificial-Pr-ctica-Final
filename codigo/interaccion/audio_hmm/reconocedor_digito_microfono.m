function [digito, info] = reconocedor_digito_microfono(opciones)
%RECONOCEDOR_DIGITO_MICROFONO Reconoce un dígito (0-9) grabado por micrófono.
%   [digito, info] = reconocedor_digito_microfono(opciones)
%   Usa modelos HMM y un codebook entrenados previamente.
%
%   Opciones (struct):
%     - rutaModelos: ruta al .mat con la variable 'modelos'.
%     - rutaCodebook: ruta al .mat con la variable 'codebook'.
%     - frecuenciaMuestreo: Hz (por defecto 8000).
%     - tamVentana: muestras (por defecto 240).
%     - desplazamiento: muestras (por defecto 120).
%     - numCoefMEL: número de coeficientes MFCC (por defecto 13).
%     - duracionGrabacion: segundos de audio a capturar (por defecto 2.5 s).
%     - umbralVAD: umbral relativo de energía (por defecto 0.1).
%     - senal: si se pasa, se usa esta señal y no se graba por micro.
%
%   Devuelve:
%     - digito: etiqueta con el dígito reconocido (char o string). 'NaN' si falla.
%     - info: struct con detalles del proceso y log-verosimilitudes.

    if nargin < 1
        opciones = struct();
    end

    rutas.rutaModelos = obtener_opcion(opciones, 'rutaModelos', fullfile('codigo', 'modelos_audio', 'modelos.mat'));
    rutas.rutaCodebook = obtener_opcion(opciones, 'rutaCodebook', fullfile('codigo', 'modelos_audio', 'codebook.mat'));
    fs = obtener_opcion(opciones, 'frecuenciaMuestreo', 8000);
    tamVentana = obtener_opcion(opciones, 'tamVentana', 240);
    desplazamiento = obtener_opcion(opciones, 'desplazamiento', 120);
    numCoefMEL = obtener_opcion(opciones, 'numCoefMEL', 13);
    duracionGrabacion = obtener_opcion(opciones, 'duracionGrabacion', 2.5);
    umbralVAD = obtener_opcion(opciones, 'umbralVAD', 0.1);

    info = struct();
    info.rutas = rutas;
    info.configuracion = struct('fs', fs, 'tamVentana', tamVentana, ...
        'desplazamiento', desplazamiento, 'numCoefMEL', numCoefMEL, 'duracionGrabacion', duracionGrabacion);

    if isfield(opciones, 'senal') && ~isempty(opciones.senal)
        senal = opciones.senal;
    else
        if ~se_puede_grabar_audio()
            error('El entorno no dispone de soporte de audio para grabar por micro.');
        end
        rec = audiorecorder(fs, 16, 1);
        disp('Grabando... hable ahora');
        recordblocking(rec, duracionGrabacion);
        senal = getaudiodata(rec);
        disp('Grabación finalizada.');
    end

    if ~isfile(rutas.rutaModelos)
        error('No se encontró %s. Ejecute el entrenamiento para generarlo.', rutas.rutaModelos);
    end
    if ~isfile(rutas.rutaCodebook)
        error('No se encontró %s. Ejecute el entrenamiento para generarlo.', rutas.rutaCodebook);
    end

    datosModelos = load(rutas.rutaModelos);
    if isfield(datosModelos, 'modelos')
        modelos = datosModelos.modelos;
    else
        error('El archivo de modelos debe contener la variable "modelos".');
    end

    datosCodebook = load(rutas.rutaCodebook);
    if isfield(datosCodebook, 'codebook')
        codebook = datosCodebook.codebook;
    elseif isfield(datosCodebook, 'centroides')
        codebook = datosCodebook.centroides;
    else
        error('El archivo codebook.mat debe contener la variable "codebook" o "centroides".');
    end

    caracteristicas = extraer_caracteristicas_senal(senal, fs, struct( ...
        'tamVentana', tamVentana, 'desplazamiento', desplazamiento, ...
        'numCoefMEL', numCoefMEL, 'umbralVAD', umbralVAD));

    if isempty(caracteristicas)
        warning('No se detectó voz en la grabación.');
        digito = NaN;
        info.logVerosimilitudes = [];
        return;
    end

    secuencia = cuantizar_caracteristicas(caracteristicas, codebook);
    [digito, logV, etiquetas] = evaluar_modelos_hmm(secuencia, modelos);

    info.logVerosimilitudes = logV;
    info.etiquetas = etiquetas;
    info.secuencia = secuencia;
end

function valor = obtener_opcion(opciones, nombre, defecto)
    if isfield(opciones, nombre) && ~isempty(opciones.(nombre))
        valor = opciones.(nombre);
    else
        valor = defecto;
    end
end

function [mejorEtiqueta, logVerosimilitudes, etiquetas] = evaluar_modelos_hmm(observaciones, modelos)
    numModelos = numel(modelos);
    logVerosimilitudes = -inf(1, numModelos);
    etiquetas = strings(1, numModelos);

    for i = 1:numModelos
        modelo = modelos(i);
        etiquetas(i) = obtener_etiqueta_modelo(modelo, i);
        logVerosimilitudes(i) = logverosimilitud_hmm(observaciones, modelo);
    end

    [~, idx] = max(logVerosimilitudes);
    mejorEtiqueta = etiquetas(idx);
end

function etiqueta = obtener_etiqueta_modelo(modelo, idx)
    if isfield(modelo, 'nombre')
        etiqueta = string(modelo.nombre);
    elseif isfield(modelo, 'etiqueta')
        etiqueta = string(modelo.etiqueta);
    elseif isfield(modelo, 'digito')
        etiqueta = string(modelo.digito);
    else
        etiqueta = sprintf('%d', idx - 1);
    end
end

function logP = logverosimilitud_hmm(observaciones, modelo)
    [A, B, pi] = obtener_matrices(modelo);
    if max(observaciones) > size(B, 2)
        error('Las observaciones exceden el número de símbolos del modelo.');
    end
    try
        [~, logP] = hmmdecode(observaciones(:)', A, B); %#ok<HMMDECODE>
    catch
        % Implementación manual del algoritmo hacia adelante en log-espacio
        numEstados = size(A, 1);
        T = numel(observaciones);
        logA = log(A + eps);
        logB = log(B(:, observaciones(:)) + eps);
        logAlpha = zeros(numEstados, T);
        logAlpha(:, 1) = log(pi(:) + eps) + logB(:, 1);
        for t = 2:T
            temp = logAlpha(:, t - 1) + logA;
            logAlpha(:, t) = logB(:, t) + logsumexp(temp, 1)';
        end
        logP = logsumexp(logAlpha(:, end));
    end
end

function [A, B, pi] = obtener_matrices(modelo)
    % Transiciones
    if isfield(modelo, 'A')
        A = modelo.A;
    elseif isfield(modelo, 'trans')
        A = modelo.trans;
    elseif isfield(modelo, 'transicion')
        A = modelo.transicion;
    elseif isfield(modelo, 'TransitionMatrix')
        A = modelo.TransitionMatrix;
    else
        error('El modelo no contiene una matriz de transición reconocible.');
    end

    % Emisiones
    if isfield(modelo, 'B')
        B = modelo.B;
    elseif isfield(modelo, 'emis')
        B = modelo.emis;
    elseif isfield(modelo, 'emision')
        B = modelo.emision;
    elseif isfield(modelo, 'EmissionMatrix')
        B = modelo.EmissionMatrix;
    else
        error('El modelo no contiene una matriz de emisión reconocible.');
    end

    % Probabilidad inicial
    if isfield(modelo, 'pi')
        pi = modelo.pi;
    elseif isfield(modelo, 'estadoInicial')
        pi = modelo.estadoInicial;
    elseif isfield(modelo, 'Prior')
        pi = modelo.Prior;
    else
        pi = ones(1, size(A, 1)) / size(A, 1);
    end

    A = double(A);
    B = double(B);
    pi = double(pi(:)');
end

function y = logsumexp(x, dim)
    if nargin < 2
        dim = 1;
    end
    m = max(x, [], dim);
    y = m + log(sum(exp(x - m), dim) + eps);
end

function disponible = se_puede_grabar_audio()
    try
        numDispositivosEntrada = audiodevinfo(1);
        disponible = numDispositivosEntrada > 0;
    catch
        disponible = false;
    end
end

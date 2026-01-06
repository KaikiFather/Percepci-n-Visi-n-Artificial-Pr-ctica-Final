function movimiento = entradaVoz(tamano)
%ENTRADAVOZ Entrada por voz utilizando HMM de dígitos.
%   movimiento = entradaVoz(tamano)
%   Devuelve un struct con fila, columna y valor.

    if nargin < 1
        tamano = [0 0];
    end

    configuracion = struct( ...
        'maxFila', tamano(1), ...
        'maxColumna', tamano(2), ...
        'rutaModelos', fullfile('codigo', 'modelos_audio', 'modelos.mat'), ...
        'rutaCodebook', fullfile('codigo', 'modelos_audio', 'codebook.mat'), ...
        'intentos', 3);

    fprintf('--- Entrada por voz (dígitos 0-9) ---\n');
    fprintf('Los operadores deben introducirse con tarjetas. Para números de dos dígitos, se pedirán decenas y unidades por separado.\n');

    fila = solicitarNumeroPorVoz('fila', configuracion.maxFila, configuracion, 1);
    columna = solicitarNumeroPorVoz('columna', configuracion.maxColumna, configuracion, 1);

    % Para el valor se asume rango 0-99 (dos dígitos). Si desea operar con
    % operadores, la ruta recomendada es entradaTarjetas.
    valorNumerico = solicitarNumeroPorVoz('valor (0-99)', 99, configuracion, 0);
    valor = num2str(valorNumerico);

    movimiento = struct('fila', fila, 'columna', columna, 'valor', valor, 'origen', 'voz');
end

function numero = solicitarNumeroPorVoz(etiqueta, maxValor, config, minValor)
    if maxValor <= 0
        maxValor = 99;
    end
    if nargin < 4
        minValor = 0;
    end

    if maxValor <= 9
        numero = capturarDigito(etiqueta, config);
        if numero < minValor || numero > maxValor
            fprintf('Número fuera de rango (%d-%d). Solicita de nuevo.\n', minValor, maxValor);
            numero = solicitarNumeroPorVoz(etiqueta, maxValor, config, minValor);
        end
        return;
    end

    fprintf('Introduce %s. Se solicitarán decenas y unidades (di 0 en decenas si es un solo dígito).\n', etiqueta);
    decenas = capturarDigito(sprintf('%s - decenas', etiqueta), config);
    unidades = capturarDigito(sprintf('%s - unidades', etiqueta), config);

    numero = decenas * 10 + unidades;

    if numero < minValor || numero > maxValor
        fprintf('Número fuera de rango (%d-%d). Solicita de nuevo.\n', minValor, maxValor);
        numero = solicitarNumeroPorVoz(etiqueta, maxValor, config, minValor);
    end
end

function digito = capturarDigito(descripcion, config)
    for intento = 1:config.intentos
        try
            [prediccion, info] = reconocedor_digito_microfono(struct( ...
                'rutaModelos', config.rutaModelos, ...
                'rutaCodebook', config.rutaCodebook));
            if isnumeric(prediccion) && isnan(prediccion)
                fprintf('No se detectó voz. Intenta de nuevo (%d/%d).\n', intento, config.intentos);
                continue;
            end

            digito = str2double(prediccion);
            if ~isnan(digito) && digito >= 0 && digito <= 9
                if isfield(info, 'logVerosimilitudes') && ~isempty(info.logVerosimilitudes)
                    puntuacion = max(info.logVerosimilitudes);
                else
                    puntuacion = NaN;
                end
                fprintf('Detectado %d para %s (log-verosimilitud máxima: %.2f).\n', digito, descripcion, puntuacion);
                return;
            else
                fprintf('Resultado no válido (%s). Intenta de nuevo (%d/%d).\n', string(prediccion), intento, config.intentos);
            end
        catch ME
            fprintf('Error al reconocer %s: %s\n', descripcion, ME.message);
            break;
        end
    end

    digito = solicitarManual(descripcion);
end

function numero = solicitarManual(descripcion)
    while true
        numeroStr = input(sprintf('Introduce manualmente %s (0-9): ', descripcion), 's');
        numero = str2double(strtrim(numeroStr));
        if ~isnan(numero) && numero >= 0 && numero <= 9
            break;
        end
        fprintf('Entrada no válida. Debe ser un dígito 0-9.\n');
    end
end

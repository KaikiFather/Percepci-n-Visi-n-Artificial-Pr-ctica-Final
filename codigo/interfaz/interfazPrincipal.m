function interfazPrincipal()
%INTERFAZPRINCIPAL Flujo principal del sistema Cross Math.
%   Captura/carga imagen, detecta cuadrícula, segmenta, reconoce celdas y
%   permite interacción por voz o tarjetas/teclado.

    fprintf('--- Sistema Cross Math Grid ---\n');

    rutaEntrada = input('Ruta de imagen (Enter = webcam/selector, "e" = ejemplo_5x5.jpg): ', 's');
    rutaEntrada = strtrim(rutaEntrada);

    try
        % IMPORTANTE: Enter debe pasar [] para activar webcam/selector
        if isempty(rutaEntrada)
            [imagen, origen] = capturarCuadricula([]);
        elseif strcmpi(rutaEntrada, 'e')
            [imagen, origen] = capturarCuadricula(fullfile('ejemplos', 'ejemplo_5x5.jpg'));
        else
            [imagen, origen] = capturarCuadricula(rutaEntrada);
        end

        fprintf('Imagen cargada desde: %s\n', origen);

        pre = preprocesarImagen(imagen);
        [tabImgWarp, N, ~, ~, debug] = detectarCuadricula(pre);

        % Si N no es fiable, mejor pedirlo que inventarlo y romper todo
        if ~debug.fiable || N < 5 || N > 12
            fprintf('No se pudo estimar N con confianza (N=%d).\n', N);
            Nuser = input('Introduce N manualmente (5..12): ');
            if isempty(Nuser) || ~isscalar(Nuser) || Nuser < 5 || Nuser > 12
                error('N manual inválido.');
            end
            N = Nuser;
        end

        fprintf('Tamaño de cuadrícula: %d x %d\n', N, N);

        [lineasFilas, lineasColumnas] = detectarBordesCeldas(tabImgWarp, N);
        celdas = segmentarCeldas(tabImgWarp, lineasFilas, lineasColumnas);

        tablero = reconocerTablero(celdas);
        tablero.N = N;

        dibujarTablero(tablero, struct());

    catch ME
        fprintf('Error durante el procesamiento: %s\n', ME.message);
        return;
    end

    while true
        fprintf('\nOpciones: [v]oz, [t]arjeta/teclado, [c]omprobar, [s]alir\n');
        opcion = lower(strtrim(input('Selecciona opción: ', 's')));

        switch opcion
            case 'v'
                movimiento = entradaVoz(size(tablero.grid));
                tablero = aplicarMovimiento(tablero, movimiento);
                dibujarTablero(tablero, struct());

            case 't'
                movimiento = entradaTarjetas(size(tablero.grid));
                tablero = aplicarMovimiento(tablero, movimiento);
                dibujarTablero(tablero, struct());

            case 'c'
                resultado = comprobarSolucion(tablero);
                resaltar = construirResaltado(resultado);
                dibujarTablero(tablero, resaltar);

                if isfield(resultado, 'todoCorrecto') && resultado.todoCorrecto
                    fprintf('¡Solución correcta!\n');
                else
                    fprintf('Hay errores en la cuadrícula.\n');
                end

            case 's'
                fprintf('Saliendo...\n');
                break;

            otherwise
                fprintf('Opción no válida.\n');
        end
    end
end

function tablero = aplicarMovimiento(tablero, movimiento)
    if isempty(movimiento) || ~isstruct(movimiento)
        fprintf('Movimiento vacío.\n');
        return;
    end

    [ok, mensaje] = validarMovimiento(tablero, movimiento);
    if ~ok
        fprintf('Movimiento inválido: %s\n', mensaje);
        return;
    end

    tablero.grid{movimiento.fila, movimiento.columna} = movimiento.valor;
    if isfield(tablero, 'tipos')
        tablero.tipos{movimiento.fila, movimiento.columna} = 'usuario';
    end
end

function resaltar = construirResaltado(resultado)
    resaltar = struct('errores', [], 'filas', [], 'columnas', []);
    if ~isfield(resultado, 'filasCorrectas') || ~isfield(resultado, 'columnasCorrectas')
        return;
    end
    resaltar.filas = find(~resultado.filasCorrectas);
    resaltar.columnas = find(~resultado.columnasCorrectas);
end

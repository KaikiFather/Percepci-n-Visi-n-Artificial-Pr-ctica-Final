function interfazPrincipal()
%INTERFAZPRINCIPAL Flujo principal del sistema Cross Math.
%   Captura/carga imagen, detecta cuadrícula, segmenta, reconoce celdas y
%   permite interacción por voz o tarjetas/teclado.

    fprintf('--- Sistema Cross Math Grid ---\n');

    rutaEntrada = input('Ruta de la imagen (Enter para usar webcam o ejemplo_5x5.jpg): ', 's');
    if isempty(rutaEntrada)
        rutaEntrada = fullfile('ejemplos', 'ejemplo_5x5.jpg');
    end

    try
        [imagen, origen] = capturarCuadricula(rutaEntrada);
        fprintf('Imagen cargada desde: %s\n', origen);

        pre = preprocesarImagen(imagen);
        [tabImgWarp, N, ~, ~] = detectarCuadricula(pre);
        fprintf('Tamaño de cuadrícula estimado: %d x %d\n', N, N);

        [lineasFilas, lineasColumnas] = detectarBordesCeldas(tabImgWarp, N);
        celdas = segmentarCeldas(tabImgWarp, lineasFilas, lineasColumnas);

        tablero = reconocerTablero(celdas);
        tablero.N = N;
        dibujarTablero(tablero, struct());
    catch ME
        fprintf('Error durante el procesamiento de la imagen: %s\n', ME.message);
        return;
    end

    while true
        fprintf('\nOpciones: [v]oz, [t]arjeta/teclado, [c]omprobar, [s]alir\n');
        opcion = lower(input('Selecciona opción: ', 's'));
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
                if resultado.todoCorrecto
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
    resaltar = struct('errores', []);
    if ~isfield(resultado, 'filasCorrectas') || ~isfield(resultado, 'columnasCorrectas')
        return;
    end
    filasErr = find(~resultado.filasCorrectas);
    colsErr = find(~resultado.columnasCorrectas);
    resaltar.filas = filasErr;
    resaltar.columnas = colsErr;
end

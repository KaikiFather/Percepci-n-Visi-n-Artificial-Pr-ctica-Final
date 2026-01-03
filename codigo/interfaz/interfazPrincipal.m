function interfazPrincipal()
%INTERFAZPRINCIPAL Flujo principal del sistema.

    fprintf('--- Sistema Cross Math Grid ---\n');

    ruta = input('Ruta de la imagen (Enter para usar ejemplo_5x5.jpg): ', 's');
    if isempty(ruta)
        ruta = fullfile('ejemplos', 'ejemplo_5x5.jpg');
    end

    [imagen, origen] = capturarCuadricula(ruta);
    fprintf('Imagen cargada desde: %s\n', origen);

    pre = preprocesarImagen(imagen);
    [recorte, ~] = detectarCuadricula(pre);

    [lineasFilas, lineasColumnas] = detectarBordesCeldas(recorte);
    celdas = segmentarCeldas(recorte, lineasFilas, lineasColumnas);

    tablero = construirTablero(celdas);
    dibujarTablero(tablero);

    while true
        fprintf('\nOpciones: [v]oz, [t]arjeta, [c]omprobar, [s]alir\n');
        opcion = lower(input('Selecciona opción: ', 's'));
        switch opcion
            case 'v'
                movimiento = entradaVoz(size(tablero.grid));
                tablero = aplicarMovimiento(tablero, movimiento);
                dibujarTablero(tablero);
            case 't'
                movimiento = entradaTarjetas(size(tablero.grid));
                tablero = aplicarMovimiento(tablero, movimiento);
                dibujarTablero(tablero);
            case 'c'
                resultado = comprobarSolucion(tablero);
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

function tablero = construirTablero(celdas)
    [filas, cols] = size(celdas);
    grid = cell(filas, cols);

    for r = 1:filas
        for c = 1:cols
            celda = celdas{r, c};
            if isempty(celda)
                grid{r, c} = '';
                continue;
            end
            resultado = reconocerCelda(celda);
            grid{r, c} = resultado.valor;
        end
    end

    tablero = struct('grid', grid);
end

function tablero = aplicarMovimiento(tablero, movimiento)
    [ok, mensaje] = validarMovimiento(tablero, movimiento);
    if ~ok
        fprintf('Movimiento inválido: %s\n', mensaje);
        return;
    end

    tablero.grid{movimiento.fila, movimiento.columna} = movimiento.valor;
end

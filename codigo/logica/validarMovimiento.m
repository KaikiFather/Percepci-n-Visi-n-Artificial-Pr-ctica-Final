function [esValido, mensaje] = validarMovimiento(tablero, movimiento)
%VALIDARMOVIMIENTO Comprueba si un movimiento es válido en el tablero.
%   tablero: struct con campo grid (cell array).
%   movimiento: struct con fila, columna y valor.

    esValido = false;
    mensaje = '';

    if ~isfield(tablero, 'grid')
        mensaje = 'El tablero no tiene formato válido.';
        return;
    end

    if ~all(isfield(movimiento, {'fila', 'columna', 'valor'}))
        mensaje = 'El movimiento no tiene los campos requeridos (fila, columna, valor).';
        return;
    end

    filas = size(tablero.grid, 1);
    cols = size(tablero.grid, 2);

    if movimiento.fila < 1 || movimiento.fila > filas || ...
            movimiento.columna < 1 || movimiento.columna > cols
        mensaje = 'La posición está fuera del tablero.';
        return;
    end

    valor = movimiento.valor;
    if isempty(valor) || ~all(isstrprop(valor, 'digit'))
        mensaje = 'El valor debe ser numérico.';
        return;
    end

    celdaActual = tablero.grid{movimiento.fila, movimiento.columna};
    if ~isempty(celdaActual) && ~strcmp(celdaActual, '')
        mensaje = 'La celda ya contiene un valor.';
        return;
    end

    esValido = true;
end

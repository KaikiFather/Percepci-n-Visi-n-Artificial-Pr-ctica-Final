function [esValido, mensaje] = validarMovimiento(tablero, movimiento)
%VALIDARMOVIMIENTO Comprueba si un movimiento es válido en el tablero.
%   tablero: struct con campos grid, tipos y fijas.
%   movimiento: struct con fila, columna y valor.

    esValido = false;
    mensaje = '';

    if ~isfield(tablero, 'grid')
        mensaje = 'El tablero no tiene formato válido.';
        return;
    end

    if ~isfield(movimiento, 'fila') || ~isfield(movimiento, 'columna') || ~isfield(movimiento, 'valor')
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

    valor = string(movimiento.valor);
    if strlength(valor) == 0
        mensaje = 'El valor no puede ser vacío.';
        return;
    end

    permitido = regexp(valor, '^[0-9]{1,2}$|^[+\-*/=]$');
    if isempty(permitido)
        mensaje = 'El valor debe ser un número (0-99) o un operador + - * / =.';
        return;
    end

    % Comprobar coherencia con tipo detectado inicialmente
    if isfield(tablero, 'tipos')
        tipoInicial = tablero.tipos{movimiento.fila, movimiento.columna};
        if strcmp(tipoInicial, 'negra')
            mensaje = 'La celda es negra y no admite movimientos.';
            return;
        end
        if strcmp(tipoInicial, 'operador') && all(isstrprop(valor, 'digit'))
            mensaje = 'La celda es de operador y no admite números.';
            return;
        end
        if strcmp(tipoInicial, 'numero') && ~all(isstrprop(valor, 'digit'))
            mensaje = 'La celda es numérica y no admite operadores.';
            return;
        end
    end

    % No permitir sobreescribir casillas fijas
    if isfield(tablero, 'fijas') && tablero.fijas(movimiento.fila, movimiento.columna)
        mensaje = 'La celda es fija y no puede modificarse.';
        return;
    end

    esValido = true;
end

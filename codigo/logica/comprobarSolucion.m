function resultado = comprobarSolucion(tablero)
%COMPROBARSOLUCION Comprueba todas las filas y columnas.
%   resultado = comprobarSolucion(tablero)

    if ~isfield(tablero, 'grid')
        error('El tablero no tiene el campo grid.');
    end

    filas = size(tablero.grid, 1);
    cols = size(tablero.grid, 2);

    resultado = struct();
    resultado.filasCorrectas = true(filas, 1);
    resultado.columnasCorrectas = true(cols, 1);
    resultado.detalleFilas = cell(filas, 1);
    resultado.detalleColumnas = cell(cols, 1);

    for f = 1:filas
        [ok, detalle] = evaluarFila(tablero, f);
        resultado.filasCorrectas(f) = ok;
        resultado.detalleFilas{f} = detalle;
    end

    for c = 1:cols
        [ok, detalle] = evaluarColumna(tablero, c);
        resultado.columnasCorrectas(c) = ok;
        resultado.detalleColumnas{c} = detalle;
    end

    resultado.todoCorrecto = all(resultado.filasCorrectas) && all(resultado.columnasCorrectas);
end

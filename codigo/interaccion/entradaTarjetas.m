function movimiento = entradaTarjetas(tamano)
%ENTRADATARJETAS Simula entrada con tarjetas mediante consola.
%   movimiento = entradaTarjetas(tamano)

    if nargin < 1
        tamano = [0 0];
    end

    fprintf('Entrada por tarjetas simulada.\n');
    
    % Leer y validar fila como entrada numérica
    filaValida = false;
    while ~filaValida
        filaStr = input(sprintf('Fila (1-%d): ', tamano(1)), 's');
        filaNum = str2double(filaStr);
        if ~isempty(filaStr) && ~isnan(filaNum)
            fila = filaNum;
            filaValida = true;
        else
            fprintf('Por favor, introduzca un valor numérico válido para la fila.\n');
        end
    end

    % Leer y validar columna como entrada numérica
    columnaValida = false;
    while ~columnaValida
        columnaStr = input(sprintf('Columna (1-%d): ', tamano(2)), 's');
        columnaNum = str2double(columnaStr);
        if ~isempty(columnaStr) && ~isnan(columnaNum)
            columna = columnaNum;
            columnaValida = true;
        else
            fprintf('Por favor, introduzca un valor numérico válido para la columna.\n');
        end
    end
    
    valor = input('Valor (número u operador): ', 's');

    movimiento = struct('fila', fila, 'columna', columna, 'valor', valor, 'origen', 'tarjeta');
end

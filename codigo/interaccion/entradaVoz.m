function movimiento = entradaVoz(tamano)
%ENTRADAVOZ Simula entrada por voz mediante consola.
%   movimiento = entradaVoz(tamano)
%   Devuelve un struct con fila, columna y valor.

    if nargin < 1
        tamano = [0 0];
    end

    fprintf('Entrada por voz simulada.\n');
    
    % Solicitar fila con validación de entrada numérica
    while true
        filaStr = input(sprintf('Fila (1-%d): ', tamano(1)), 's');
        filaStr = strtrim(filaStr);
        if isempty(filaStr)
            fprintf('Entrada vacía. Por favor, introduzca un número para la fila.\n');
            continue;
        end
        filaNum = str2double(filaStr);
        if isnan(filaNum)
            fprintf('Entrada no válida. Por favor, introduzca un número para la fila.\n');
            continue;
        end
        fila = filaNum;
        break;
    end
    
    % Solicitar columna con validación de entrada numérica
    while true
        columnaStr = input(sprintf('Columna (1-%d): ', tamano(2)), 's');
        columnaStr = strtrim(columnaStr);
        if isempty(columnaStr)
            fprintf('Entrada vacía. Por favor, introduzca un número para la columna.\n');
            continue;
        end
        columnaNum = str2double(columnaStr);
        if isnan(columnaNum)
            fprintf('Entrada no válida. Por favor, introduzca un número para la columna.\n');
            continue;
        end
        columna = columnaNum;
        break;
    end
    
    valor = input('Valor (número u operador): ', 's');

    movimiento = struct('fila', fila, 'columna', columna, 'valor', valor, 'origen', 'voz');
end

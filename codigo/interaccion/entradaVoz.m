function movimiento = entradaVoz(tamano)
%ENTRADAVOZ Simula entrada por voz mediante consola.
%   movimiento = entradaVoz(tamano)
%   Devuelve un struct con fila, columna y valor.

    if nargin < 1
        tamano = [0 0];
    end

    fprintf('Entrada por voz simulada.\n');
    fila = input(sprintf('Fila (1-%d): ', tamano(1)));
    columna = input(sprintf('Columna (1-%d): ', tamano(2)));
    valor = input('Valor numérico: ', 's');

    movimiento = struct('fila', fila, 'columna', columna, 'valor', valor, 'origen', 'voz');
end

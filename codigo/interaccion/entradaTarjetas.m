function movimiento = entradaTarjetas(tamano)
%ENTRADATARJETAS Simula entrada con tarjetas mediante consola.
%   movimiento = entradaTarjetas(tamano)

    if nargin < 1
        tamano = [0 0];
    end

    fprintf('Entrada por tarjetas simulada.\n');
    fila = input(sprintf('Fila (1-%d): ', tamano(1)));
    columna = input(sprintf('Columna (1-%d): ', tamano(2)));
    valor = input('Valor numérico: ', 's');

    movimiento = struct('fila', fila, 'columna', columna, 'valor', valor, 'origen', 'tarjeta');
end

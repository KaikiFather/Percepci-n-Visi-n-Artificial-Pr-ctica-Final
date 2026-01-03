function dibujarTablero(tablero)
%DIBUJARTABLERO Dibuja la cuadrícula en una figura.
%   dibujarTablero(tablero)

    if ~isfield(tablero, 'grid')
        error('El tablero no tiene el campo grid.');
    end

    grid = tablero.grid;
    filas = size(grid, 1);
    cols = size(grid, 2);

    figura = figure('Name', 'Cross Math Grid', 'NumberTitle', 'off');
    axis([0 cols 0 filas]);
    axis equal off;
    hold on;

    for r = 0:filas
        plot([0, cols], [r, r], 'k');
    end
    for c = 0:cols
        plot([c, c], [0, filas], 'k');
    end

    for r = 1:filas
        for c = 1:cols
            valor = grid{r, c};
            if isempty(valor)
                valor = '';
            end
            text(c-0.5, filas-r+0.5, valor, 'HorizontalAlignment', 'center', ...
                'FontSize', 12, 'FontWeight', 'bold');
        end
    end

    hold off;
    drawnow;
end

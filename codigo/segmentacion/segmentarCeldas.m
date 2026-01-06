function celdas = segmentarCeldas(img, lineasFilas, lineasColumnas, offset)
%SEGMENTARCELDAS Divide la cuadrícula en celdas y las normaliza a 64x64.
%   celdas = segmentarCeldas(img, lineasFilas, lineasColumnas, offset)
%   Si no se proporcionan líneas, se reparte de forma uniforme asumiendo
%   cuadrícula cuadrada.

    if nargin < 4
        offset = 4;
    end

    gray = im2gray(img);

    if nargin < 3 || isempty(lineasFilas) || isempty(lineasColumnas)
        N = 9;
        lineasFilas = round(linspace(1, size(gray,1), N+1));
        lineasColumnas = round(linspace(1, size(gray,2), N+1));
    else
        lineasFilas = sort(lineasFilas);
        lineasColumnas = sort(lineasColumnas);
    end

    filas = numel(lineasFilas) - 1;
    cols = numel(lineasColumnas) - 1;
    celdas = cell(filas, cols);
    warningIssued = false;

    for r = 1:filas
        for c = 1:cols
            cellWidth = lineasColumnas(c+1) - lineasColumnas(c);
            cellHeight = lineasFilas(r+1) - lineasFilas(r);

            maxOffsetX = floor((cellWidth - 1) / 2);
            maxOffsetY = floor((cellHeight - 1) / 2);

            effectiveOffsetX = min(offset, maxOffsetX);
            effectiveOffsetY = min(offset, maxOffsetY);

            if ~warningIssued && (effectiveOffsetX < offset || effectiveOffsetY < offset)
                warning('segmentarCeldas:OffsetTooLarge', ...
                    'Offset solicitado (%g) excede la mitad del tamaño de celda en algunas celdas. Se ha reducido automáticamente.', ...
                    offset);
                warningIssued = true;
            end

            x1 = lineasColumnas(c) + effectiveOffsetX;
            x2 = lineasColumnas(c+1) - effectiveOffsetX;
            y1 = lineasFilas(r) + effectiveOffsetY;
            y2 = lineasFilas(r+1) - effectiveOffsetY;

            w = max(x2 - x1, 1);
            h = max(y2 - y1, 1);
            rect = [x1, y1, w, h];
            recorte = imcrop(gray, rect);

            if isempty(recorte)
                celdas{r, c} = [];
                continue;
            end

            recorte = imresize(recorte, [64 64], 'nearest');
            celdas{r, c} = recorte;
        end
    end
end

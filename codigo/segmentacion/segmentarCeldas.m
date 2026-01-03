function celdas = segmentarCeldas(img, lineasFilas, lineasColumnas, offset)
%SEGMENTARCELDAS Divide la cuadrícula en celdas.
%   celdas = segmentarCeldas(img, lineasFilas, lineasColumnas, offset)

    if nargin < 4
        offset = 3;
    end

    gray = im2gray(img);

    if nargin >= 3 && ~isempty(lineasFilas) && ~isempty(lineasColumnas)
        lineasFilas = sort(lineasFilas);
        lineasColumnas = sort(lineasColumnas);
        filas = numel(lineasFilas) - 1;
        cols = numel(lineasColumnas) - 1;
        celdas = cell(filas, cols);
        for r = 1:filas
            for c = 1:cols
                % Calcular las dimensiones base de la celda
                cellWidth = lineasColumnas(c+1) - lineasColumnas(c);
                cellHeight = lineasFilas(r+1) - lineasFilas(r);

                % Limitar el offset para que no exceda la mitad de la celda
                maxOffsetX = floor((cellWidth - 1) / 2);
                maxOffsetY = floor((cellHeight - 1) / 2);

                effectiveOffsetX = min(offset, maxOffsetX);
                effectiveOffsetY = min(offset, maxOffsetY);

                % Avisar si el offset solicitado es demasiado grande y ha sido reducido
                if effectiveOffsetX < offset || effectiveOffsetY < offset
                    warning('segmentarCeldas:OffsetTooLarge', ...
                        'Offset reducido de %g a (%g, %g) en la celda (fila %d, columna %d).', ...
                        offset, effectiveOffsetX, effectiveOffsetY, r, c);
                end

                x1 = lineasColumnas(c) + effectiveOffsetX;
                x2 = lineasColumnas(c+1) - effectiveOffsetX;
                y1 = lineasFilas(r) + effectiveOffsetY;
                y2 = lineasFilas(r+1) - effectiveOffsetY;

                w = max(x2 - x1, 1);
                h = max(y2 - y1, 1);
                rect = [x1, y1, w, h];
                celdas{r, c} = imcrop(gray, rect);
            end
        end
        return;
    end

    bin = gray > 20;
    bin = imcomplement(bin);
    relleno = imfill(bin, 100000);
    relleno = imcomplement(relleno);
    relleno = imfill(relleno, 'holes');

    [labeledImage, numLabels] = bwlabel(relleno);
    celdas = cell(numLabels, 1);
    stats = regionprops(labeledImage, 'BoundingBox');
    for k = 1:numLabels
        bb = stats(k).BoundingBox;

        x = floor(bb(1)) + offset;
        y = floor(bb(2)) + offset;
        w = floor(bb(3)) - (offset * 2);
        h = floor(bb(4)) - (offset * 2);

        if w > 0 && h > 0
            rect = [x, y, w, h];
            celdas{k} = imcrop(gray, rect);
        else
            celdas{k} = [];
        end
    end
end

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
                x1 = lineasColumnas(c) + offset;
                x2 = lineasColumnas(c+1) - offset;
                y1 = lineasFilas(r) + offset;
                y2 = lineasFilas(r+1) - offset;

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

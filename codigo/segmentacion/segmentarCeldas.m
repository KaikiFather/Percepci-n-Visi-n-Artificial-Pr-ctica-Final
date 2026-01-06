function celdas = segmentarCeldas(tabImgWarp, lineasFilas, lineasColumnas)
%SEGMENTARCELDAS Recorta celdas según líneas y normaliza a 64x64.
%   celdas = segmentarCeldas(tabImgWarp, lineasFilas, lineasColumnas)

    if nargin < 3
        error('segmentarCeldas requiere (tabImgWarp, lineasFilas, lineasColumnas).');
    end

    tabGray = im2gray(tabImgWarp);
    H = size(tabGray,1);
    W = size(tabGray,2);

    lineasFilas = sort(lineasFilas(:));
    lineasColumnas = sort(lineasColumnas(:));

    N = min(numel(lineasFilas), numel(lineasColumnas)) - 1;
    if N < 1
        error('segmentarCeldas: no hay líneas suficientes.');
    end

    celdas = cell(N,N);

    padFrac = 0.08; % quita líneas de rejilla
    for i=1:N
        for j=1:N
            y1 = lineasFilas(i);
            y2 = lineasFilas(i+1);
            x1 = lineasColumnas(j);
            x2 = lineasColumnas(j+1);

            h = max(1, y2-y1);
            w = max(1, x2-x1);
            pad = max(1, round(min(h,w)*padFrac));

            yy1 = min(max(y1+pad,1),H);
            yy2 = min(max(y2-pad,1),H);
            xx1 = min(max(x1+pad,1),W);
            xx2 = min(max(x2-pad,1),W);

            if yy2 <= yy1 || xx2 <= xx1
                roi = tabGray(y1:y2, x1:x2);
            else
                roi = tabGray(yy1:yy2, xx1:xx2);
            end

            celdas{i,j} = imresize(roi, [64 64]);
        end
    end
end

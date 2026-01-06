function resultado = reconocerCelda(imagen, plantillasNumero, plantillasOperador)
%RECONOCERCELDA Clasifica una celda como negra, vacía, número u operador.
%   resultado = reconocerCelda(imagen, plantillasNumero, plantillasOperador)
%   Devuelve struct con campos: tipo, valor, puntuacion.

    if nargin < 2
        plantillasNumero = {};
    end
    if nargin < 3
        plantillasOperador = {};
    end

    imgGray = im2double(im2gray(imagen));
    imgGray = imresize(imgGray, [64 64]);

    % Heurística de celda negra
    if mean(imgGray(:)) < 0.1
        resultado = struct('tipo', 'negra', 'valor', '#', 'puntuacion', 1);
        return;
    end

    % Binarización y ruido
    umbral = graythresh(imgGray);
    bin = imbinarize(imgGray, umbral * 0.8);
    bin = imcomplement(bin);
    bin = bwareaopen(bin, 10);

    porcentajeActivos = nnz(bin) / numel(bin);
    if porcentajeActivos < 0.02
        resultado = struct('tipo', 'vacio', 'valor', '', 'puntuacion', 0);
        return;
    end

    % Intentar operador primero
    [idxOp, puntOp, etiquetaOp] = clasificarOperador(imgGray, plantillasOperador);
    [idxNum, puntNum, etiquetaNum] = clasificarNumero(imgGray, plantillasNumero);

    maxOp = max(puntOp);
    maxNum = max(puntNum);

    if maxOp >= maxNum
        resultado = struct('tipo', 'operador', 'valor', etiquetaOp, 'puntuacion', maxOp);
    else
        resultado = struct('tipo', 'numero', 'valor', etiquetaNum, 'puntuacion', maxNum);
    end
end

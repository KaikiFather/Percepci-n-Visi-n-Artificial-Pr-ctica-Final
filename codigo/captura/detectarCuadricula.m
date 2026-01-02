function [recorte, bbox] = detectarCuadricula(preprocesado)
%DETECTARCUADRICULA Detecta la región principal de la cuadrícula.
%   [recorte, bbox] = detectarCuadricula(preprocesado)
%   preprocesado puede ser una imagen o una estructura de preprocesado.

    if nargin < 1
        error('Se requiere una imagen o estructura de preprocesado.');
    end

    if isstruct(preprocesado)
        gray = preprocesado.gray;
        binaria = preprocesado.binaria;
    else
        gray = im2gray(preprocesado);
        binaria = imbinarize(gray, 'adaptive', ...
            'ForegroundPolarity', 'dark', 'Sensitivity', 0.45);
        binaria = imcomplement(binaria);
        binaria = imfill(binaria, 'holes');
    end

    regiones = regionprops(binaria, 'Area', 'BoundingBox');
    if isempty(regiones)
        recorte = gray;
        bbox = [1 1 size(gray,2) size(gray,1)];
        return;
    end

    [~, idx] = max([regiones.Area]);
    bbox = regiones(idx).BoundingBox;

    x = max(floor(bbox(1)), 1);
    y = max(floor(bbox(2)), 1);
    w = min(floor(bbox(3)), size(gray, 2) - x);
    h = min(floor(bbox(4)), size(gray, 1) - y);

    recorte = imcrop(gray, [x, y, w, h]);
end

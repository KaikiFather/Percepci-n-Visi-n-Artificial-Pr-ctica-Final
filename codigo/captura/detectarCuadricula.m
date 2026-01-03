function [recorte, bbox] = detectarCuadricula(preprocesado)
%DETECTARCUADRICULA Detecta la región principal de la cuadrícula.
%   [recorte, bbox] = detectarCuadricula(preprocesado)
%   preprocesado debe ser una estructura de preprocesado con campos:
%       - gray: imagen en escala de grises
%       - binaria: imagen binaria procesada

    if nargin < 1
        error('Se requiere una estructura de preprocesado.');
    end

    if ~isstruct(preprocesado)
        error('El argumento preprocesado debe ser una estructura con campos gray y binaria.');
    end

    gray = preprocesado.gray;
    binaria = preprocesado.binaria;

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

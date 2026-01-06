function [mejorIndice, puntuaciones, etiqueta] = clasificarOperador(imagen, plantillas, etiquetas)
%CLASIFICAROPERADOR Template matching para operadores +-*/=

    if nargin < 2 || isempty(plantillas)
        [plantillas, etiquetas] = cargarPlantillasOperadores();
    end
    if nargin < 3 || isempty(etiquetas)
        etiquetas = {'+','-','*','/','='};
    end

    imagenPrep = prepararImagen(imagen);

    numPlantillas = length(plantillas);
    puntuaciones = zeros(numPlantillas, 1);

    for k = 1:numPlantillas
        plantillaActual = im2double(imresize(plantillas{k}, size(imagenPrep)));
        try
            c = normxcorr2(plantillaActual, imagenPrep);
            puntuaciones(k) = max(c(:));
        catch
            puntuaciones(k) = corr2(plantillaActual, imagenPrep);
        end
    end

    [~, mejorIndice] = max(puntuaciones);
    etiqueta = etiquetas{mejorIndice};
end

function imgBin = prepararImagen(img)
    img = im2double(im2gray(img));
    img = imresize(img, [64 64]);
    img = imadjust(img);
    umbral = graythresh(img);
    imgBin = imbinarize(img, umbral * 0.8);
    imgBin = imcomplement(imgBin);
    imgBin = imclearborder(imgBin);
    imgBin = bwareaopen(imgBin, 10);
    imgBin = imgaussfilt(double(imgBin), 0.5);
end

function [mejorIndice, puntuaciones] = clasificarOperador(imagen, plantillas)
    if nargin < 2
        plantillas = {
            im2gray(imread('patrones/mas.png')) > 20,...
            im2gray(imread('patrones/menos.png')) > 20,...
            im2gray(imread('patrones/mul.png')) > 20,...
            im2gray(imread('patrones/div.png')) > 20,...
            im2gray(imread('patrones/igual.png')) > 20
            };
    end
    numPlantillas = length(plantillas);
    puntuaciones = zeros(numPlantillas, 1);

    imagen = im2double(imagen);
    
    for k = 1:numPlantillas
        plantillaActual = im2double(plantillas{k});
        try
            c = normxcorr2(plantillaActual, imagen);
            puntuaciones(k) = max(c(:));
        catch ME
            warning('Error comparando plantilla %d: %s', k, ME.message);
            puntuaciones(k) = -Inf;
        end
    end

    [~, mejorIndice] = max(puntuaciones);
end
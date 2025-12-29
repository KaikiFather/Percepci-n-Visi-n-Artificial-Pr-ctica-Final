function [mejorIndice, puntuaciones] = clasificarNumero(imagen, plantillas)
    if nargin < 2
        plantillas = {
            im2gray(imread('patrones/1.png')) > 20,...
            im2gray(imread('patrones/2.png')) > 20,...
            im2gray(imread('patrones/3.png')) > 20,...
            im2gray(imread('patrones/4.png')) > 20,...
            im2gray(imread('patrones/5.png')) > 20,...
            im2gray(imread('patrones/6.png')) > 20,...
            im2gray(imread('patrones/7.png')) > 20,...
            im2gray(imread('patrones/8.png')) > 20,...
            im2gray(imread('patrones/9.png')) > 20,...
            im2gray(imread('patrones/0.png')) > 20
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
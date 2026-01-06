function [mejorIndice, puntuaciones, etiqueta] = clasificarNumero(imagen, plantillas, etiquetas)
%CLASIFICARNUMERO Realiza template matching para dígitos 0-9 y compuestos.
%   [mejorIndice, puntuaciones, etiqueta] = clasificarNumero(imagen, plantillas, etiquetas)
%   Si no se proporcionan plantillas, se generan automáticamente.

    if nargin < 2 || isempty(plantillas)
        [plantillas, etiquetas] = cargarPlantillasDigitos();
    end
    if nargin < 3 || isempty(etiquetas)
        etiquetas = arrayfun(@num2str, 0:numel(plantillas)-1, 'UniformOutput', false);
    end

    imagenPrep = prepararImagen(imagen);
    comps = bwconncomp(imagenPrep > 0.3);

    if comps.NumObjects >= 2
        % Dos componentes => intentar dos dígitos
        bounding = regionprops(comps, 'BoundingBox');
        [~, orden] = sort(arrayfun(@(b) b.BoundingBox(1), bounding));
        recortes = cell(1,2);
        for k = 1:min(2, numel(orden))
            bb = bounding(orden(k)).BoundingBox;
            recortes{k} = imcrop(imagenPrep, bb);
            recortes{k} = imresize(recortes{k}, [64 64]);
        end
        etiquetasRec = cell(1, numel(recortes));
        for k = 1:numel(recortes)
            [~, ~, etiquetasRec{k}] = clasificarNumero(recortes{k}, plantillas, etiquetas); %#ok<AGROW>
        end
        etiqueta = strjoin(etiquetasRec, '');
        mejorIndice = 1;
        puntuaciones = ones(numel(plantillas), 1); % marcador
        return;
    end

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
    imgBin = bwareaopen(imgBin, 15);
    imgBin = imgaussfilt(double(imgBin), 0.5);
end

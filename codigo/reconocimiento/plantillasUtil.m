function [imgs, etiquetas] = cargarPlantillasDigitos()
%CARGARPLANTILLASDIGITOS Devuelve plantillas de dígitos 0-9, generándolas si no existen.
    baseDir = fullfile('codigo', 'reconocimiento', 'plantillas', 'digitos');
    if ~exist(baseDir, 'dir'); mkdir(baseDir); end

    etiquetas = arrayfun(@num2str, 0:9, 'UniformOutput', false);
    imgs = cell(numel(etiquetas), 1);
    for k = 1:numel(etiquetas)
        archivo = fullfile(baseDir, sprintf('%s.png', etiquetas{k}));
        if isfile(archivo)
            imgs{k} = im2double(imread(archivo));
        else
            plantilla = generarDigitoBasico(str2double(etiquetas{k}));
            imwrite(plantilla, archivo);
            imgs{k} = plantilla;
        end
        imgs{k} = im2gray(imgs{k});
    end
end

function [imgs, etiquetas] = cargarPlantillasOperadores()
%CARGARPLANTILLASOPERADORES Devuelve plantillas de operadores +-x÷=.
    baseDir = fullfile('codigo', 'reconocimiento', 'plantillas', 'operadores');
    if ~exist(baseDir, 'dir'); mkdir(baseDir); end

    etiquetas = {'+', '-', '*', '/', '='};
    nombres = {'mas','menos','mul','div','igual'};
    imgs = cell(numel(etiquetas), 1);
    for k = 1:numel(etiquetas)
        archivo = fullfile(baseDir, sprintf('%s.png', nombres{k}));
        if isfile(archivo)
            imgs{k} = im2double(imread(archivo));
        else
            plantilla = generarOperadorBasico(etiquetas{k});
            imwrite(plantilla, archivo);
            imgs{k} = plantilla;
        end
        imgs{k} = im2gray(imgs{k});
    end
end

function img = generarDigitoBasico(d)
    img = zeros(64, 64);
    grosor = 6;
    padding = 12;
    switch d
        case 0
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
        case 1
            img = dibujarLinea(img, [32 padding], [32 64-padding], grosor);
        case 2
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
            img(padding+round((64-2*padding)/2):padding+round((64-2*padding)/2)+grosor, :) = 1;
            img(32:end, padding:padding+grosor) = 0;
            img(1:32, end-padding-grosor:end-padding) = 0;
        case 3
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
            img(padding+round((64-2*padding)/2):padding+round((64-2*padding)/2)+grosor, :) = 1;
            img(:, padding:padding+grosor) = 0;
        case 4
            img = dibujarLinea(img, [padding 32], [64-padding 32], grosor);
            img = dibujarLinea(img, [64-padding 32], [64-padding padding], grosor);
            img = dibujarLinea(img, [padding 32], [padding 64-padding], grosor);
        case 5
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
            img(padding+round((64-2*padding)/2):padding+round((64-2*padding)/2)+grosor, :) = 1;
            img(32:end, end-padding-grosor:end-padding) = 0;
            img(1:32, padding:padding+grosor) = 0;
        case 6
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
            img(padding+round((64-2*padding)/2):padding+round((64-2*padding)/2)+grosor, :) = 1;
            img(1:32, padding:padding+grosor) = 0;
        case 7
            img = dibujarRectangulo(img, padding, padding, 64-padding, padding+grosor, grosor);
            img = dibujarLinea(img, [64-padding padding], [32 64-padding], grosor);
        case 8
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
            img(padding+round((64-2*padding)/2):padding+round((64-2*padding)/2)+grosor, :) = 1;
        case 9
            img = dibujarRectangulo(img, padding, padding, 64-padding, 64-padding, grosor);
            img(padding+round((64-2*padding)/2):padding+round((64-2*padding)/2)+grosor, :) = 1;
            img(32:end, padding:padding+grosor) = 0;
        otherwise
            img = zeros(64,64);
    end
    img = imgaussfilt(img, 1);
end

function img = generarOperadorBasico(simbolo)
    img = zeros(64,64);
    grosor = 7;
    switch simbolo
        case '+'
            img = dibujarLinea(img, [32 10], [32 54], grosor);
            img = dibujarLinea(img, [10 32], [54 32], grosor);
        case '-'
            img = dibujarLinea(img, [12 32], [52 32], grosor);
        case '*'
            img = dibujarLinea(img, [16 16], [48 48], grosor);
            img = dibujarLinea(img, [16 48], [48 16], grosor);
        case '/'
            img = dibujarLinea(img, [16 48], [48 16], grosor);
        case '='
            img = dibujarLinea(img, [12 24], [52 24], grosor);
            img = dibujarLinea(img, [12 40], [52 40], grosor);
    end
    img = imgaussfilt(img, 0.8);
end

function img = dibujarRectangulo(img, x1, y1, x2, y2, grosor)
    img = dibujarLinea(img, [x1 y1], [x2 y1], grosor);
    img = dibujarLinea(img, [x2 y1], [x2 y2], grosor);
    img = dibujarLinea(img, [x2 y2], [x1 y2], grosor);
    img = dibujarLinea(img, [x1 y2], [x1 y1], grosor);
end

function img = dibujarLinea(img, p1, p2, grosor)
    % Bresenham aproximado con expansión de grosor
    x1 = round(p1(1)); y1 = round(p1(2));
    x2 = round(p2(1)); y2 = round(p2(2));
    numPuntos = max(abs([x2 - x1, y2 - y1])) + 1;
    xs = round(linspace(x1, x2, numPuntos));
    ys = round(linspace(y1, y2, numPuntos));
    for k = 1:numPuntos
        img = trazarDisco(img, xs(k), ys(k), grosor);
    end
end

function img = trazarDisco(img, x, y, radio)
    [X, Y] = meshgrid(1:size(img,2), 1:size(img,1));
    mask = (X - x).^2 + (Y - y).^2 <= (radio/2)^2;
    img(mask) = 1;
end

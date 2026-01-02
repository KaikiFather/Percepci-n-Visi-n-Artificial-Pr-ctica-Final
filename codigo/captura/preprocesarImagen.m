function resultado = preprocesarImagen(imagen)
%PREPROCESARIMAGEN Convierte y realza la imagen para detección de cuadrícula.
%   resultado = preprocesarImagen(imagen)
%   Devuelve una estructura con campos: gray, binaria, bordes.

    if nargin < 1
        error('Se requiere una imagen de entrada.');
    end

    gray = im2gray(imagen);
    gray = im2double(gray);
    gray = imgaussfilt(gray, 1);

    binaria = imbinarize(gray, 'adaptive', ...
        'ForegroundPolarity', 'dark', 'Sensitivity', 0.45);
    binaria = imcomplement(binaria);
    binaria = imfill(binaria, 'holes');

    bordes = edge(gray, 'Canny');

    resultado = struct('gray', gray, 'binaria', binaria, 'bordes', bordes);
end

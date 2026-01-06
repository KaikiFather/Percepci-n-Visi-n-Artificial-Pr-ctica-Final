function resultado = preprocesarImagen(imagen)
%PREPROCESARIMAGEN Convierte y realza la imagen para detección de cuadrícula.
%   resultado = preprocesarImagen(imagen)
%   Devuelve una estructura con campos: gray, binaria, bordes.

    if nargin < 1
        error('Se requiere una imagen de entrada.');
    end

    gray = im2gray(imagen);
    gray = im2double(gray);
    gray = adapthisteq(gray, 'ClipLimit', 0.02);
    gray = imgaussfilt(gray, 1);

    % Mejorar contraste de líneas de rejilla
    binaria = imbinarize(gray, 'adaptive', ...
        'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);
    binaria = imcomplement(binaria);
    binaria = bwareaopen(binaria, 50);
    binaria = imfill(binaria, 'holes');

    bordes = edge(gray, 'Canny', [0.05 0.2]);

    resultado = struct('gray', gray, 'binaria', binaria, 'bordes', bordes);
end

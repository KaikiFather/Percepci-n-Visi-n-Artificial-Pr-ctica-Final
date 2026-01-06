function resultado = preprocesarImagen(imagen)
%PREPROCESARIMAGEN Prepara la imagen para detección/rectificación.
%   resultado = preprocesarImagen(imagen)
%   Devuelve: struct('gray', gray, 'binaria', binaria, 'bordes', bordes)

    if nargin < 1 || isempty(imagen)
        error('Se requiere una imagen de entrada.');
    end

    gray = im2gray(imagen);
    gray = im2double(gray);

    % Contraste local y suavizado leve
    gray = adapthisteq(gray, 'ClipLimit', 0.02);
    gray = imgaussfilt(gray, 1);

    % Binarización adaptativa: buscamos líneas oscuras
    binaria = imbinarize(gray, 'adaptive', ...
        'ForegroundPolarity', 'dark', ...
        'Sensitivity', 0.55);

    % Queremos líneas como 1
    binaria = imcomplement(binaria);

    % Limpieza típica
    binaria = bwareaopen(binaria, 80);
    binaria = imclose(binaria, strel('square', 3));
    binaria = imfill(binaria, 'holes');

    bordes = edge(gray, 'Canny', [0.05 0.20]);

    resultado = struct('gray', gray, 'binaria', binaria, 'bordes', bordes);
end

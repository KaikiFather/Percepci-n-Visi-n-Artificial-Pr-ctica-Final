function [imagen, origen] = capturarCuadricula(entrada)
%CAPTURARCUADRICULA Carga una imagen desde archivo o webcam.
%   [imagen, origen] = capturarCuadricula(entrada)
%   - entrada puede ser una ruta de archivo o una matriz de imagen.
%   - si se omite, se intenta abrir la webcam.

    if nargin < 1 || isempty(entrada)
        if exist('webcam', 'class') == 8 %#ok<EXIST>
            cam = webcam; %#ok<NASGU>
            pause(0.2);
            imagen = snapshot(cam);
            origen = 'webcam';
            clear cam;
        else
            error('No se ha proporcionado imagen y no hay soporte de webcam.');
        end
        return;
    end

    if ischar(entrada) || isstring(entrada)
        ruta = char(entrada);
        if ~isfile(ruta)
            error('No se encontró el archivo de imagen: %s', ruta);
        end
        imagen = imread(ruta);
        origen = ruta;
        return;
    end

    if isnumeric(entrada)
        imagen = entrada;
        origen = 'matriz';
        return;
    end

    error('Tipo de entrada no soportado para capturarCuadricula.');
end

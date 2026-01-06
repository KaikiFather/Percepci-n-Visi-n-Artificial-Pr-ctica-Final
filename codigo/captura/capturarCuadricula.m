function [imagen, origen] = capturarCuadricula(entrada)
%CAPTURARCUADRICULA Carga una imagen desde archivo o webcam.
%   [imagen, origen] = capturarCuadricula(entrada)
%   - entrada puede ser una ruta de archivo, una matriz de imagen o vacío.
%   - si se omite, se intenta abrir la webcam; si falla, se permite elegir un archivo.
%
%   La prioridad es: argumento directo > webcam disponible > selector de archivo.

    if nargin < 1
        entrada = [];
    end

    % Caso: ya se pasa la imagen como matriz
    if isnumeric(entrada)
        imagen = entrada;
        origen = 'matriz';
        return;
    end

    % Caso: se pasa una ruta
    if ischar(entrada) || isstring(entrada)
        ruta = char(entrada);
        if ~isfile(ruta)
            error('No se encontró el archivo de imagen: %s', ruta);
        end
        imagen = imread(ruta);
        origen = ruta;
        return;
    end

    % Si no hay entrada, intentar webcam y luego selector
    if isempty(entrada)
        [imagen, origen] = capturarDesdeWebcam();
        if isempty(imagen)
            [archivo, rutaBase] = uigetfile({'*.jpg;*.png;*.jpeg;*.bmp', 'Imágenes'}, ...
                'Selecciona una imagen de la cuadrícula');
            if isequal(archivo, 0)
                error('No se seleccionó ninguna imagen.');
            end
            origen = fullfile(rutaBase, archivo);
            imagen = imread(origen);
        end
        return;
    end

    error('Tipo de entrada no soportado para capturarCuadricula.');
end

function [imagen, origen] = capturarDesdeWebcam()
    imagen = [];
    origen = '';
    if exist('webcam', 'class') ~= 8 %#ok<EXIST>
        return;
    end

    try
        cam = webcam;
        pause(0.2);
        imagen = snapshot(cam);
        origen = 'webcam';
        clear cam;
    catch ME
        warning('No se pudo acceder a la webcam: %s', ME.message);
        if exist('cam', 'var')
            clear cam;
        end
        imagen = [];
    end
end

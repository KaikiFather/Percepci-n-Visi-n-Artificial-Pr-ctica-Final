function [imagen, origen] = capturarCuadricula(entrada)
%CAPTURARCUADRICULA Carga una imagen desde archivo o webcam.
%   [imagen, origen] = capturarCuadricula(entrada)
%   - entrada puede ser una ruta de archivo, una matriz de imagen o [].
%   - Si se pasa [] (o se omite), intenta webcam; si falla, abre selector de archivo.
%
%   Prioridad: imagen directa > ruta > webcam > selector.

    if nargin < 1
        entrada = [];
    end

    % 1) Si ya viene como matriz de imagen
    if isnumeric(entrada) && ~isempty(entrada)
        imagen = entrada;
        origen = 'matriz';
        return;
    end

    % 2) Si viene como ruta
    if (ischar(entrada) || isstring(entrada)) && ~isempty(strtrim(string(entrada)))
        ruta = char(entrada);
        if ~isfile(ruta)
            error('No se encontró el archivo de imagen: %s', ruta);
        end
        imagen = imread(ruta);
        origen = ruta;
        return;
    end

    % 3) Si no hay entrada: webcam o selector
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

    % En MATLAB suele existir como función (file), no como class.
    if exist('webcam', 'file') ~= 2 %#ok<EXIST>
        return;
    end

    try
        % Si hay varias cámaras, esto ayuda a detectar disponibilidad
        if exist('webcamlist', 'file') == 2 %#ok<EXIST>
            cams = webcamlist;
            if isempty(cams)
                return;
            end
        end

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
        origen = '';
    end
end

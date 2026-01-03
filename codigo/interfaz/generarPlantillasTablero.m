function generarPlantillasTablero(directorioSalida)
%GENERARPLANTILLASTABLERO Genera plantillas de tableros en PNG y JPG.
%   generarPlantillasTablero(directorioSalida)
%   Genera plantillas para tamaños 5x5, 7x7 y 12x12.

    if nargin < 1 || isempty(directorioSalida)
        directorioSalida = fullfile('patrones', 'plantillas_tablero');
    end

    if ~exist(directorioSalida, 'dir')
        mkdir(directorioSalida);
    end

    tamanos = [5, 7, 12];
    celda = 80;          % Tamaño de celda en píxeles, elegido para que el tablero tenga buena resolución para visualización y reconocimiento
    grosorLinea = 3;     % Grosor de línea en píxeles, suficientemente grueso para ser visible sin ocultar demasiado el contenido de las celdas
    margen = 20;         % Margen exterior en píxeles alrededor del tablero, evita cortes en los bordes y deja espacio en la imagen final

    for idx = 1:numel(tamanos)
        n = tamanos(idx);
        imagen = crearTableroVacio(n, celda, grosorLinea, margen);
        nombreBase = sprintf('tablero_%dx%d', n, n);
        rutaPng = fullfile(directorioSalida, [nombreBase, '.png']);
        rutaJpg = fullfile(directorioSalida, [nombreBase, '.jpg']);
        
        try
            imwrite(imagen, rutaPng);
            if exist(rutaPng, 'file') ~= 2
                error('generarPlantillasTablero:WriteFailed', ...
                    'No se pudo crear el archivo PNG: %s', rutaPng);
            end
            fprintf('Creado: %s\n', rutaPng);
            
            imwrite(imagen, rutaJpg, 'Quality', 95);
            if exist(rutaJpg, 'file') ~= 2
                error('generarPlantillasTablero:WriteFailed', ...
                    'No se pudo crear el archivo JPG: %s', rutaJpg);
            end
            fprintf('Creado: %s\n', rutaJpg);
        catch e
            error('generarPlantillasTablero:WriteError', ...
                'Error al guardar las plantillas del tablero en "%s" o "%s": %s', ...
                rutaPng, rutaJpg, e.message);
        end
    end
    
    fprintf('Plantillas generadas exitosamente en: %s\n', directorioSalida);
end

function imagen = crearTableroVacio(n, tamCelda, grosor, margen)
    ancho = n * tamCelda + 2 * margen;
    alto = n * tamCelda + 2 * margen;
    imagen = uint8(255 * ones(alto, ancho, 3));

    for fila = 0:n
        y = margen + fila * tamCelda + 1;
        y1 = max(y - floor(grosor / 2), 1);
        y2 = min(y1 + grosor - 1, alto);
        imagen(y1:y2, :, :) = 0;
    end

    for col = 0:n
        x = margen + col * tamCelda + 1;
        x1 = max(x - floor(grosor / 2), 1);
        x2 = min(x1 + grosor - 1, ancho);
        imagen(:, x1:x2, :) = 0;
    end
end

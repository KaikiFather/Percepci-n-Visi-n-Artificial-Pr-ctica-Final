function [tabImgWarp, N, tform, bbox] = detectarCuadricula(preprocesado)
%DETECTARCUADRICULA Detecta y rectifica la cuadrícula.
%   [tabImgWarp, N, tform, bbox] = detectarCuadricula(preprocesado)
%   preprocesado: estructura con campos gray, binaria, bordes.
%   Devuelve la imagen del tablero rectificada a 800x800, el tamaño N
%   estimado (entre 5 y 12), la transformación projectiva y el bounding box.

    if nargin < 1 || ~isstruct(preprocesado)
        error('Se requiere una estructura de preprocesado con campos gray, binaria, bordes.');
    end

    gray = preprocesado.gray;
    binaria = preprocesado.binaria;

    % Encontrar el contorno más grande
    binaria = bwareaopen(binaria, 500);
    regiones = regionprops(binaria, 'Area', 'BoundingBox', 'ConvexHull');
    if isempty(regiones)
        error('No se detectó ninguna región candidata a cuadrícula.');
    end

    [~, idx] = max([regiones.Area]);
    bbox = regiones(idx).BoundingBox;
    hull = regiones(idx).ConvexHull;

    % Aproximar a 4 esquinas
    esquinas = aproximarCuadrilatero(hull);
    if size(esquinas, 1) ~= 4
        x = bbox(1); y = bbox(2); w = bbox(3); h = bbox(4);
        esquinas = [x y; x+w y; x+w y+h; x y+h];
    end
    esquinas = ordenarEsquinas(esquinas);

    % Definir destino cuadrado
    ladoDestino = 800;
    ptsDestino = [1 1; ladoDestino 1; ladoDestino ladoDestino; 1 ladoDestino];
    tform = fitgeotrans(esquinas, ptsDestino, 'projective');
    tabImgWarp = imwarp(gray, tform, 'OutputView', imref2d([ladoDestino ladoDestino]));

    % Estimar N usando proyecciones
    [lineasFilas, lineasColumnas] = estimarLineas(tabImgWarp);
    N = min(numel(lineasFilas), numel(lineasColumnas)) - 1;

    if N < 5 || N > 12
        warning('No se pudo estimar N de forma fiable. Se ajusta al rango [5,12].');
        N = max(5, min(12, N));
    end
end

function esquinas = aproximarCuadrilatero(hull)
    try
        perimetro = sum(sqrt(sum(diff([hull; hull(1,:)]).^2, 2)));
        tolerancia = 0.02 * perimetro;
        esquinas = reducepoly(hull, tolerancia);
    catch
        esquinas = hull;
    end
end

function esquinasOrd = ordenarEsquinas(esquinas)
    % Orden: superior-izquierda, superior-derecha, inferior-derecha, inferior-izquierda
    suma = sum(esquinas, 2);
    resta = esquinas(:,2) - esquinas(:,1);
    [~, idxTL] = min(suma);
    [~, idxBR] = max(suma);
    [~, idxTR] = min(resta);
    [~, idxBL] = max(resta);
    esquinasOrd = [esquinas(idxTL,:); esquinas(idxTR,:); esquinas(idxBR,:); esquinas(idxBL,:)];
end

function [lineasFilas, lineasColumnas] = estimarLineas(tabImgWarp)
    bin = imbinarize(tabImgWarp, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.55);
    bin = imcomplement(bin);
    bin = bwareaopen(bin, 100);
    bin = imdilate(bin, strel('square', 3));

    proyFilas = sum(bin, 2);
    proyCols = sum(bin, 1);

    lineasFilas = extraerPicos(proyFilas);
    lineasColumnas = extraerPicos(proyCols);

    if numel(lineasFilas) < 2 || numel(lineasColumnas) < 2
        % Fallback: asumir celdas cuadradas con tamaño 800/N aprox
        pasos = 9; % predeterminado 9x9
        lineasFilas = round(linspace(1, size(tabImgWarp,1), pasos+1));
        lineasColumnas = round(linspace(1, size(tabImgWarp,2), pasos+1));
    end

    lineasFilas = unique(lineasFilas);
    lineasColumnas = unique(lineasColumnas);
end

function picos = extraerPicos(proyeccion)
    proyeccion = proyeccion(:);
    if isempty(proyeccion)
        picos = [];
        return;
    end
    suavizado = movmean(proyeccion, 5);
    umbral = 0.5 * max(suavizado + eps);
    indices = find(suavizado > umbral);
    if isempty(indices)
        picos = [];
        return;
    end
    grupos = separarEnGrupos(indices);
    picos = zeros(numel(grupos), 1);
    for k = 1:numel(grupos)
        [~, pos] = max(proyeccion(grupos{k}));
        picos(k) = grupos{k}(pos);
    end
end

function grupos = separarEnGrupos(indices)
    grupos = {};
    if isempty(indices)
        return;
    end
    inicio = indices(1);
    for k = 2:numel(indices)
        if indices(k) ~= indices(k-1) + 1
            grupos{end+1} = inicio:indices(k-1); %#ok<AGROW>
            inicio = indices(k);
        end
    end
    grupos{end+1} = inicio:indices(end);
end

function [lineasFilas, lineasColumnas, proyFilas, proyColumnas] = detectarBordesCeldas(img, N)
%DETECTARBORDESCELDAS Estima las líneas de la cuadrícula por proyección.
%   [lineasFilas, lineasColumnas] = detectarBordesCeldas(img, N)
%   Usa la proyección de bordes para localizar picos. Si falla, reparte
%   uniformemente con N si se proporciona o con 9 por defecto.

    if nargin < 2 || isempty(N)
        N = [];
    end

    gray = im2gray(img);
    edges = edge(gray, 'Canny');
    proyFilas = sum(edges, 2);
    proyColumnas = sum(edges, 1);

    lineasFilas = extraerLineas(proyFilas, 0.45);
    lineasColumnas = extraerLineas(proyColumnas, 0.45);

    if numel(lineasFilas) < 2 || numel(lineasColumnas) < 2
        if isempty(N)
            N = 9;
        end
        alto = size(gray, 1);
        ancho = size(gray, 2);
        lineasFilas = round(linspace(1, alto, N + 1));
        lineasColumnas = round(linspace(1, ancho, N + 1));
    end

    lineasFilas = unique(lineasFilas);
    lineasColumnas = unique(lineasColumnas);
end

function lineas = extraerLineas(proyeccion, umbralRelativo)
    if nargin < 2
        umbralRelativo = 0.5;
    end
    proyeccion = proyeccion(:);
    if max(proyeccion) == 0
        lineas = [];
        return;
    end

    suavizado = movmean(proyeccion, 5);
    umbral = max(suavizado) * umbralRelativo;
    indices = find(suavizado > umbral);
    if isempty(indices)
        lineas = [];
        return;
    end

    grupos = separarEnGrupos(indices);
    lineas = zeros(numel(grupos), 1);
    for k = 1:numel(grupos)
        lineas(k) = round(mean(grupos{k}));
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

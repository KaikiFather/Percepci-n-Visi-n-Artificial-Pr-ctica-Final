function [lineasFilas, lineasColumnas] = detectarBordesCeldas(img)
%DETECTARBORDESCELDAS Estima las líneas de la cuadrícula.
%   [lineasFilas, lineasColumnas] = detectarBordesCeldas(img)

    gray = im2gray(img);
    edges = edge(gray, 'Canny');

    sumaFilas = sum(edges, 2);
    sumaColumnas = sum(edges, 1);

    lineasFilas = extraerLineas(sumaFilas, 0.5);
    lineasColumnas = extraerLineas(sumaColumnas, 0.5);

    if numel(lineasFilas) < 2 || numel(lineasColumnas) < 2
        lineasFilas = linspace(1, size(gray, 1), 6);
        lineasColumnas = linspace(1, size(gray, 2), 6);
    end

    lineasFilas = unique(round(lineasFilas));
    lineasColumnas = unique(round(lineasColumnas));
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

    umbral = max(proyeccion) * umbralRelativo;
    indices = find(proyeccion > umbral);
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

    actual = indices(1);
    inicio = actual;
    for k = 2:numel(indices)
        if indices(k) ~= indices(k-1) + 1
            grupos{end+1} = inicio:indices(k-1); %#ok<AGROW>
            inicio = indices(k);
        end
    end
    grupos{end+1} = inicio:indices(end);
end

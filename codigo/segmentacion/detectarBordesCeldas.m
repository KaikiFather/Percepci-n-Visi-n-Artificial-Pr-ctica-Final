function [lineasFilas, lineasColumnas] = detectarBordesCeldas(tabImgWarp, N)
%DETECTARBORDESCELDAS Detecta líneas de rejilla por proyección.
%   Si no detecta suficiente, fallback uniforme usando N.

    if nargin < 1 || isempty(tabImgWarp)
        error('detectarBordesCeldas: tabImgWarp vacío.');
    end
    if nargin < 2
        N = [];
    end

    tabGray = im2gray(tabImgWarp);

    bin = imbinarize(tabGray, 'adaptive', 'ForegroundPolarity','dark', 'Sensitivity', 0.55);
    bin = imcomplement(bin);
    bin = bwareaopen(bin, 120);
    bin = imdilate(bin, strel('square', 2));

    proyFilas = sum(bin,2);
    proyCols  = sum(bin,1);

    lineasFilas = extraerPicos(proyFilas);
    lineasColumnas = extraerPicos(proyCols);

    % Fallback uniforme
    if numel(lineasFilas) < 2 || numel(lineasColumnas) < 2
        if isempty(N) || ~isscalar(N) || N < 5 || N > 12
            N = 5; % para no romper
        end
        H = size(tabGray,1);
        W = size(tabGray,2);
        lineasFilas = round(linspace(1, H, N+1));
        lineasColumnas = round(linspace(1, W, N+1));
    end

    lineasFilas = sort(unique(lineasFilas(:)));
    lineasColumnas = sort(unique(lineasColumnas(:)));
end

function picos = extraerPicos(proy)
    proy = proy(:);
    if isempty(proy), picos = []; return; end

    suav = movmean(proy, 9);
    umbral = 0.55 * (max(suav) + eps);

    idx = find(suav > umbral);
    if isempty(idx), picos = []; return; end

    grupos = separarEnGrupos(idx);
    picos = zeros(numel(grupos),1);
    for k=1:numel(grupos)
        g = grupos{k};
        [~,pos] = max(proy(g));
        picos(k) = g(pos);
    end

    picos = sort(unique(picos));

    minDist = 12;
    out = [];
    for i=1:numel(picos)
        if isempty(out) || abs(picos(i)-out(end)) >= minDist
            out(end+1) = picos(i); %#ok<AGROW>
        end
    end
    picos = out(:);
end

function grupos = separarEnGrupos(idx)
    grupos = {};
    if isempty(idx), return; end
    inicio = idx(1);
    for k=2:numel(idx)
        if idx(k) ~= idx(k-1)+1
            grupos{end+1} = inicio:idx(k-1); %#ok<AGROW>
            inicio = idx(k);
        end
    end
    grupos{end+1} = inicio:idx(end);
end

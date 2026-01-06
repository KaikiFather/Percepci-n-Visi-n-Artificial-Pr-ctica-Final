function [tabImgWarp, N, tform, bbox, debug] = detectarCuadricula(pre)
%DETECTARCUADRICULA Detecta y rectifica el tablero a 800x800 y estima N.
%   pre: struct con campos gray, binaria, bordes
%   Devuelve: tabImgWarp (800x800), N (5..12), tform, bbox y debug (score/fiable).

    if nargin < 1 || ~isstruct(pre) || ~isfield(pre,'gray') || ~isfield(pre,'binaria')
        error('detectarCuadricula requiere struct con campos gray y binaria.');
    end

    gray = pre.gray;
    bw = pre.binaria;

    % 1) Candidato principal por área
    bw2 = bwareaopen(bw, 500);
    regs = regionprops(bw2, 'Area', 'BoundingBox', 'ConvexHull');
    if isempty(regs)
        error('No se detectó ninguna región candidata a cuadrícula.');
    end
    [~, idx] = max([regs.Area]);
    bbox = regs(idx).BoundingBox;
    hull = regs(idx).ConvexHull;

    % 2) Esquinas: reducir hull a 4 puntos (si falla, bbox)
    corners = aproximarCuadrilatero(hull);
    if size(corners,1) ~= 4
        x=bbox(1); y=bbox(2); w=bbox(3); h=bbox(4);
        corners = [x y; x+w y; x+w y+h; x y+h];
    end
    corners = ordenarEsquinas(corners);

    % 3) Warp a cuadrado fijo
    side = 800;
    dst = [1 1; side 1; side side; 1 side];
    tform = fitgeotrans(corners, dst, 'projective');
    tabImgWarp = imwarp(gray, tform, 'OutputView', imref2d([side side]));

    % 4) Estimar N por proyecciones
    [lineasF, lineasC, score] = estimarLineas(tabImgWarp);
    Nraw = min(numel(lineasF), numel(lineasC)) - 1;

    fiable = (Nraw >= 5 && Nraw <= 12 && score >= 0.35);
    N = Nraw;

    debug = struct();
    debug.lineasFilas = lineasF;
    debug.lineasColumnas = lineasC;
    debug.scoreLineas = score;
    debug.Nraw = Nraw;
    debug.fiable = fiable;

    if ~fiable
        warning('N no fiable (N=%d, score=%.2f).', Nraw, score);
    end
end

function corners = aproximarCuadrilatero(hull)
    try
        per = sum(sqrt(sum(diff([hull; hull(1,:)]).^2, 2)));
        tol = 0.02 * per;
        corners = reducepoly(hull, tol);

        if size(corners,1) > 4
            corners = seleccionar4Extremos(corners);
        end
    catch
        corners = hull;
    end
end

function P4 = seleccionar4Extremos(P)
    suma = sum(P,2);
    resta = P(:,2) - P(:,1);
    [~, iTL] = min(suma);
    [~, iBR] = max(suma);
    [~, iTR] = min(resta);
    [~, iBL] = max(resta);
    P4 = [P(iTL,:); P(iTR,:); P(iBR,:); P(iBL,:)];
end

function ord = ordenarEsquinas(P)
    suma = sum(P,2);
    resta = P(:,2) - P(:,1);
    [~, iTL] = min(suma);
    [~, iBR] = max(suma);
    [~, iTR] = min(resta);
    [~, iBL] = max(resta);
    ord = [P(iTL,:); P(iTR,:); P(iBR,:); P(iBL,:)];
end

function [lf, lc, score] = estimarLineas(tab)
    % binarizar líneas
    bin = imbinarize(tab, 'adaptive', 'ForegroundPolarity','dark', 'Sensitivity', 0.55);
    bin = imcomplement(bin);
    bin = bwareaopen(bin, 120);
    bin = imdilate(bin, strel('square', 2));

    pf = sum(bin,2);
    pc = sum(bin,1);

    lf = extraerPicos(pf);
    lc = extraerPicos(pc);

    % score simple por cantidad
    score = min(numel(lf), numel(lc)) / 13; % 13 = 12+1
    score = max(0, min(1, score));
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
    % filtrar cercanos
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

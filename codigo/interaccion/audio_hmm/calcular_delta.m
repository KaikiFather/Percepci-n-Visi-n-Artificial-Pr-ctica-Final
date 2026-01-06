function deltas = calcular_delta(atributos, N)
%CALCULAR_DELTA Calcula deltas o delta-deltas de un conjunto de atributos.
%   deltas = calcular_delta(atributos, N) aplica la fórmula estándar usando
%   un contexto de N cuadros a cada lado. N por defecto es 2.

    if nargin < 2 || isempty(N)
        N = 2;
    end

    if isempty(atributos)
        deltas = atributos;
        return;
    end

    atributos = atributos'; % columnas = cuadros
    [numCoef, numCuadros] = size(atributos);
    deltas = zeros(numCoef, numCuadros);

    divisor = 2 * sum((1:N) .^ 2);
    for t = 1:numCuadros
        acumulador = zeros(numCoef, 1);
        for n = 1:N
            idxPos = min(numCuadros, t + n);
            idxNeg = max(1, t - n);
            acumulador = acumulador + n * (atributos(:, idxPos) - atributos(:, idxNeg));
        end
        deltas(:, t) = acumulador / divisor;
    end

    deltas = deltas';
end

function indices = cuantizar_caracteristicas(caracteristicas, codebook)
%CUANTIZAR_CARACTERISTICAS Asigna cada vector de características al centroide más cercano.
%   indices = cuantizar_caracteristicas(caracteristicas, codebook)
%   devuelve un vector columna con los índices de los centroides.
%
%   El codebook puede estar en formato:
%     - matriz KxD con los centroides.
%     - struct con campos 'codebook' o 'centroides'.

    if isstruct(codebook)
        if isfield(codebook, 'codebook')
            centroides = codebook.codebook;
        elseif isfield(codebook, 'centroides')
            centroides = codebook.centroides;
        else
            error('El codebook no contiene los campos esperados.');
        end
    else
        centroides = codebook;
    end

    if isempty(caracteristicas)
        indices = [];
        return;
    end

    centroides = double(centroides);
    caracteristicas = double(caracteristicas);

    % Distancias euclídeas cuadráticas
    try
        distancias = pdist2(caracteristicas, centroides, 'squaredeuclidean');
    catch
        % Fallback sin Statistics Toolbox
        numVec = size(caracteristicas, 1);
        numCent = size(centroides, 1);
        distancias = zeros(numVec, numCent);
        for i = 1:numVec
            diff = centroides - caracteristicas(i, :);
            distancias(i, :) = sum(diff .^ 2, 2)';
        end
    end
    [~, indices] = min(distancias, [], 2);
end

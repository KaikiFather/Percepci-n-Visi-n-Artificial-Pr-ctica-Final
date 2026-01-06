function tablero = reconocerTablero(celdas)
%RECONOCERTABLERO Recorre las celdas y devuelve estructura con grid y tipos.
%   tablero.grid -> valores en texto
%   tablero.tipos -> tipo de cada celda
%   tablero.fijas -> booleano de casillas no vacías (iniciales)

    [filas, cols] = size(celdas);
    grid = cell(filas, cols);
    tipos = cell(filas, cols);
    fijas = false(filas, cols);

    [plantillasNum, etiquetasNum] = cargarPlantillasDigitos(); %#ok<ASGLU>
    [plantillasOp, etiquetasOp] = cargarPlantillasOperadores(); %#ok<ASGLU>

    for r = 1:filas
        for c = 1:cols
            celdaImg = celdas{r, c};
            if isempty(celdaImg)
                grid{r, c} = '';
                tipos{r, c} = 'vacio';
                continue;
            end
            res = reconocerCelda(celdaImg, plantillasNum, plantillasOp);
            grid{r, c} = res.valor;
            tipos{r, c} = res.tipo;
            if ~strcmp(res.tipo, 'vacio')
                fijas(r, c) = true;
            end
        end
    end

    tablero = struct('grid', grid, 'tipos', tipos, 'fijas', fijas);
end

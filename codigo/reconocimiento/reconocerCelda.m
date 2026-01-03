function resultado = reconocerCelda(imagen, plantillasNumero, plantillasOperador)
%RECONOCERCELDA Clasifica una celda como número, operador o vacía.
%   resultado = reconocerCelda(imagen, plantillasNumero, plantillasOperador)

    if nargin < 2
        plantillasNumero = {};
    end
    if nargin < 3
        plantillasOperador = {};
    end

    imagenGray = im2gray(imagen);
    imagenGray = im2double(imagenGray);

    % Umbral de brillo para considerar una celda como vacía.
    % En imágenes convertidas con im2double, 1.0 es blanco puro.
    % El valor 0.9 se ha seleccionado empíricamente para las
    % condiciones típicas de iluminación y puede ajustarse si es necesario.
    umbralCeldaVacia = 0.9;

    nivelOscuro = mean(imagenGray(:));
    if nivelOscuro > umbralCeldaVacia
        resultado = struct('tipo', 'vacio', 'valor', '', 'puntuacion', 0);
        return;
    end

    if isempty(plantillasNumero)
        [indiceNumero, puntNum] = clasificarNumero(imagenGray);
    else
        [indiceNumero, puntNum] = clasificarNumero(imagenGray, plantillasNumero);
    end

    if isempty(plantillasOperador)
        [indiceOp, puntOp] = clasificarOperador(imagenGray);
    else
        [indiceOp, puntOp] = clasificarOperador(imagenGray, plantillasOperador);
    end

    maxNum = max(puntNum);
    maxOp = max(puntOp);

    if maxNum >= maxOp
        mapa = {'1','2','3','4','5','6','7','8','9','0'};
        valor = mapa{indiceNumero};
        resultado = struct('tipo', 'numero', 'valor', valor, 'puntuacion', maxNum);
    else
        mapa = {'+','-','*','/','='};
        valor = mapa{indiceOp};
        resultado = struct('tipo', 'operador', 'valor', valor, 'puntuacion', maxOp);
    end
end

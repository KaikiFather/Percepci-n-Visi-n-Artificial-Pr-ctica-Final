function [esCorrecta, detalle] = evaluarColumna(tablero, columna)
%EVALUARCOLUMNA Evalúa una columna de la cuadrícula.
%   [esCorrecta, detalle] = evaluarColumna(tablero, columna)

    if ~isfield(tablero, 'grid')
        error('El tablero no tiene el campo grid.');
    end

    tokens = tablero.grid(:, columna);
    [esCorrecta, detalle] = evaluarTokens(tokens);
end

function [esCorrecta, detalle] = evaluarTokens(tokens)
    esCorrecta = true;
    detalle = struct('valido', true, 'mensaje', '', 'arriba', [], 'abajo', []);

    tokens = reshape(tokens, 1, []);
    indicesIgual = find(strcmp(tokens, '='));
    if isempty(indicesIgual)
        detalle.mensaje = 'No hay signo de igualdad.';
        detalle.valido = false;
        esCorrecta = false;
        return;
    end
    if numel(indicesIgual) ~= 1
        detalle.mensaje = 'Hay más de un signo de igualdad.';
        detalle.valido = false;
        esCorrecta = false;
        return;
    end

    idx = indicesIgual(1);
    arriba = tokens(1:idx-1);
    abajo = tokens(idx+1:end);

    if any(cellfun(@isempty, arriba)) || any(cellfun(@isempty, abajo))
        detalle.mensaje = 'Faltan valores para evaluar.';
        esCorrecta = false;
        detalle.valido = false;
        return;
    end

    valorArriba = evaluarExpresionMatematica(arriba);
    valorAbajo = evaluarExpresionMatematica(abajo);

    detalle.arriba = valorArriba;
    detalle.abajo = valorAbajo;

    if isempty(valorArriba) || isempty(valorAbajo)
        esCorrecta = false;
        detalle.valido = false;
        detalle.mensaje = 'Expresión inválida.';
        return;
    end

    esCorrecta = abs(valorArriba - valorAbajo) < 1e-6;
    if ~esCorrecta
        detalle.mensaje = 'La igualdad no se cumple.';
    end
end



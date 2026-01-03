function [esCorrecta, detalle] = evaluarFila(tablero, fila)
%EVALUARFILA Evalúa una fila de la cuadrícula.
%   [esCorrecta, detalle] = evaluarFila(tablero, fila)

    if ~isfield(tablero, 'grid')
        error('El tablero no tiene el campo grid.');
    end

    tokens = tablero.grid(fila, :);
    [esCorrecta, detalle] = evaluarTokens(tokens);
end

function [esCorrecta, detalle] = evaluarTokens(tokens)
    esCorrecta = true;
    detalle = struct('valido', true, 'mensaje', '', 'izquierda', [], 'derecha', []);

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
    izquierda = tokens(1:idx-1);
    derecha = tokens(idx+1:end);

    if any(cellfun(@isempty, izquierda)) || any(cellfun(@isempty, derecha))
        detalle.mensaje = 'Faltan valores para evaluar.';
        esCorrecta = false;
        detalle.valido = false;
        return;
    end

    valorIzq = evaluarExpresionMatematica(izquierda);
    valorDer = evaluarExpresionMatematica(derecha);

    detalle.izquierda = valorIzq;
    detalle.derecha = valorDer;

    if isempty(valorIzq) || isempty(valorDer)
        esCorrecta = false;
        detalle.valido = false;
        detalle.mensaje = 'Expresión inválida.';
        return;
    end

    esCorrecta = abs(valorIzq - valorDer) < 1e-6;
    if ~esCorrecta
        detalle.mensaje = 'La igualdad no se cumple.';
    end
end



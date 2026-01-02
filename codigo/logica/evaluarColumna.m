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

    valorArriba = evaluarExpresion(arriba);
    valorAbajo = evaluarExpresion(abajo);

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

function valor = evaluarExpresion(tokens)
    valor = [];
    if isempty(tokens)
        return;
    end

    numeros = [];
    operadores = {};

    for k = 1:numel(tokens)
        token = tokens{k};
        if isempty(token)
            return;
        end
        if all(isstrprop(token, 'digit'))
            numeros(end+1) = str2double(token); %#ok<AGROW>
        elseif esOperadorValido(token)
            operadores{end+1} = token; %#ok<AGROW>
        else
            return;
        end
    end

    if numel(numeros) ~= numel(operadores) + 1
        return;
    end

    [numeros, operadores] = aplicarPrioridad(numeros, operadores, {'*', '/'});
    if isempty(numeros)
        return;
    end
    [numeros, operadores] = aplicarPrioridad(numeros, operadores, {'+', '-'});
    if isempty(numeros)
        return;
    end

    if numel(numeros) == 1
        valor = numeros(1);
    end
end

function [nums, ops] = aplicarPrioridad(nums, ops, objetivo)
    idx = 1;
    while idx <= numel(ops)
        if ismember(ops{idx}, objetivo)
            a = nums(idx);
            b = nums(idx+1);
            switch ops{idx}
                case '*'
                    res = a * b;
                case '/'
                    if b == 0
                        nums = [];
                        ops = {};
                        return;
                    end
                    res = a / b;
                case '+'
                    res = a + b;
                case '-'
                    res = a - b;
                otherwise
                    nums = [];
                    ops = {};
                    return;
            end
            if isempty(res) || ~isfinite(res)
                nums = [];
                ops = {};
                return;
            end
            nums(idx) = res;
            nums(idx+1) = [];
            ops(idx) = [];
        else
            idx = idx + 1;
        end
    end
end

function esOperador = esOperadorValido(token)
    esOperador = any(strcmp(token, {'+', '-', '*', '/'}));
end

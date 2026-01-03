function valor = evaluarExpresionMatematica(tokens)
%EVALUAREXPRESIONMATEMATICA Evalúa una expresión matemática a partir de tokens.
%   valor = evaluarExpresionMatematica(tokens)
%   Evalúa una secuencia de números y operadores respetando la prioridad.

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

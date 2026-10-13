function [fun, expresionVectorizada] = crearFuncion(expresion)

  % Convierte una expresion escrita con x en una funcion anonima vectorizable
  % Se limita el vocabulario permitido antes de usar str2func

  % Verificar que se haya ingresado una expresion
  if nargin < 1 || isempty(strtrim(expresion))
    error('La expresion de la funcion no puede estar vacia.');
  endif

  expresion = lower(strtrim(expresion));

  % Verificar caracteres permitidos
  if isempty(regexp(expresion, '^[0-9xX+\-*/^()., _a-zA-Z]+$', 'once'))
    error('La expresion contiene caracteres no permitidos.');
  endif

  % La e de 1e6 es parte de un numero, no un identificador
  vocabulario=regexprep(expresion, ...
    '(?<![a-zA-Z_0-9])(?:[0-9]+\.?[0-9]*|\.[0-9]+)e[+\-]?[0-9]+', ...
    '0');

  % Obtener los identificadores utilizados en la expresion
  ids = regexp(vocabulario, '[a-zA-Z_][a-zA-Z0-9_]*', 'match');

  permitidos = {'x','sin','cos','tan','asin','acos','atan','sinh','cosh','tanh', ...
                'exp','log','log10','sqrt','abs','pi','e'};

  % Verificar que todos los identificadores pertenezcan al vocabulario permitido
  for k = 1:numel(ids)
    if ~any(strcmp(ids{k}, permitidos))
      error(['Identificador no permitido en la funcion: ', ids{k}]);
    endif
  endfor

  % Vectorizar los operadores para permitir evaluaciones con vectores
  expresionVectorizada = regexprep(expresion, '(?<!\.)\^', '.^');
  expresionVectorizada = regexprep(expresionVectorizada, '(?<!\.)\*', '.*');
  expresionVectorizada = regexprep(expresionVectorizada, '(?<!\.)/', './');

  % Crear y probar la funcion anonima.
  try
    fun = str2func(['@(x) ', expresionVectorizada]);

    prueba = fun(0.731);

    if ~isnumeric(prueba) || ~isscalar(prueba)
      error('La expresion debe producir un valor numerico escalar.');
    endif

  catch err
    error(['No se pudo interpretar la funcion. Revise parentesis y operadores. Detalle: ', err.message]);
  end_try_catch

endfunction
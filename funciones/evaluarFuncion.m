function y = evaluarFuncion(f, x)

  % Cada paso del algoritmo trabaja con un numero real, escalar y finito

  % Validar la funcion y el argumento
  if ~isa(f,'function_handle') || ~isscalar(x) || ~isreal(x) || ~isfinite(x)

    error('La funcion y su argumento deben ser validos; x debe ser real y finito.');

  endif

  % Evaluar la funcion
  y=f(x);

  % Validar el resultado obtenido
  if ~isnumeric(y) || ~isscalar(y) || ~isreal(y) || ~isfinite(y)

    error(sprintf('La funcion no devuelve un numero real y finito en x = %.12g. Revise su dominio.',x));

  endif

endfunction
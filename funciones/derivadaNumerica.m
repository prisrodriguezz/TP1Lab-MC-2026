function valor = derivadaNumerica(f, x, orden)

  % Diferencias centrales con paso adaptado a la escala de x.

  % Derivada de primer orden por defecto
  if nargin < 3, orden = 1; endif

  h = eps^(1/3) * max(1, abs(x));

  % Calcular derivada de primer orden
  if orden == 1

    valor = (evaluarFuncion(f,x + h) - evaluarFuncion(f,x - h)) / (2*h);

  % Calcular derivada de segundo orden
  elseif orden == 2

    h = eps^(1/4) * max(1, abs(x));

    valor = (evaluarFuncion(f,x + h) - 2*evaluarFuncion(f,x) + evaluarFuncion(f,x - h)) / (h^2);

  else

    error('Solo se admiten derivadas de orden 1 o 2.');

  endif

endfunction
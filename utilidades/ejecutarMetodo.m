function r = ejecutarMetodo(nombre, cfg)

  % ============================================================
  % Selecciona y ejecuta el metodo numerico indicado.
  % ============================================================

  switch nombre

    case 'Interpolacion Lineal'

      r = interpolacionLineal(cfg.f, cfg.a, cfg.b, cfg.tol, cfg.maxIter);

    case 'Iteracion'

      r = iteracion( ...
        cfg.g, cfg.x0, cfg.tol, cfg.maxIter, cfg.f, cfg.exprG);

    case 'Iteracion + Aitken'

      r = aitken( ...
        cfg.g, cfg.x0, cfg.tol, cfg.maxIter, cfg.f, cfg.exprG);

    otherwise

      error(['Metodo desconocido: ', nombre]);

  endswitch


  % Guarda una copia de los parametros de la ejecucion.
  r.datosUtilizados = {
    ['Metodo: ', r.metodo], ['Funcion f(x): ', cfg.exprF]
  };


  % Agrega los datos especificos de cada metodo.

  if strcmp(nombre, 'Iteracion') || strcmp(nombre, 'Iteracion + Aitken')
    r.datosUtilizados{end+1} = ['Funcion g(x): ', cfg.exprG];
    r.datosUtilizados{end+1} = sprintf('Valor inicial x0: %.12g', cfg.x0);

  elseif strcmp(nombre, 'Interpolacion Lineal')
    r.datosUtilizados{end+1} = sprintf('Intervalo: [%.12g, %.12g]', cfg.a, cfg.b);
  endif


  % Agrega los parametros comunes a todos los metodos.
  r.datosUtilizados{end+1} = sprintf('Tolerancia: %.12g', cfg.tol);

  r.datosUtilizados{end+1} = sprintf('Maximo de iteraciones: %d', cfg.maxIter);


  % Aclaracion adicional cuando no se alcanza la convergencia.
  if ~r.converge
    r.analisis{end+1} = ['NO CONVERGIO indica que no se cumplio el criterio de parada dentro del maximo de iteraciones.'];
  endif

endfunction
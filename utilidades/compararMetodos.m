
function c = compararMetodos(nombre1, nombre2, cfg)

  % ============================================================
  % Ejecuta dos metodos con la misma configuracion y compara
  % sus principales resultados.
  % ============================================================

  % Ejecutar ambos metodos.
  c.resultado1 = ejecutarSeguro(nombre1, cfg);
  c.resultado2 = ejecutarSeguro(nombre2, cfg);


  % Calcular la diferencia entre las raices aproximadas.
  c.diferenciaRaices = abs(c.resultado1.raiz - c.resultado2.raiz);


  % Definir las columnas de la tabla comparativa.
  c.columnas = {'Magnitud', nombre1, nombre2};


  % Construir la tabla con los principales resultados.
  c.tabla = { ...
    'Aproximacion', c.resultado1.raiz, ...
                    c.resultado2.raiz; ...

    'f(raiz)',      c.resultado1.valorFuncion, ...
                    c.resultado2.valorFuncion; ...

    'Iteraciones',  c.resultado1.iteraciones, ...
                    c.resultado2.iteraciones; ...

    'Error final',  c.resultado1.error, ...
                    c.resultado2.error; ...

    'Tolerancia',   c.resultado1.tolerancia, ...
                    c.resultado2.tolerancia; ...

    'Tiempo (s)',   c.resultado1.tiempo, ...
                    c.resultado2.tiempo; ...

    'Convergencia', siNo(c.resultado1.converge), ...
                    siNo(c.resultado2.converge); ...

    'Finalizacion', c.resultado1.mensaje, ...
                    c.resultado2.mensaje ...
  };


  % Advertencias generales para interpretar la comparacion.
  c.advertencia = ...
    ['Para Punto Fijo, debe justificarse que x = g(x) equivale a f(x) = 0. El programa no demuestra esa equivalencia.'];

  c.advertencia = [c.advertencia, ...
    'Los errores de ambos metodos pueden tener distinto significado.',
    'El tiempo de ejecucion no determina por si solo que metodo es mejor.'];


  % Advertir si las aproximaciones difieren significativamente.
  if c.resultado1.converge && ...
     c.resultado2.converge && ...
     c.diferenciaRaices > 10 * cfg.tol

    c.advertencia = [c.advertencia, 'Las aproximaciones difieren: pueden corresponder a raices distintas.'];

  endif

endfunction


% ==============================================================
% CONVERTIR BOOLEANO A TEXTO
% Devuelve 'SI' o 'NO' segun el valor recibido.
% ==============================================================
function s = siNo(v)

  if v
    s = 'SI';
  else
    s = 'NO';
  endif

endfunction


% ==============================================================
% Intenta ejecutar un metodo y captura posibles errores para
% evitar que falle toda la comparacion.
% ==============================================================
function r = ejecutarSeguro(nombre, cfg)

  try

    % Ejecutar el metodo normalmente.
    r = ejecutarMetodo(nombre, cfg);

  catch err

    % Crear un resultado base si ocurre un error.
    r = resultadoBase(nombre, cfg.tol);

    r.tiempo = NaN;

    r.mensaje = ['NO EJECUTABLE / INTERRUMPIDO: ', err.message];

    r.analisis = { r.mensaje, 'No hay una solucion convergente ni un tiempo completo del algoritmo.'};


    % Guardar los datos disponibles antes del error.
    r.datosUtilizados = {
      ['Metodo: ', nombre],
      ['Funcion f(x): ', cfg.exprF],
      sprintf('Tolerancia: %.12g; maximo de iteraciones: %d', cfg.tol, cfg.maxIter)
    };

    % Para Interpolacion se agrega el intervalo [a,b]
    if isfield(cfg, 'a') && isfield(cfg, 'b') && ~isempty(cfg.a) && ~isempty(cfg.b)

      r.datosUtilizados{end+1} = sprintf('Intervalo: [%.12g, %.12g]', cfg.a, cfg.b);

    endif


    % Agregar g(x) y x0 solamente para Iteracion y Aitken.
    if any(strcmp(nombre, {'Iteracion', 'Iteracion + Aitken'}))

      r.datosUtilizados{end+1} = ['Funcion g(x): ', cfg.exprG];

      if ~isempty(cfg.x0)

        r.datosUtilizados{end+1} = sprintf('Valor inicial x0: %.12g', cfg.x0);

      endif

    endif

  end_try_catch

endfunction
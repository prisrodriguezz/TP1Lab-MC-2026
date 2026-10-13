
function graficarFuncion(ax, tipo, f, g, a, b, resultado, resultado2)

  % Resultado opcional para comparar dos metodos.
  if nargin < 8
    resultado2 = [];
  endif

  % Preparar el area de grafico.
  cla(ax);
  hold(ax, 'on');
  grid(ax, 'on');

  % Generar puntos para representar la funcion.
  x = linspace(a, b, 500);

  plot(ax, x, arrayfun(@(v) muestra(f, v), x), ...
       'b-', 'LineWidth', 1.5);

  plot(ax, [a, b], [0, 0], 'k--');

  legendas = {'f(x)', 'y=0'};
  title(ax, 'Funcion y aproximaciones (datos de la ejecucion guardada)');


  % Graficar g(x) e y=x para el metodo de Punto Fijo.
  if any(strcmp(tipo, {'Iteracion', 'Iteracion / Punto Fijo'})) && ~isempty(g)

    plot(ax, x, arrayfun(@(v) muestra(g, v), x), ...
         'Color', [.2, .6, .2]);

    plot(ax, x, x, 'k:');

    legendas = [legendas, {'g(x)', 'y=x'}];

  endif


  % Graficar la aproximacion y los iterados del primer metodo.
  if ~isempty(resultado) && isfinite(resultado.raiz)

    yr = muestra(f, resultado.raiz);

    plot(ax, resultado.raiz, yr, ...
         'ro', 'MarkerFaceColor', 'r');

    legendas{end+1} = ...
      [resultado.metodo, ' (aproximacion)'];

    hist = resultado.historial;

    if numel(hist) > 1 && numel(hist) <= 30

      plot(ax, hist, arrayfun(@(v) muestra(f, v), hist), 'r.');

      legendas{end+1} = 'Iterados metodo 1';

    endif

  endif


  % Graficar la aproximacion del segundo metodo, si existe.
  if ~isempty(resultado2) && isfinite(resultado2.raiz)

    yr = muestra(f, resultado2.raiz);

    plot(ax, resultado2.raiz, yr, ...
         'ms', 'MarkerFaceColor', 'm');

    legendas{end+1} = ...
      [resultado2.metodo, ' (aproximacion)'];

  endif


  % Configurar etiquetas y leyenda.
  xlabel(ax, 'x');
  ylabel(ax, 'y');
  legend(ax, legendas, 'Location', 'best');

  hold(ax, 'off');

endfunction


function y = muestra(f, x)

  % Los puntos fuera del dominio se dejan como huecos.
  try

    y = evaluarFuncion(f, x);

  catch

    y = NaN;

  end_try_catch

endfunction

function graficarFuncion(ax, tipo, f, g, a, b, resultado, resultado2)

  % Resultado opcional para comparar dos metodos.
  if nargin < 8
    resultado2 = [];
  endif

  % Verificar que el eje grafico siga siendo valido.
  if isempty(ax) || ~isgraphics(ax)
    return;
  endif

  % Preparar el area de grafico.
  cla(ax);
  hold(ax, 'on');
  grid(ax, 'on');
  box(ax, 'on');

  % Generar un intervalo simetrico respecto de cero.
  xMaxAbs = max(abs([a, b]));

  if xMaxAbs == 0
    xMaxAbs = 1;
  endif

  xMin = -xMaxAbs;
  xMax = xMaxAbs;
  x = linspace(xMin, xMax, 500);

  % Graficar la funcion principal.
  plot(ax, x, arrayfun(@(v) muestra(f, v), x), ...
       'b-', 'LineWidth', 1.8);

  % Ejes de referencia.
  plot(ax, [xMin, xMax], [0, 0], ...
       'k--', 'LineWidth', 1.0);

  plot(ax, [0, 0], [-10, 100], ...
       'k--', 'LineWidth', 1.0);

  legendas = {'f(x)', 'y = 0', 'x = 0'};

  % Graficar g(x) e y=x para el metodo de Punto Fijo.
  if any(strcmp(tipo, {'Iteracion', 'Iteracion / Punto Fijo'})) ...
      && ~isempty(g)

    plot(ax, x, arrayfun(@(v) muestra(g, v), x), ...
         'Color', [.2, .6, .2], 'LineWidth', 1.5);

    plot(ax, x, x, 'k:', 'LineWidth', 1.2);

    legendas = [legendas, {'g(x)', 'y = x'}];

  endif

  % Graficar la aproximacion y los iterados del primer metodo.
  if ~isempty(resultado) && isfinite(resultado.raiz)

    yr = muestra(f, resultado.raiz);

    plot(ax, resultado.raiz, yr, ...
         'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);

    legendas{end+1} = ...
      [resultado.metodo, ' (aproximacion)'];

    hist = resultado.historial;

    if numel(hist) > 1 && numel(hist) <= 30

      plot(ax, hist, arrayfun(@(v) muestra(f, v), hist), ...
           'r.', 'MarkerSize', 12);

      legendas{end+1} = 'Iterados metodo 1';

    endif

  endif

  % Graficar la aproximacion del segundo metodo, si existe.
  if ~isempty(resultado2) && isfinite(resultado2.raiz)

    yr = muestra(f, resultado2.raiz);

    plot(ax, resultado2.raiz, yr, ...
         'ms', 'MarkerFaceColor', 'm', 'MarkerSize', 7);

    legendas{end+1} = ...
      [resultado2.metodo, ' (aproximacion)'];

  endif

  % Configurar limites de los ejes.
  xlim(ax, [xMin, xMax]);
  ylim(ax, [-10, 100]);

  % Mejorar la legibilidad de las etiquetas.
  set(ax, 'FontSize', 11, ...
          'LineWidth', 1.0, ...
          'TickDir', 'out');

  xlabel(ax, 'x', 'FontSize', 13);
  ylabel(ax, 'f(x)', 'FontSize', 13);

  title(ax, 'Funcion y aproximaciones', ...
        'FontSize', 14);

  % Usar una ubicacion compatible con Octave.
  legend(ax, legendas, 'Location', 'northeast');

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
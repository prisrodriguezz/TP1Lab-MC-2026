function graficarFuncion(ax, tipo, f, g, a, b, resultado, resultado2)

  % Resultado opcional para comparar dos metodos.
  if nargin < 8
    resultado2 = [];
  endif

  % Verificar que el eje grafico siga siendo valido.
  if isempty(ax) || ~isgraphics(ax)
    return;
  endif

  if ~isfinite(a) || ~isfinite(b) || a >= b
    error('El intervalo del grafico debe cumplir a < b.');
  endif

  % El intervalo horizontal es el seleccionado por el usuario. No se
  % extiende de forma simetrica hacia valores que no pertenecen al problema.
  xMin = a;
  xMax = b;
  x = linspace(xMin, xMax, 600);

  yf = arrayfun(@(v) muestra(f, v), x);

  % g(x) corresponde si el modo o alguno de los resultados es Punto Fijo.
  mostrarG = ~isempty(g) && (esPuntoFijo(tipo) || ...
    resultadoEsPuntoFijo(resultado) || resultadoEsPuntoFijo(resultado2));

  if mostrarG
    yg = arrayfun(@(v) muestra(g, v), x);
  else
    yg = [];
  endif

  % Preparar el area de grafico.
  cla(ax);
  hold(ax, 'on');
  grid(ax, 'on');
  box(ax, 'on');

  objetosLeyenda = [];
  textosLeyenda = {};

  % Funcion original.
  h = plot(ax, x, yf, 'b-', 'LineWidth', 1.8);
  [objetosLeyenda, textosLeyenda] = agregarLeyenda( ...
    objetosLeyenda, textosLeyenda, h, 'Funcion original f(x)');

  % Funcion de iteracion y recta de referencia para Punto Fijo.
  if mostrarG
    h = plot(ax, x, yg, 'Color', [.15, .55, .20], ...
             'LineWidth', 1.6);
    [objetosLeyenda, textosLeyenda] = agregarLeyenda( ...
      objetosLeyenda, textosLeyenda, h, 'Funcion de iteracion g(x)');

    h = plot(ax, x, x, 'k:', 'LineWidth', 1.4);
    [objetosLeyenda, textosLeyenda] = agregarLeyenda( ...
      objetosLeyenda, textosLeyenda, h, 'Recta y = x');
  endif

  % El eje y=0 ayuda a ubicar las raices. El eje x=0 solo se dibuja cuando
  % pertenece al intervalo visible.
  h = plot(ax, [xMin, xMax], [0, 0], ...
           'Color', [.35, .35, .35], 'LineStyle', '--', 'LineWidth', 1.0);
  [objetosLeyenda, textosLeyenda] = agregarLeyenda( ...
    objetosLeyenda, textosLeyenda, h, 'Referencia y = 0');

  % Los limites verticales se obtienen de todos los valores validos que
  % realmente se representan, incluidos los historiales disponibles.
  valoresY = [yf(isfinite(yf)), yg(isfinite(yg))];

  if mostrarG
    valoresY = [valoresY, x];
  endif

  resultados = {resultado, resultado2};

  for k = 1:numel(resultados)
    r = resultados{k};

    if isempty(r)
      continue;
    endif

    if isfield(r, 'historial') && ~isempty(r.historial)
      hist = r.historial(:)';
      hist = hist(isfinite(hist) & hist >= xMin & hist <= xMax);
      valoresY = [valoresY, arrayfun(@(v) muestra(f, v), hist)];
    endif

    if isfield(r, 'raiz') && isfinite(r.raiz) && ...
       r.raiz >= xMin && r.raiz <= xMax
      valoresY(end+1) = muestra(f, r.raiz);
    endif
  endfor

  [yMin, yMax] = limitesConMargen(valoresY);
  ySpan = yMax - yMin;

  if xMin <= 0 && xMax >= 0
    plot(ax, [0, 0], [yMin, yMax], ...
         'Color', [.65, .65, .65], 'LineStyle', '--', ...
         'LineWidth', 0.8, 'HandleVisibility', 'off');
  endif

  % Iteraciones y aproximaciones finales. Los estilos dependen del metodo,
  % no del orden elegido para la comparacion.
  for k = 1:numel(resultados)
    r = resultados{k};

    if isempty(r) || ~isfield(r, 'raiz') || ~isfinite(r.raiz)
      continue;
    endif

    pf = resultadoEsPuntoFijo(r);
    acelerado = resultadoEsAitken(r);

    if isfield(r, 'historial') && numel(r.historial) > 1 && ...
       numel(r.historial) <= 30
      hist = r.historial(:)';
      validos = isfinite(hist) & hist >= xMin & hist <= xMax;
      hist = hist(validos);

      if ~isempty(hist)
        yh = arrayfun(@(v) muestra(f, v), hist);

        if acelerado
          colorHist = [.10, .55, .60];
          marcadorHist = '^';
          nombreHist = 'Iteraciones de Aitken';
        elseif pf
          colorHist = [.55, .20, .65];
          marcadorHist = 'd';
          nombreHist = 'Iteraciones de Punto Fijo';
        else
          colorHist = [.85, .25, .15];
          marcadorHist = 'o';
          nombreHist = 'Iteraciones de Regula Falsi';
        endif

        h = plot(ax, hist, yh, '--', 'Color', colorHist, ...
                 'Marker', marcadorHist, 'MarkerSize', 5, ...
                 'LineWidth', 1.0);
        [objetosLeyenda, textosLeyenda] = agregarLeyenda( ...
          objetosLeyenda, textosLeyenda, h, nombreHist);
      endif
    endif

    if r.raiz < xMin || r.raiz > xMax
      continue;
    endif

    yr = muestra(f, r.raiz);

    if acelerado
      h = plot(ax, r.raiz, yr, '^', ...
               'Color', [.05, .40, .45], ...
               'MarkerFaceColor', [.35, .80, .85], ...
               'MarkerSize', 8, 'LineWidth', 1.4);
      nombre = 'Aproximacion de Aitken';
      desplazamiento = 0.17;
    elseif pf
      h = plot(ax, r.raiz, yr, 'd', ...
               'Color', [.45, .05, .60], ...
               'MarkerFaceColor', [.85, .55, .95], ...
               'MarkerSize', 7, 'LineWidth', 1.4);
      nombre = 'Aproximacion de Punto Fijo';
      desplazamiento = 0.17;
    else
      h = plot(ax, r.raiz, yr, 'o', ...
               'Color', [.85, .10, .05], ...
               'MarkerFaceColor', 'none', ...
               'MarkerSize', 11, 'LineWidth', 1.8);
      nombre = 'Aproximacion de Regula Falsi';
      desplazamiento = 0.08;
    endif

    [objetosLeyenda, textosLeyenda] = agregarLeyenda( ...
      objetosLeyenda, textosLeyenda, h, nombre);

    % La anotacion se desplaza solo en vertical; el marcador conserva las
    % coordenadas numericas reales de la aproximacion.
    text(ax, r.raiz, yr + desplazamiento*ySpan, ...
         sprintf('%s: x = %.8g', nombreCorto(pf, acelerado), r.raiz), ...
         'Color', get(h, 'Color'), 'FontSize', 9, ...
         'HorizontalAlignment', alineacionEtiqueta(r.raiz, xMin, xMax), ...
         'BackgroundColor', [1, 1, 1], 'Margin', 2, ...
         'Clipping', 'on');
  endfor

  xlim(ax, [xMin, xMax]);
  ylim(ax, [yMin, yMax]);

  set(ax, 'FontSize', 11, 'LineWidth', 1.0, 'TickDir', 'out');
  xlabel(ax, 'x', 'FontSize', 13);
  ylabel(ax, 'y', 'FontSize', 13);
  title(ax, 'Funciones, iteraciones y aproximaciones', 'FontSize', 14);

  if ~isempty(objetosLeyenda)
    legend(ax, objetosLeyenda, textosLeyenda, 'Location', 'northeast');
  endif

  hold(ax, 'off');

endfunction


function [objetos, textos] = agregarLeyenda(objetos, textos, h, texto)

  objetos(end+1) = h;
  textos{end+1} = texto;

endfunction


function tf = resultadoEsPuntoFijo(r)

  tf = ~isempty(r) && isfield(r, 'metodo') && esPuntoFijo(r.metodo);

endfunction


function tf = resultadoEsAitken(r)

  tf = ~isempty(r) && isfield(r, 'metodo') && ...
       ~isempty(strfind(r.metodo, 'Aitken'));

endfunction


function tf = esPuntoFijo(nombre)

  tf = ischar(nombre) && ...
       (~isempty(strfind(nombre, 'Iteracion')) || ...
        ~isempty(strfind(nombre, 'Punto Fijo')) || ...
        ~isempty(strfind(nombre, 'Aitken')));

endfunction


function nombre = nombreCorto(esPF, esAcelerado)

  if esAcelerado
    nombre = 'Aitken';
  elseif esPF
    nombre = 'Punto Fijo';
  else
    nombre = 'Regula Falsi';
  endif

endfunction


function alineacion = alineacionEtiqueta(x, xMin, xMax)

  posicion = (x-xMin)/(xMax-xMin);

  if posicion < 0.25
    alineacion = 'left';
  elseif posicion > 0.75
    alineacion = 'right';
  else
    alineacion = 'center';
  endif

endfunction


function [yMin, yMax] = limitesConMargen(valores)

  valores = valores(isfinite(valores));

  if isempty(valores)
    yMin = -1;
    yMax = 1;
    return;
  endif

  yMin = min(valores);
  yMax = max(valores);

  if yMin == yMax
    margen = max(1, 0.1*abs(yMin));
  else
    margen = 0.08*(yMax-yMin);
  endif

  yMin = yMin - margen;
  yMax = yMax + margen;

endfunction


function y = muestra(f, x)

  % Los puntos fuera del dominio se dejan como huecos.
  try
    y = evaluarFuncion(f, x);
  catch
    y = NaN;
  end_try_catch

endfunction

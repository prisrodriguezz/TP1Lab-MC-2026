
function r = iteracion(g, x0, tolerancia, maxIter, f, expresionG, intervalo)

  % Valores por defecto para parametros opcionales.
  if nargin < 7
    intervalo = [];
  endif

  if nargin < 6
    expresionG = '(g ingresada)';
  endif

  if nargin < 5
    f = [];
  endif

  % Crear estructura base del resultado.
  r = resultadoBase('Iteracion / Punto Fijo', tolerancia);

  % Validar parametros generales.
  validarParametros(tolerancia, maxIter, x0, intervalo);
  validarPF(x0, tolerancia, maxIter);

  % Definir columnas de la tabla de iteraciones.
  r.columnas = {'xn', 'g(xn)', 'Error'};

  % ---------------------------------------------------------
  % ANALISIS PRELIMINAR DE CONVERGENCIA
  % ---------------------------------------------------------

  if isempty(intervalo)
    puntos = linspace(x0-1, x0+1, 51);
    etiqueta = 'entorno [x0-1,x0+1]';
  else
    puntos = linspace(intervalo(1), intervalo(2), 51);
    etiqueta = sprintf('[%.6g, %.6g]', ...
      intervalo(1), intervalo(2));
  endif

  dg = NaN(size(puntos));

  for j = 1:numel(puntos)
    try
      dg(j) = derivadaNumerica(g, puntos(j), 1);
    catch
      % Si no se puede evaluar la derivada, el diagnostico
      % queda indeterminado. La iteracion puede continuar.
    end_try_catch
  endfor

  % Estimar la condicion de contraccion por muestreo.
  derivadasValidas = dg(isfinite(dg));

  if isempty(derivadasValidas)
    q = NaN;
    cumple = false;
    diagnostico = 'INDETERMINADO: no se pudo estimar la derivada.';
  else
    q = max(abs(derivadasValidas));
    cumple = numel(derivadasValidas) == numel(dg) && q < 1;

    if numel(derivadasValidas) ~= numel(dg)
      diagnostico = ...
        'INDETERMINADO: algunas derivadas no pudieron evaluarse.';
    elseif cumple
      diagnostico = ...
        'Compatible con contraccion en las muestras analizadas.';
    else
      diagnostico = ...
        'No cumple la condicion de contraccion en todas las muestras.';
    endif
  endif

  r.analisis = { ...
    ['Funcion de iteracion: g(x) = ', expresionG], ...
    'Formula: x_(n+1) = g(x_n)', ...
    sprintf('Analisis por muestreo en %s.', etiqueta), ...
    sprintf('Maximo |g''(x)| estimado: %.8g', q), ...
    ['Diagnostico preliminar: ', diagnostico], ...
    'Este analisis es orientativo y no garantiza convergencia.', ...
    'Criterio de parada: |x_(n+1)-x_n| < E.', ...
    sprintf('Tolerancia solicitada: E = %.10g', tolerancia)};

  % ---------------------------------------------------------
  % ITERACIONES
  % ---------------------------------------------------------

  datos = cell(maxIter, 3);
  hist = zeros(maxIter+1, 1);
  hist(1) = x0;

  xn = x0;
  err = NaN;
  r.converge = false;

  % El tiempo mide solamente el algoritmo iterativo.
  reloj = tic;

  for k = 1:maxIter

    % Calcular la siguiente aproximacion.
    gx = evaluarFuncion(g, xn);
    siguiente = gx;
    err = abs(siguiente - xn);

    if ~all(isfinite([gx, siguiente, err]))
      error('La iteracion produjo NaN o Inf.');
    endif

    % Guardar la iteracion.
    datos(k,:) = {xn, gx, err};
    hist(k+1) = siguiente;

    xn = siguiente;

    % Criterio de parada: solo error entre aproximaciones.
    if err < tolerancia
      r.converge = true;
      break;
    endif

  endfor

  r.tiempo = toc(reloj);
  r.iteraciones = k;
  r.raiz = xn;
  r.error = err;
  r.tabla = datos(1:k,:);
  r.historial = hist(1:k+1);

  % ---------------------------------------------------------
  % RESULTADOS FINALES
  % ---------------------------------------------------------

  % Residuo informativo: no participa en la parada.
  try
    if isempty(f)
      r.valorFuncion = xn - evaluarFuncion(g, xn);
    else
      r.valorFuncion = evaluarFuncion(f, xn);
    endif
  catch
    r.valorFuncion = NaN;
  end_try_catch

  % Clasificar el comportamiento observado.
  r.comportamiento = clasificarComportamiento(r.historial, ...
    r.converge);

  if r.converge
    r.mensaje = ...
      'Se alcanzo la tolerancia para el error entre aproximaciones.';
  else
    r.mensaje = ...
      'No se alcanzo la tolerancia dentro del maximo de iteraciones.';
  endif

  r.analisis{end+1} = ...
    ['Comportamiento observado: ', r.comportamiento];

  r.analisis{end+1} = sprintf( ...
    'Iteraciones realizadas: %d.', r.iteraciones);

  r.analisis{end+1} = sprintf( ...
    'Error final entre aproximaciones: %.10g.', r.error);

  if isempty(f)
    r.analisis{end+1} = ...
      'No se proporciono f(x); el residuo se calcula con x-g(x).';
  else
    r.analisis{end+1} = sprintf( ...
      'Residuo informativo |f(xn)|: %.10g (no interviene en la parada).', ...
      abs(r.valorFuncion));
  endif

  % Informacion adicional si se proporciono un intervalo.
  if ~isempty(intervalo)
    r.analisis{end+1} = sprintf( ...
      'Muestras de g dentro del intervalo: %d; x0 dentro: %d.', ...
      all(isfinite(arrayfun(@(x) evaluarFuncion(g,x), puntos))) && ...
        all(arrayfun(@(x) evaluarFuncion(g,x), puntos) >= intervalo(1) & ...
            arrayfun(@(x) evaluarFuncion(g,x), puntos) <= intervalo(2)), ...
      x0 >= intervalo(1) && x0 <= intervalo(2));
  endif

  r.analisis{end+1} = ['Finalizacion: ', r.mensaje];

endfunction


function comportamiento = clasificarComportamiento(historial, converge)

  % Clasificacion orientativa basada en las ultimas diferencias.
  % No constituye una demostracion matematica de convergencia.

  if numel(historial) < 4
    comportamiento = ...
      'Indeterminado: pocas aproximaciones para clasificar.';
    return;
  endif

  diferencias = diff(historial);
  diferencias = diferencias(isfinite(diferencias));

  if numel(diferencias) < 3
    comportamiento = ...
      'Indeterminado: no hay suficientes diferencias validas.';
    return;
  endif

  ultimas = diferencias(max(1,end-3):end);
  magnitudes = abs(ultimas);

  if converge
    if all(ultimas(2:end).*ultimas(1:end-1) < 0)
      comportamiento = ...
        'Convergencia oscilatoria observada.';
    else
      comportamiento = ...
        'Convergencia observada; sin alternancia sostenida.';
    endif
    return;
  endif

  if all(magnitudes(2:end) > magnitudes(1:end-1))
    comportamiento = ...
      'Posible divergencia: las diferencias aumentan.';
  elseif all(ultimas(2:end).*ultimas(1:end-1) < 0)
    comportamiento = ...
      'Oscilacion sin convergencia dentro del limite.';
  else
    comportamiento = ...
      'Indeterminado: no se observa un patron concluyente.';
  endif

endfunction


function validarPF(x0, tol, n)

  % Validar punto inicial.
  if ~isscalar(x0) || ~isreal(x0)
    error('Punto Fijo requiere un valor real escalar x0.');
  endif

  % Validar valores finitos.
  if ~all(isfinite([x0, tol, n]))
    error('x0, tolerancia y maximo deben ser finitos.');
  endif

  % Validar tolerancia.
  if tol <= 0
    error('La tolerancia debe ser mayor que cero.');
  endif

  % Validar cantidad maxima de iteraciones.
  if n < 1 || n ~= fix(n)
    error('El maximo debe ser un entero positivo.');
  endif

endfunction
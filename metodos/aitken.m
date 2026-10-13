function r = aitken(g, x0, tolerancia, maxIter, f, expresionG, intervalo)

  if nargin < 7, intervalo = []; endif
  if nargin < 6, expresionG = '(g ingresada)'; endif
  if nargin < 5, f = []; endif

  r = resultadoBase('Iteracion + Aitken', tolerancia);

  validarParametros(tolerancia, maxIter, x0, intervalo);

  if ~isscalar(x0) || ~isreal(x0) || ~isfinite(x0)
    error('Aitken requiere un valor inicial x0 escalar, real y finito.');
  endif

  if ~isscalar(tolerancia) || ~isfinite(tolerancia) || tolerancia <= 0
    error('La tolerancia debe ser positiva y finita.');
  endif

  if ~isscalar(maxIter) || maxIter < 1 || maxIter ~= fix(maxIter)
    error('El maximo de iteraciones debe ser un entero positivo.');
  endif

  r.columnas = {'x0', 'x1 = g(x0)', 'x2 = g(x1)', 'Aprox. de Aitken', 'Error absoluto'};

  r.analisis = {
    ['Funcion de iteracion: g(x) = ', expresionG],
    'Se calculan dos aproximaciones simples por cada ciclo de Aitken.',
    'Formula: xA = Base - (x1-Base)^2 / (x2-2*x1+Base).',
    'Si no converge, la aproximacion acelerada pasa a ser la nueva base.',
    'Criterio de parada: error absoluto entre aproximaciones aceleradas consecutivas < tolerancia.',
    sprintf('Tolerancia solicitada: %.10g', tolerancia)
  };

  if ~isempty(intervalo)
    puntos = linspace(intervalo(1), intervalo(2), 51);
    dg = NaN(size(puntos));
    imagen = NaN(size(puntos));

    for j = 1:numel(puntos)
      try
        imagen(j) = evaluarFuncion(g, puntos(j));
        dg(j) = derivadaNumerica(g, puntos(j), 1);
      catch
      end_try_catch
    endfor

    r.analisis{end+1} = sprintf('Muestras con |g''| < 1: %d de %d.', sum(isfinite(dg) & abs(dg) < 1), numel(puntos));

    r.analisis{end+1} = sprintf('Muestras de g dentro del intervalo: %d de %d.',
    sum(isfinite(imagen) & imagen >= intervalo(1) & imagen <= intervalo(2)), numel(puntos));

    r.analisis{end+1} = 'El muestreo aporta evidencia, pero no demuestra por si solo las condiciones del teorema de punto fijo ni la convergencia de Aitken.';
  endif

  datos = cell(maxIter, 5);
  hist = NaN(maxIter, 1);

  base = x0;
  anteriorA = NaN;
  xA = NaN;
  err = Inf;

  tic;

  for k = 1:maxIter

    % Dos iteraciones del metodo original.
    x1 = evaluarFuncion(g, base);
    x2 = evaluarFuncion(g, x1);

    delta = x1 - base;
    delta2 = x2 - 2*x1 + base;

    if ~all(isfinite([base, x1, x2, delta, delta2]))
      error('La iteracion produjo valores NaN o Inf.');
    endif

    % Verificar que se pueda aplicar la formula de Aitken.
    escala = max(1, max(abs([base, x1, x2])));

    if abs(delta2) <= 1e-14 * escala
      error(['El denominador de Aitken es nulo o demasiado pequeno. ',
      'No se puede calcular la aproximacion acelerada.']);
    endif

    % Aproximacion acelerada de Aitken.
    xA = base - delta^2 / delta2;

    if ~isreal(xA) || ~isfinite(xA)
      error('Aitken produjo una aproximacion no real o no finita.');
    endif

    % Error absoluto entre aproximaciones aceleradas consecutivas.
    if k == 1
      err = Inf;
    else
      err = abs(xA - anteriorA);
    endif

    datos(k,:) = {base, x1, x2, xA, err};
    hist(k) = xA;

    % El primer ciclo no tiene una aproximacion acelerada anterior
    % con la cual comparar el error.
    if k > 1 && err < tolerancia
      r.converge = true;
      break;
    endif

    % La aproximacion acelerada se utiliza como nueva base.
    anteriorA = xA;
    base = xA;

  endfor

  r.tiempo = toc;
  r.iteraciones = k;
  r.raiz = xA;
  r.error = err;
  r.tabla = datos(1:k,:);
  r.historial = hist(1:k);

  % Valor de la funcion original en la aproximacion final.
  if isempty(f)
    r.valorFuncion = NaN;
    r.analisis{end+1} = 'No se proporciono f(x); no se calcula el residuo de la funcion original.';
  else
    r.valorFuncion = evaluarFuncion(f, xA);
  endif

  if r.converge
    r.mensaje = 'Convergencia alcanzada: error absoluto entre aproximaciones aceleradas consecutivas menor que la tolerancia.';
  else
    r.mensaje = 'No se alcanzo la tolerancia dentro del maximo de ciclos de Aitken.';
  endif

  r.analisis{end+1} = 'Cada ciclo genera dos aproximaciones simples y una aproximacion acelerada.';

  r.analisis{end+1} = 'El criterio de parada utiliza exclusivamente el error absoluto entre aproximaciones aceleradas consecutivas.';

  r.analisis{end+1} = ['Finalizacion: ', r.mensaje];

endfunction

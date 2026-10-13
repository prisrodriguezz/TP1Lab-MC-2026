function r = interpolacionLineal(f, a, b, tolerancia, maxIter)

  % Crear estructura base del resultado.
  r = resultadoBase('Interpolacion Lineal / Regula Falsi', tolerancia);

  % Validar parametros generales.
  validarParametros(tolerancia, maxIter, [], [a, b]);

  % Definir columnas de la tabla de iteraciones.
  r.columnas = {'a', 'b', 'f(a)', 'f(b)', ...
    'x interpolado', 'f(x)', 'Nuevo intervalo', 'Error'};

  % Validar intervalo.
  if a >= b
    error('Debe cumplirse a < b.');
  endif

  % Validar tolerancia.
  if tolerancia <= 0 || ~isfinite(tolerancia)
    error('La tolerancia debe ser positiva y finita.');
  endif

  % Validar cantidad maxima de iteraciones.
  if maxIter < 1 || maxIter ~= fix(maxIter)
    error('El maximo de iteraciones debe ser un entero positivo.');
  endif

  % Evaluar la funcion en los extremos.
  fa = evaluarFuncion(f, a);
  fb = evaluarFuncion(f, b);

  % Verificar valores finitos y cambio de signo.
  if ~all(isfinite([fa, fb])) || fa ~= 0 && fb ~= 0 && sign(fa) == sign(fb)
    error('Regula Falsi requiere valores finitos y f(a)*f(b) < 0.');
  endif

  % Verificar si alguno de los extremos es raiz exacta.
  if fa == 0 || fb == 0

    if fa == 0
      r.raiz = a;
    else
      r.raiz = b;
    endif

    r.valorFuncion = 0;
    r.error = 0;
    r.converge = true;
    r.mensaje = 'Raiz exacta encontrada en un extremo; no fue necesario iterar.';
    r.analisis = {r.mensaje};
    r.historial = r.raiz;

    return;

  endif

  % Registrar informacion teorica del metodo.
  r.analisis = {'Formula: x = (a*f(b) - b*f(a)) / (f(b) - f(a))', ...
    'Se reemplaza el extremo que tiene el mismo signo que f(x).', ...
    'Parada: |x_n-x_(n-1)| < E, o raiz exacta.', ...
    sprintf('Tolerancia solicitada: E = %.10g', tolerancia)};

  % Inicializar estructuras y comenzar la medicion del algoritmo.
  datos = cell(maxIter, 8);
  anterior = NaN;
  hist = zeros(maxIter, 1);

  tic;

  for k = 1:maxIter

    % Verificar que el denominador sea valido.
    den = fb - fa;

    if abs(den) <= eps*max(1, max(abs([fa, fb])))
      error('Denominador nulo o demasiado pequeno en Regula Falsi.');
    endif

    % Guardar los valores del intervalo actual
    aa = a;
    bb = b;
    faa = fa;
    fbb = fb;

    % Calcular punto de interseccion de la secante con y = 0
    x = (a*fb - b*fa)/den;
    fx = evaluarFuncion(f, x);

    if ~isfinite(fx)
      error('La funcion produjo NaN o Inf durante Regula Falsi.');
    endif

    % Calcular el error entre aproximaciones consecutivas
    if k == 1
      err = NaN;  %En la 1er iteracion no existe una aprox. anterior calculada
    else
      err = abs(x-anterior);
    endif

    % Actualizar el intervalo segun el cambio de signo.
    if fx == 0

      % Se encontro una raiz exacta.
      a = x;
      b = x;
      fa = 0;
      fb = 0;

    elseif sign(fa) ~= sign(fx)

      b = x;
      fb = fx;

    elseif sign(fx) ~= sign(fb)

      a = x;
      fa = fx;

    endif

    % Registrar el intervalo despues de la actualizacion.
    intervaloNuevo = sprintf('[%.8g, %.8g]', a, b);

    % Registrar los datos de la iteracion.
    datos(k,:) = {aa, bb, faa, fbb, x, fx, intervaloNuevo, err};

    hist(k) = x;
    anterior = x;

    % Criterio de parada: cambio entre aproximaciones
    % menor que la tolerancia, o raiz exacta.
    if fx == 0 || (k > 1 && err < tolerancia)
      r.converge = true;
      break;
    endif

  endfor

  % Guardar resultados finales.
  r.tiempo = toc;
  r.iteraciones = k;
  r.raiz = x;
  r.valorFuncion = fx;
  r.error = err;
  r.tabla = datos(1:k,:);
  r.historial = hist(1:k);

  % Generar mensaje segun el estado de convergencia.
  if r.converge

    r.mensaje = ...
      'Se cumplio el criterio de parada: cambio entre aproximaciones menor que E o raiz exacta.';

  else

    r.mensaje = ...
      'No se alcanzo el criterio de parada dentro del numero maximo de iteraciones.';

  endif

  % Agregar observaciones del metodo.
  r.analisis{end+1} = ...
    'Se verifico cambio de signo. La garantia teorica requiere continuidad en todo [a,b]; el muestreo no la demuestra.';

  r.analisis{end+1} = ['Finalizacion: ', r.mensaje];

endfunction
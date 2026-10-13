
function r = tanteo(f, a, b, valor, modo)

  % Valores por defecto
  if nargin < 4
    valor = 20;
  endif

  if nargin < 5
    modo = 'automatico';
  endif

  % Validar el intervalo
  validarParametros(1,1,[],[a,b]);

  if a >= b
    error('Para Tanteo debe cumplirse x inicial < x final.');
  endif

  % Validar el modo seleccionado
  if ~ischar(modo) || ...
      ~any(strcmp(modo,{'manual','automatico'}))
    error('El modo debe ser manual o automatico.');
  endif

  % Determinar el incremento h
  if strcmp(modo,'manual')

    % El usuario ingresa directamente el incremento
    h = valor;

    if ~isscalar(h) || ~isreal(h) || ...
        ~isfinite(h) || h <= 0
      error('El incremento h debe ser un numero real positivo y finito.');
    endif

  else

    % El usuario ingresa la cantidad de divisiones
    cantidad = valor;

    if ~isscalar(cantidad) || ~isreal(cantidad) || ...
        ~isfinite(cantidad) || cantidad < 2 || ...
        cantidad ~= fix(cantidad)
      error('La cantidad de divisiones debe ser un entero mayor o igual que 2.');
    endif

    h = (b-a)/cantidad;

  endif

  % Generar los puntos respetando el incremento h
  n = floor((b-a)/h + 1e-12);
  x = a + (0:n)*h;

  % Corregir diferencias de redondeo numerico
  margen = 1e-10 * max([1,abs(a),abs(b),abs(h)]);

  if abs(x(end)-b) <= margen
    x(end) = b;
  else
    % Incluir el extremo final sin sobrepasarlo
    x(end+1) = b;
  endif

  % Evaluar la funcion en todos los puntos
  y = zeros(size(x));

  for k = 1:numel(x)
    y(k) = evaluarFuncion(f,x(k));
  endfor

  % Comprobar que las evaluaciones sean validas
  if ~all(isfinite(y))
    error('La funcion produjo NaN o Inf durante el tanteo.');
  endif

  % Construir tabla y detectar cambios de signo
  tabla = cell(numel(x),4);
  cambios = [];

  for k = 1:numel(x)

    if k < numel(x)

      cambio = y(k) ~= 0 && y(k+1) ~= 0 && ...
        sign(y(k)) ~= sign(y(k+1));

      if cambio
        cambios(end+1,:) = [x(k),x(k+1)];
      endif

    else
      cambio = false;
    endif

    tabla(k,:) = {k-1,x(k),y(k),cambio};

  endfor

  % Guardar los resultados principales
  r = struct('tabla',{tabla}, ...
    'columnas',{{'Punto','x','f(x)', ...
    'Cambio de signo con siguiente'}}, ...
    'intervalos',cambios);

  % Identificar raices exactas en los puntos evaluados
  r.raicesExactas = x(y == 0);

  % Guardar los datos utilizados
  r.xInicial = a;
  r.xFinal = b;
  r.incremento = h;
  r.cantidadPuntos = numel(x);
  r.modo = modo;

  if strcmp(modo,'automatico')
    r.cantidadDivisiones = cantidad;
  else
    r.cantidadDivisiones = NaN;
  endif

  % Generar mensaje segun los resultados
  if ~isempty(r.raicesExactas)

    r.mensaje = sprintf( ...
      'Se encontraron %d raiz/raices exactas y %d cambios de signo.', ...
      numel(r.raicesExactas),rows(cambios));

  elseif isempty(cambios)

    r.mensaje = ...
      'No se detectaron cambios de signo con esta particion.';

  else

    r.mensaje = sprintf( ...
      'Se detectaron %d subintervalo(s) con cambio de signo.', ...
      rows(cambios));

  endif

endfunction
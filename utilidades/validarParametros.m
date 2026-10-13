function validarParametros(tol, maxIter, x0, intervalo)

  % Validacion compartida; no cambia las formulas de los metodos

  % Validar tolerancia
  if ~isscalar(tol) || ~isreal(tol) || ~isfinite(tol) || tol<=0

    error('La tolerancia debe ser un numero real, positivo y finito.');

  endif

  % Validar cantidad maxima de iteraciones
  if ~isscalar(maxIter) || ~isreal(maxIter) || ~isfinite(maxIter) || maxIter<1 || maxIter~=fix(maxIter)

    error('El maximo de iteraciones debe ser un entero positivo y finito.');

  endif

  % Validar valor inicial (cuando se proporciona)
  if nargin>=3 && ~isempty(x0) && (~isscalar(x0) || ~isreal(x0) || ~isfinite(x0))

    error('x0 debe ser un numero real, escalar y finito.');

  endif

  % Validar intervalo (cuando se proporciona)
  if nargin>=4 && ~isempty(intervalo)

    if numel(intervalo)~=2 || ~isreal(intervalo) || ~all(isfinite(intervalo)) || intervalo(1)>=intervalo(2)

      error('El intervalo debe tener extremos reales y finitos con a < b.');

    endif

  endif

endfunction
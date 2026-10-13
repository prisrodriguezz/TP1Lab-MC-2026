function r = resultadoBase(nombre, tolerancia)

  % Estructura base para almacenar el resultado de un metodo
  r = struct('metodo', nombre, 'raiz', NaN, 'valorFuncion', NaN, ...

    % Datos del proceso de iteracion
    'iteraciones', 0, 'error', Inf, 'tiempo', 0, 'tabla', {{}}, ...

    % Estado de convergencia y columnas de la tabla
    'columnas', {{}}, 'converge', false, 'mensaje', '', ...

    % Informacion adicional del resultado
    'analisis', {{}}, 'tolerancia', tolerancia, 'historial', []);

endfunction
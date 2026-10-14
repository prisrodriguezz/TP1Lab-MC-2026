
function interfazMetodos()

  % Metodos numericos disponibles
  metodos = {'Interpolacion Lineal','Iteracion', 'Iteracion + Aitken'};

  % Ventana principal
  fig = figure('Name','Laboratorio de Metodos Numericos', ...
    'NumberTitle','off','MenuBar','none', ...
    'Position',[60 40 1300 800], ...
    'Color',[0.94 0.94 0.94]);

  % Panel izquierdo: entradas y operaciones
  p = uipanel(fig,'Title','Configuracion', ...
    'Units','normalized','Position',[.01 .03 .29 .94]);

  % ---------------------------------------------------------
  % FUNCION DEL PROBLEMA
  % ---------------------------------------------------------
  uicontrol(p,'Style','text','String','FUNCION DEL PROBLEMA', ...
    'Units','normalized','Position',[.04 .95 .92 .035], ...
    'FontWeight','bold','HorizontalAlignment','left');

  [h.exprF,h.lblF] = campo(p,'f(x)',.905,'x^3-2*x-5');

  % ---------------------------------------------------------
  % DATOS PARA TANTEO
  % ---------------------------------------------------------
  uicontrol(p,'Style','text','String','TANTEO', ...
    'Units','normalized','Position',[.04 .87 .92 .035], ...
    'FontWeight','bold','HorizontalAlignment','left');

  [h.xInicial,h.lblXInicial] = campo(p,'x inicial',.83,'0');
  [h.xFinal,h.lblXFinal] = campo(p,'x final',.79,'5');

  % Selector del modo de incremento
  h.lblModoTanteo = uicontrol(p,'Style','text', ...
    'String','Incremento', ...
    'Units','normalized','Position',[.04 .75 .34 .035], ...
    'HorizontalAlignment','left');

  h.modoTanteo = uicontrol(p,'Style','popupmenu', ...
    'String',{'Manual (h)','Automatico (n)'}, ...
    'Value',2, ...
    'Units','normalized','Position',[.38 .75 .58 .04], ...
    'Callback',@actualizarModoTanteo);

  % Valor de h manual o cantidad de divisiones automatica
  [h.valorTanteo,h.lblValorTanteo] = ...
    campo(p,'Divisiones (n)',.71,'20');

  uicontrol(p,'Style','pushbutton','String','Ejecutar Tanteo', ...
    'Units','normalized','Position',[.05 .665 .9 .04], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@hacerTanteo);

  % ---------------------------------------------------------
  % CALCULO DEL METODO NUMERICO
  % ---------------------------------------------------------
  uicontrol(p,'Style','text','String','CALCULO DEL METODO', ...
    'Units','normalized','Position',[.04 .615 .92 .035], ...
    'FontWeight','bold','HorizontalAlignment','left');

  uicontrol(p,'Style','text','String','Modo', ...
    'Units','normalized','Position',[.04 .57 .34 .035], ...
    'HorizontalAlignment','left');

  h.modo = uicontrol(p,'Style','popupmenu', ...
    'String',{'Metodo individual','Comparar metodos'}, ...
    'Units','normalized','Position',[.38 .57 .58 .04], ...
    'Callback',@actualizarCampos);

  h.lblM1 = uicontrol(p,'Style','text','String','Metodo', ...
    'Units','normalized','Position',[.04 .525 .34 .035], ...
    'HorizontalAlignment','left');

  h.metodo1 = uicontrol(p,'Style','popupmenu','String',metodos, ...
    'Units','normalized','Position',[.38 .525 .58 .04], ...
    'Callback',@actualizarCampos);

  h.lblM2 = uicontrol(p,'Style','text','String','Metodo 2', ...
    'Units','normalized','Position',[.04 .48 .34 .035], ...
    'HorizontalAlignment','left');

  h.metodo2 = uicontrol(p,'Style','popupmenu','String',metodos, ...
    'Value',2,'Units','normalized', ...
    'Position',[.38 .48 .58 .04], ...
    'Callback',@actualizarCampos);

  [h.a,h.lblA] = campo(p,'a',.435,'2');
  [h.b,h.lblB] = campo(p,'b',.39,'3');
  [h.exprG,h.lblG] = campo(p,'g(x)',.345,'(2*x+5)^(1/3)');
  [h.x0,h.lblX0] = campo(p,'x0 requerido',.30,'2');
  [h.tol,h.lblTol] = campo(p,'Tolerancia E',.255,'1e-6');
  [h.maxIter,h.lblMax] = campo(p,'Max. iter.',.21,'100');

  % Botones de calculo y gestion de resultados
  uicontrol(p,'Style','pushbutton','String','Calcular', ...
    'Units','normalized','Position',[.04 .155 .29 .04], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@calcular);

  uicontrol(p,'Style','pushbutton','String','Graficar', ...
    'Units','normalized','Position',[.355 .155 .29 .04], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@graficar);

  uicontrol(p,'Style','pushbutton','String','Limpiar', ...
    'Units','normalized','Position',[.67 .155 .29 .04], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@limpiar);

  % Detalles individuales para el modo comparacion
  h.det1 = uicontrol(p,'Style','pushbutton', ...
    'String','Ver detalle Metodo 1', ...
    'Units','normalized','Position',[.05 .095 .9 .035], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@(s,e)verDetalle(1));

  h.det2 = uicontrol(p,'Style','pushbutton', ...
    'String','Ver detalle Metodo 2', ...
    'Units','normalized','Position',[.05 .05 .9 .035], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@(s,e)verDetalle(2));

  h.estado = uicontrol(p,'Style','text','String','Listo.', ...
    'Units','normalized','Position',[.04 .005 .92 .035], ...
    'HorizontalAlignment','left');

  % ---------------------------------------------------------
  % PANELES DE RESULTADOS
  % ---------------------------------------------------------
  
  % Botones de navegacion
  uicontrol(fig,'Style','pushbutton','String','Resultados y Análisis', ...
    'Units','normalized','Position',[.32 .93 .21 .045], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@(s,e)mostrarPanel(1));

  uicontrol(fig,'Style','pushbutton','String','Iteraciones', ...
    'Units','normalized','Position',[.55 .93 .17 .045], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@(s,e)mostrarPanel(2));

  uicontrol(fig,'Style','pushbutton','String','Grafico', ...
    'Units','normalized','Position',[.74 .93 .17 .045], ...
    'BackgroundColor',[0.88 0.91 0.96], ...
    'Callback',@(s,e)mostrarPanel(3));

  % Panel principal: Resultados y Analisis
  h.paneles(1) = uipanel(fig,'Title','Resultados y Analisis', ...
    'Units','normalized','Position',[.31 .03 .68 .89]);

  % Panel de iteraciones
  h.paneles(2) = uipanel(fig,'Title','Iteraciones', ...
    'Units','normalized','Position',[.31 .03 .68 .89], ...
    'Visible','off');

  % Panel de grafico
  h.paneles(3) = uipanel(fig,'Title','Grafico', ...
    'Units','normalized','Position',[.31 .03 .68 .89], ...
    'Visible','off');

  % BLOQUE 1: DATOS DE ENTRADA
  h.bloqueDatos = uipanel(h.paneles(1), ...
    'Title','Datos de entrada', ...
    'Units','normalized','Position',[.02 .69 .96 .28]);

  h.datos = uicontrol(h.bloqueDatos,'Style','edit', ...
    'Max',20,'Min',0,'Enable','inactive', ...
    'Units','normalized','Position',[.02 .05 .96 .85], ...
    'HorizontalAlignment','left', ...
    'FontSize',11, ...
    'String','Los datos utilizados apareceran aqui.');

  % BLOQUE 2: RESULTADOS NUMERICOS
  h.bloqueResultados = uipanel(h.paneles(1), ...
    'Title','Resultados numericos', ...
    'Units','normalized','Position',[.02 .36 .96 .30]);

  h.resumen = uicontrol(h.bloqueResultados,'Style','edit', ...
    'Max',20,'Min',0,'Enable','inactive', ...
    'Units','normalized','Position',[.02 .05 .96 .85], ...
    'HorizontalAlignment','left', ...
    'FontSize',11, ...
    'String','Los resultados apareceran aqui.');

  % BLOQUE 3: ANALISIS BREVE
  h.bloqueAnalisis = uipanel(h.paneles(1), ...
    'Title','Analisis breve', ...
    'Units','normalized','Position',[.02 .03 .96 .30]);

  h.analisis = uicontrol(h.bloqueAnalisis,'Style','edit', ...
    'Max',20,'Min',0,'Enable','inactive', ...
    'Units','normalized','Position',[.02 .05 .96 .85], ...
    'HorizontalAlignment','left', ...
    'FontSize',11, ...
    'String','Aqui se mostraran la formula y las condiciones principales.');


  % ---------------------------------------------------------
  % TABLA DE ITERACIONES
  % ---------------------------------------------------------
  h.tabla = uitable(h.paneles(2), ...
    'Units','normalized','Position',[.01 .01 .98 .98], ...
    'Data',{},'ColumnName',{},'RowName',{}, ...
    'FontSize',11);


  % ---------------------------------------------------------
  % GRAFICO
  % ---------------------------------------------------------
  h.axes = axes('Parent',h.paneles(3), ...
    'Units','normalized','Position',[.09 .1 .86 .82]);

  % Estado compartido entre las operaciones
  h.metodos = metodos;
  h.ultimo = [];
  h.comparacion = [];
  h.cfgUltima = [];
  h.ultimaOperacion = '';

  guidata(fig,h);
  actualizarCampos();

  % =========================================================
  % FUNCIONES AUXILIARES DE LA INTERFAZ
  % =========================================================

  % Ajustar el ancho de las columnas segun sus encabezados
  function ajustarColumnas(tabla,columnas)

    cantidad = numel(columnas);
    anchos = cell(1,cantidad);

    for k = 1:cantidad
      anchos{k} = max(80,min(160, ...
        7*length(columnas{k}) + 20));
    endfor

    % Dar mas espacio a la tabla de comparacion
    if cantidad == 3 && strcmpi(columnas{1},'Magnitud')
      anchos = {180,260,260};
    endif

    if cantidad > 0
      set(tabla,'ColumnWidth',anchos);
    endif

  endfunction

  % Crear una etiqueta y su campo de entrada
  function [editH,labelH] = campo(parent,etiqueta,y,valor)

    labelH = uicontrol(parent,'Style','text', ...
      'String',etiqueta,'Units','normalized', ...
      'Position',[.04 y .34 .035], ...
      'HorizontalAlignment','left');

    editH = uicontrol(parent,'Style','edit', ...
      'String',valor,'Units','normalized', ...
      'Position',[.38 y .58 .04], ...
      'HorizontalAlignment','left');

  endfunction

  % Mostrar los controles correspondientes a los metodos elegidos
  function actualizarCampos(~,~)

    q = guidata(fig);
    comp = get(q.modo,'Value') == 2;

    set([q.lblM2,q.metodo2,q.det1,q.det2], ...
      'Visible',onoff(comp));

    nombres = {q.metodos{get(q.metodo1,'Value')}};

    if comp
      nombres{2} = q.metodos{get(q.metodo2,'Value')};
      set(q.lblM1,'String','Metodo 1');
    else
      set(q.lblM1,'String','Metodo');
    endif

    usaG = any(strcmp(nombres,'Iteracion')) || any(strcmp(nombres,'Iteracion + Aitken'));

    set([q.exprG,q.lblG,q.x0,q.lblX0], ...
      'Visible',onoff(usaG));

    if usaG
      set(q.lblX0,'String','x0 requerido');
    else
      set(q.lblX0,'String','x0 (no utilizado)');
    endif

  endfunction

  % Cambiar la etiqueta segun el modo de Tanteo
  function actualizarModoTanteo(~,~)

    q = guidata(fig);

    if get(q.modoTanteo,'Value') == 1
      set(q.lblValorTanteo,'String','Incremento (h)');
      set(q.valorTanteo,'String','0.5');
    else
      set(q.lblValorTanteo,'String','Divisiones (n)');
      set(q.valorTanteo,'String','20');
    endif

  endfunction

  % Mostrar el panel seleccionado
  function mostrarPanel(indice)

    q = guidata(fig);
    set(q.paneles,'Visible','off');
    set(q.paneles(indice),'Visible','on');

  endfunction

  % ---------------------------------------------------------
  % LEER Y VALIDAR LOS DATOS
  % ---------------------------------------------------------
  function cfg = leer(proposito)

    if nargin < 1
      proposito = 'calculo';
    endif

    q = guidata(fig);

    [cfg.f,~] = crearFuncion(get(q.exprF,'String'));
    cfg.exprF = get(q.exprF,'String');
    cfg.exprG = get(q.exprG,'String');
    cfg.g = [];

    cfg.xInicial = [];
    cfg.xFinal = [];
    cfg.cantidad = [];

    % Identificar los metodos seleccionados
    nombres = {q.metodos{get(q.metodo1,'Value')}};

    if get(q.modo,'Value') == 2
      nombres{end+1} = q.metodos{get(q.metodo2,'Value')};
    endif

    usaG = any(strcmp(nombres,'Iteracion')) || any(strcmp(nombres,'Iteracion + Aitken'));
    usaIntervalo = any(strcmp(nombres,'Interpolacion Lineal'));

    % Tanteo utiliza su propio intervalo
    if strcmp(proposito,'tanteo')

      cfg.xInicial = numero(q.xInicial,'x inicial');
      cfg.xFinal = numero(q.xFinal,'x final');

      if cfg.xInicial >= cfg.xFinal
        error('Para Tanteo debe cumplirse x inicial < x final.');
      endif

      cfg.valorTanteo = numero(q.valorTanteo,'valor de Tanteo');

      if get(q.modoTanteo,'Value') == 1

        % Modo manual: el valor ingresado representa h
        cfg.modoTanteo = 'manual';

        if cfg.valorTanteo <= 0
          error('El incremento h debe ser positivo.');
        endif

        cfg.h = cfg.valorTanteo;
        cfg.cantidad = [];

      else

        % Modo automatico: el valor ingresado representa n
        cfg.modoTanteo = 'automatico';

        if cfg.valorTanteo < 2 || cfg.valorTanteo ~= fix(cfg.valorTanteo)
          error(['La cantidad de divisiones debe ser un entero mayor o igual que 2.']);
        endif

        cfg.cantidad = cfg.valorTanteo;
        cfg.h = (cfg.xFinal-cfg.xInicial)/cfg.cantidad;

      endif

      return;
    endif

    % Inicializar el intervalo
    cfg.a = [];
    cfg.b = [];

    % Leer el intervalo si el metodo lo necesita
    if usaIntervalo || strcmp(proposito,'grafico')

      cfg.a = numero(q.a,'a');
      cfg.b = numero(q.b,'b');

      if cfg.a >= cfg.b
        error('Debe cumplirse a < b.');
      endif

    endif

    % Inicializar parametros comunes
    cfg.tol = 1;
    cfg.maxIter = 1;
    cfg.x0 = [];

    % Para graficar solo se necesitan la funcion y el rango
    if strcmp(proposito,'grafico')

      if usaG
        [cfg.g,~] = crearFuncion(cfg.exprG);
      endif

      return;
    endif

    % Leer los parametros del calculo numerico
    cfg.tol = numero(q.tol,'tolerancia');
    cfg.maxIter = numero(q.maxIter,'maximo de iteraciones');

    % Leer los datos especificos de Iteracion
    if usaG

      [cfg.g,~] = crearFuncion(cfg.exprG);

      sx = strtrim(get(q.x0,'String'));

      if isempty(sx)
        error('El metodo de Iteracion / Punto Fijo requiere ingresar x0');
      endif

      cfg.x0 = str2double(sx);

      if ~isreal(cfg.x0) || ~isscalar(cfg.x0) || ~isfinite(cfg.x0)
        error('x0 debe ser un numero real, escalar y finito.');
      endif

      validarParametros(cfg.tol,cfg.maxIter,cfg.x0,[cfg.a,cfg.b]);

    else

      validarParametros(cfg.tol,cfg.maxIter,[],[cfg.a,cfg.b]);

    endif

  endfunction

  % Convertir un campo de texto en un numero valido
  function v = numero(control,nombre)

    s = strtrim(get(control,'String'));

    if isempty(s)
      error(['El campo ',nombre,' esta vacio.']);
    endif

    v = str2double(s);

    if ~isreal(v) || ~isscalar(v) || ~isfinite(v)
      error([nombre,' debe ser un numero real y finito.']);
    endif

  endfunction

  % =========================================================
  % CALCULO DE LOS METODOS NUMERICOS
  % =========================================================
  function calcular(~,~)

    try
      q = guidata(fig);
      cfg = leer('calculo');

      n1 = q.metodos{get(q.metodo1,'Value')};

      if get(q.modo,'Value') == 1

        % Ejecutar un solo metodo
        q.ultimo = ejecutarMetodo(n1,cfg);
        q.comparacion = [];
        q.cfgUltima = cfg;
        q.ultimaOperacion = 'calculo';

        guidata(fig,q);
        mostrar(q.ultimo);

        q = guidata(fig);
        set(q.estado,'String','Calculo finalizado.');

      else

        % Ejecutar ambos metodos para compararlos
        n2 = q.metodos{get(q.metodo2,'Value')};

        if strcmp(n1,n2)
          error('Seleccione dos metodos diferentes para compararlos.');
        endif

        q.comparacion = compararMetodos(n1,n2,cfg);
        q.ultimo = [];
        q.cfgUltima = cfg;
        q.ultimaOperacion = 'calculo';

        guidata(fig,q);

        % Mostrar los datos de ambos metodos en dos columnas
        datos1 = q.comparacion.resultado1.datosUtilizados;
        datos2 = q.comparacion.resultado2.datosUtilizados;

        set(q.datos,'FontName','Courier New', ...
          'String',formatearDatosComparacion(datos1,datos2));

        % Mostrar tabla comparativa
        datosTabla = formatearTabla(q.comparacion);

        set(q.tabla,'Data',datosTabla, ...
          'ColumnName',q.comparacion.columnas, ...
          'RowName', 'numbered');

        ajustarColumnas(q.tabla,q.comparacion.columnas);


      % Mostrar resumen de la comparacion
      set(q.resumen,'String',{
        sprintf('Diferencia absoluta entre las raices: %.12g', ...
          q.comparacion.diferenciaRaices)});

        set(q.analisis,'String', ['Seleccione [Ver detalle Metodo 1] o [Ver detalle Metodo 2] para consultar el analisis individual.']);

        set(q.estado,'String','Comparacion finalizada.');

      endif

    catch err
      q = guidata(fig);
      errordlg(err.message,'Error de entrada o calculo');
      set(q.estado,'String',['Error: ',err.message]);
    end_try_catch

  endfunction

  % Mostrar el resultado de un metodo
  function mostrar(r)

    q = guidata(fig);

    % Datos de entrada utilizados
    datos = r.datosUtilizados;
    set(q.datos, 'String', datos);

    % Resultados numericos
    if r.converge
      estado = 'CONVERGIO';
    else
      estado = 'NO CONVERGIO';
    endif

    % Resumen numerico
    lineas = {
      sprintf('Raiz aproximada: %.8g',r.raiz),
      sprintf('Residuo absoluto |f(x)|: %.8g',abs(r.valorFuncion)),
      sprintf('Iteraciones realizadas: %d',r.iteraciones),
      sprintf('Error: %.8g',r.error),
      sprintf('Tiempo de ejecucion: %.6g s',r.tiempo),
      ['Estado: ',estado],
      ['Finalizacion: ',r.mensaje]};

    set(q.resumen,'String',lineas);

    % Tabla de iteraciones
    datosTabla = formatearTabla(r);

    set(q.tabla,'Data',datosTabla, 'ColumnName',r.columnas, 'RowName', 'numbered');

    ajustarColumnas(q.tabla,r.columnas);

    % Analisis del metodo
    set(q.analisis,'String',r.analisis);

    % Mostrar el panel de resultados
    mostrarPanel(1);

  endfunction

  % Formatear los datos de entrada en dos columnas
  function lineas = formatearDatosComparacion(datos1,datos2)

    datos1 = datos1(:);
    datos2 = datos2(:);

    cantidad = max(numel(datos1),numel(datos2));

    % Encabezados
    lineas = {
      sprintf('%-42s | %-42s','METODO 1','METODO 2');
      repmat('-',1,87)
    };

    for k = 1:cantidad

      if k <= numel(datos1)
        texto1 = datos1{k};
      else
        texto1 = '';
      endif

      if k <= numel(datos2)
        texto2 = datos2{k};
      else
        texto2 = '';
      endif

      lineas{end+1} = sprintf('%-42s | %-42s', ...
        texto1,texto2);

    endfor

  endfunction

  % Formatear los numeros de las tablas
  function datos = formatearTabla(r)

    datos = r.tabla;

    % Identificar una tabla de comparacion
    esComparacion = isfield(r,'resultado1') && ...
                    isfield(r,'resultado2');

    % Quitar la fila Finalizacion de la tabla comparativa
    if esComparacion && columns(datos) > 0

      conservar = true(rows(datos),1);

      for i = 1:rows(datos)
        etiqueta = datos{i,1};

        if ischar(etiqueta) && ...
            strcmpi(strtrim(etiqueta),'Finalizacion')
          conservar(i) = false;
        endif
      endfor

      datos = datos(conservar,:);

    endif

    % Convertir valores numericos a texto
    for i = 1:rows(datos)
      for j = 1:columns(datos)

        valor = datos{i,j};

        if isnumeric(valor) && isscalar(valor)

          if isnan(valor)
            datos{i,j} = '—';
          elseif isinf(valor)
            datos{i,j} = '—';
          else
            datos{i,j} = sprintf('%.8g',valor);
          endif

        endif

      endfor
    endfor

  endfunction

  % Mostrar el resultado individual dentro de una comparacion
  function verDetalle(cual)

    q = guidata(fig);

    if isempty(q.comparacion)
      errordlg('Primero ejecute una comparacion.','Sin resultados');
      return;
    endif

    if cual == 1
      r = q.comparacion.resultado1;
    else
      r = q.comparacion.resultado2;
    endif

    q.ultimo = r;
    guidata(fig,q);
    mostrar(r);

  endfunction

  % =========================================================
  % TANTEO
  % =========================================================
  function hacerTanteo(~,~)

    try
      q = guidata(fig);
      cfg = leer('tanteo');

      reloj = tic;

      t = tanteo(cfg.f,cfg.xInicial,cfg.xFinal, cfg.valorTanteo,cfg.modoTanteo);

      tiempo = toc(reloj);

      % Preparar la tabla de evaluaciones
      tablaTanteo = cell(rows(t.tabla),4);

      for k = 1:rows(t.tabla)

        tablaTanteo{k,1} = k;
        tablaTanteo{k,2} = sprintf('%.8g',t.tabla{k,2});
        tablaTanteo{k,3} = sprintf('%.8g',t.tabla{k,3});

        if k < rows(t.tabla) && t.tabla{k,4}

          tablaTanteo{k,4} = sprintf('[%.8g, %.8g]', ...
            t.tabla{k,2},t.tabla{k+1,2});

        else

          tablaTanteo{k,4} = '—';

        endif

      endfor

      q.ultimo = [];
      q.comparacion = [];
      q.cfgUltima = cfg;
      q.ultimaOperacion = 'tanteo';

      guidata(fig,q);

      % Preparar los datos utilizados
      datos = { ['Funcion: ',cfg.exprF], ...
        sprintf('x inicial: %.12g',cfg.xInicial), ...
        sprintf('x final: %.12g',cfg.xFinal), ...
        ['Modo: ',cfg.modoTanteo], ...
        sprintf('Incremento utilizado (h): %.12g',t.incremento)};

      if strcmp(cfg.modoTanteo,'automatico')
        datos{end+1} = sprintf('Divisiones ingresadas (n): %d', ...
          cfg.cantidad);
      endif

      set(q.datos,'String',datos);

      % Mostrar la tabla de Tanteo
      columnasTanteo = {'Iteracion','x evaluado','f(x)', 'Intervalo con cambio de signo'};

      set(q.tabla,'Data',tablaTanteo, 'ColumnName',columnasTanteo, 'RowName', 'numbered');

      ajustarColumnas(q.tabla,columnasTanteo);

      % Listar todos los intervalos detectados
      if isempty(t.intervalos)

        lineasIntervalos = {'No se detectaron intervalos con cambio de signo.'};

      else

        lineasIntervalos = {'Intervalos con cambio de signo:'};

        for k = 1:rows(t.intervalos)
          lineasIntervalos{end+1} = sprintf('[%.8g, %.8g]', t.intervalos(k,1),t.intervalos(k,2));
        endfor

      endif

      resumen = {
        sprintf('Puntos evaluados: %d',t.cantidadPuntos);
        sprintf('Intervalos detectados: %d',rows(t.intervalos));
        sprintf('Tiempo del tanteo: %.8g s',tiempo)
      };

      resumen = [resumen; lineasIntervalos(:)];

      set(q.resumen,'String',resumen);

      set(q.analisis,'String',{ ...
        'Tanteo evalua la funcion en los puntos de una particion.', ...
        ['Un cambio de signo puede indicar una raiz si la funcion es continua en ese intervalo.'], ...
        'Este procedimiento no garantiza detectar todas las raices.'});

      set(q.estado,'String','Tanteo finalizado.');

    catch err
      q = guidata(fig);
      errordlg(err.message,'Error en Tanteo');
      set(q.estado,'String',['Error en Tanteo: ',err.message]);
    end_try_catch

  endfunction

  % =========================================================
  % GRAFICO
  % =========================================================
  function graficar(~,~)

    try
      q = guidata(fig);

      % Reutilizar los datos de la ultima operacion si existen
      if isempty(q.cfgUltima)
        cfg = leer('grafico');
        esTanteo = false;
      else
        cfg = q.cfgUltima;
        esTanteo = strcmp(q.ultimaOperacion,'tanteo');
      endif

      r = q.ultimo;
      r2 = [];

      if esTanteo

        % Tanteo utiliza su propio rango y dibuja la funcion original
        rangoA = cfg.xInicial;
        rangoB = cfg.xFinal;
        n1 = 'Interpolacion Lineal';
        r = [];
        cfg.g = [];
        r2 = [];

      else

        % Definir el rango del grafico
        if isempty(cfg.a) || isempty(cfg.b)

          if isempty(cfg.x0)
            error('Ingrese un intervalo valido para graficar.');
          endif

          % Rango predeterminado alrededor de x0 para Iteracion
          rangoA = cfg.x0 - 5;
          rangoB = cfg.x0 + 5;

        else

          rangoA = cfg.a;
          rangoB = cfg.b;

        endif

        n1 = q.metodos{get(q.metodo1,'Value')};

        if ~isempty(r)
          n1 = r.metodo;
        endif

        if ~isempty(q.comparacion)

          r = q.comparacion.resultado1;
          r2 = q.comparacion.resultado2;

          % Si se comparan metodos de distinta naturaleza,
          % se grafica la funcion original
          pf1 = any(strcmp(r.metodo, { 'Iteracion', 'Iteracion + Aitken'}));
          pf2 = any(strcmp(r2.metodo, { 'Iteracion', 'Iteracion + Aitken'}));

          if pf1 ~= pf2
            n1 = 'Interpolacion Lineal';
          endif

        endif

      endif

      % Generar el grafico
      graficarFuncion(q.axes,n1,cfg.f,cfg.g, ...
        rangoA,rangoB,r,r2);

      mostrarPanel(3);
      set(q.estado,'String','Grafico generado.');

    catch err
      q = guidata(fig);
      errordlg(err.message,'Error al graficar');
      set(q.estado,'String',['Error al graficar: ',err.message]);
    end_try_catch

  endfunction

  % =========================================================
  % LIMPIAR CAMPOS Y RESULTADOS
  % =========================================================
  function limpiar(~,~)

    q = guidata(fig);

    % Vaciar los campos de entrada
    controles = {q.exprF,q.xInicial,q.xFinal,q.valorTanteo, ...
      q.a,q.b,q.exprG,q.x0,q.tol,q.maxIter};

    for k = 1:numel(controles)
      set(controles{k},'String','');
    endfor

    % Vaciar resultados, tabla y grafico
    set(q.tabla,'Data',{},'ColumnName',{},'RowName',{});

    set(q.resumen,'String', ...
      'Ingrese los datos y ejecute una operacion.');

    set(q.datos,'String','Sin ejecucion registrada.');

    set(q.analisis,'String', ...
      'Ejecute un metodo para consultar su analisis.');

    cla(q.axes);

    q.ultimo = [];
    q.comparacion = [];
    q.cfgUltima = [];
    q.ultimaOperacion = '';

    guidata(fig,q);

    set(q.estado,'String','Campos y resultados limpiados.');

  endfunction

  % Convertir verdadero/falso en visible/no visible
  function s = onoff(v)

    if v
      s = 'on';
    else
      s = 'off';
    endif

  endfunction

endfunction
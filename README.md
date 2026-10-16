# Primer Trabajo de Evaluación - Laboratorio
## Métodos Computacionales — 2026

### Descripción

El presente trabajo tiene como objetivo implementar y analizar los métodos numéricos de **Interpolación Lineal (Regula Falsi)** e **Iteración de Punto Fijo**, estudiando sus fundamentos matemáticos, algoritmos y condiciones de convergencia.

Para ello, se desarrolló una aplicación en **GNU Octave** que permite ingresar funciones y parámetros, ejecutar los métodos de manera individual y comparar sus resultados. También incorpora una etapa de tanteo para explorar el comportamiento de la función y seleccionar intervalos iniciales, junto con herramientas gráficas para visualizar las aproximaciones obtenidas.

Finalmente, los métodos se aplican a un problema determinado y se analizan los resultados considerando la aproximación de la raíz, el error, la cantidad de iteraciones, la convergencia y el tiempo de ejecución, identificando las ventajas y limitaciones de cada procedimiento.

### Estructura del proyecto

El proyecto se organiza en las siguientes carpetas y archivos:

| Archivo / Carpeta | Descripción |
|---|---|
| `main.m` | Punto de entrada de la aplicación. Configura las rutas necesarias e inicia la interfaz gráfica. |
| `interfaz/` | Contiene los archivos de la interfaz gráfica, recibe los datos ingresados por el usuario y coordina las operaciones. |
| `metodos/` | Contiene los algoritmos de los métodos numéricos implementados. |
| `funciones/` | Incluye funciones auxiliares para trabajar con las expresiones matemáticas ingresadas. |
| `resultados/` | Define la estructura inicial utilizada para almacenar los resultados de los métodos. |
| `graficos/` | Contiene las funciones para representar gráficamente la función y visualizar los resultados obtenidos. |
| `utilidades/` | Incluye funciones auxiliares para coordinar y validar las operaciones del programa. |

### Requisitos

- Tener instalado [GNU Octave](https://octave.org/).
- Descargar o clonar este repositorio en el equipo.

### Cómo ejecutar la aplicación

1. Descargar o clonar el repositorio.
2. Abrir GNU Octave.
3. Establecer como directorio de trabajo la carpeta raíz del proyecto, donde se encuentra el archivo `main.m`.
4. Ejecutar el archivo `main.m` desde la consola de Octave:

   ```octave
   main
   ```

5. Una vez iniciada la aplicación, se abrirá la interfaz gráfica con una función y sus parámetros cargados por defecto.
6. Revisar o modificar los valores de entrada según el problema que se desea resolver.

### Integrantes

- Barbero Asselborn, Valentina Nerea
- Rodriguez, Priscila Oriana 

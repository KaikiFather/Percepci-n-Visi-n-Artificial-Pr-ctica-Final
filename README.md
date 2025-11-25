# PRÁCTICA FINAL – PERCEPCIÓN Y VISIÓN ARTIFICIAL
## Sistema para resolver Cross Math Grid en MATLAB

---

## 1. Descripción del proyecto

Este proyecto corresponde a la práctica final de la asignatura de Percepción y consiste en desarrollar un sistema capaz de reconocer, interpretar y validar rompecabezas tipo **Cross Math Grid** mediante técnicas de visión artificial. El sistema debe capturar la cuadrícula desde una cámara, identificar números, operadores, signos de igualdad y casillas especiales, y permitir que el usuario introduzca valores faltantes mediante voz o tarjetas impresas. Finalmente, el sistema debe comprobar si las operaciones horizontales y verticales del tablero son correctas.

El proyecto incluye todos los componentes necesarios: detección de la cuadrícula, segmentación, reconocimiento de símbolos, interacción con el usuario, lógica del juego, comprobación de resultados, interfaz gráfica, documentación y material de entrega.

---

## 2. Requerimientos oficiales

Los requisitos establecidos para la práctica son los siguientes:

**Captura de cuadrícula:**  
- La partida inicia mostrando una cuadrícula a la cámara.  
- El sistema debe detectar automáticamente el tamaño, las celdas y los símbolos presentes.

**Resolución interactiva:**  
- El usuario puede introducir valores mediante voz o tarjetas impresas.  
- El sistema debe validar cada movimiento y evitar incoherencias aritméticas o entradas inválidas.

**Reconocimiento de estructura:**  
- Debe aceptar cuadrículas de diferentes tamaños (entre 5×5 y 12×12).  
- El tamaño debe detectarse automáticamente sin intervención del usuario.

**Comprobación de solución:**  
- Se deben evaluar todas las operaciones horizontales y verticales.  
- El sistema debe señalar los errores visualmente.

**Material obligatorio de entrega:**  
- Memoria técnica.  
- Código completo en MATLAB.  
- Plantillas de tarjetas impresas.  
- Vídeo demostrativo.  
- Presentación final.

---

## 3. Estructura del repositorio

```text
Proyecto-CrossMath/
│
├── README.md                          # Documento principal del proyecto
├── LICENCIA                           # Licencia del repositorio
├── ejecutar.m                         # Archivo de inicio para ejecutar el sistema
│
├── configuracion/                     # Archivos de configuración
│   ├── ajustes_ejemplo.yaml           # Configuración de ejemplo
│   ├── parametros_camara.json         # Parámetros de cámara
│   └── parametros_ocr.json            # Parámetros del reconocimiento de símbolos
│
├── codigo/                            # Código fuente organizado por módulos
│   │
│   ├── captura/                       # Captura y preprocesamiento de la imagen
│   │   ├── capturarCuadricula.m
│   │   ├── preprocesarImagen.m
│   │   └── detectarCuadricula.m
│   │
│   ├── segmentacion/                  # Segmentación del tablero
│   │   ├── segmentarCeldas.m
│   │   └── detectarBordesCeldas.m
│   │
│   ├── reconocimiento/                # Reconocimiento de números y símbolos
│   │   ├── reconocerCelda.m
│   │   ├── clasificarNumero.m
│   │   ├── clasificarOperador.m
│   │   └── plantillas/
│   │       ├── digitos/
│   │       └── operadores/
│   │
│   ├── interaccion/                   # Entrada mediante voz o tarjetas
│   │   ├── entradaVoz.m
│   │   ├── entradaTarjetas.m
│   │   └── plantillas_tarjetas/
│   │
│   ├── logica/                        # Lógica del juego y validación
│   │   ├── validarMovimiento.m
│   │   ├── evaluarFila.m
│   │   ├── evaluarColumna.m
│   │   └── comprobarSolucion.m
│   │
│   └── interfaz/                      # Interfaz gráfica del sistema
│       ├── interfazPrincipal.m
│       └── dibujarTablero.m
│
├── datos/                             # Imágenes para pruebas
│   ├── originales/
│   └── procesados/
│
├── documentos/                        # Documentación del proyecto
│   ├── Memoria.pdf
│   ├── Presentacion.pdf
│   ├── Enunciado.pdf
│   └── tarjetas/
│
├── ejemplos/                          # Ejemplos de cuadrículas reales
│   ├── ejemplo_5x5.jpg
│   ├── ejemplo_7x7.jpg
│   └── ejemplo_12x12.jpg
│
└── video/
    └── demostracion.mp4               # Vídeo de demostración

---

## 4. Planificación resumida

**Semana 1:** Captura de imagen, preprocesamiento y detección de cuadrícula.  
**Semana 2:** Segmentación de celdas y reconocimiento de símbolos.  
**Semana 3:** Implementación de la lógica del juego y validación de operaciones.  
**Semana 4:** Integración de la entrada por voz y tarjetas impresa.  
**Semana 5:** Implementación de la interfaz gráfica y flujo completo.  
**Semana 6:** Elaboración de la memoria, grabación del video y preparación de la presentación.

---

## 5. Explicación de carpetas y archivos

**configuracion/**  
Contiene parámetros de cámara, ajustes de OCR y configuraciones generales del sistema.

**codigo/**  
Incluye todo el código MATLAB del proyecto organizado en módulos: captura, segmentación, reconocimiento, interacción, lógica e interfaz gráfica.

**datos/**  
Conjunto de imágenes para pruebas y validaciones internas.

**documentos/**  
Todo el material obligatorio de entrega: memoria, presentación, enunciado y plantillas de tarjetas.

**ejemplos/**  
Cuadrículas de ejemplo usadas para validar el sistema.

**video/**  
Video demostrativo del funcionamiento completo.


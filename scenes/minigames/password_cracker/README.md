# Password Cracker - Minijuego de Ciberseguridad (Versión Mejorada)

## Descripción
Password Cracker es un minijuego educativo avanzado de ciberseguridad donde el jugador debe descifrar contraseñas de diferentes niveles de dificultad utilizando pistas, análisis de similitud y estrategia. El juego enseña conceptos de seguridad de contraseñas de manera interactiva y progresiva.

## 🎮 Características del Juego

### Sistema de Niveles (NUEVO ⭐)
El juego ahora incluye **3 niveles** progresivos con diferentes contraseñas:

1. **Nivel 1 - Fácil**: `SecurePass123`
   - Contraseña básica con mayúsculas, minúsculas y números
   - Ideal para aprender las mecánicas

2. **Nivel 2 - Media**: `Cyb3r$ecurity`
   - Incluye sustitución de caracteres (leetspeak)
   - Símbolos especiales
   - Mayor complejidad

3. **Nivel 3 - Difícil**: `H@ck3rM1nd!2024`
   - Múltiples sustituciones de caracteres
   - Varios símbolos especiales
   - Longitud extendida

### Sistema de Análisis de Similitud (NUEVO 🔍)
- **2 análisis disponibles** por nivel
- Muestra el **porcentaje de similitud** entre el intento y la contraseña correcta
- **Barra de progreso visual** con código de colores:
  - 🟢 Verde (75%+): Muy cerca
  - 🟡 Amarillo (50-74%): Estás avanzando
  - 🟠 Naranja (25-49%): Aún lejos
  - 🔴 Rojo (0-24%): Intenta de nuevo
- **Bonus de puntos** (+10) si la similitud es > 50%

### Sistema de Puntuación (NUEVO ⭐)
Puntos calculados basándose en:
- **Base**: 500 puntos por nivel completado
- **Bonus de vidas**: +50 puntos por cada vida restante
- **Bonus de tiempo**: +2 puntos por segundo ahorrado (hasta 5 min)
- **Bonus de pistas**: +30 puntos por cada pista no usada
- **Penalización**: -25 puntos por cada pista revelada

### Sistema de Tiempo (NUEVO ⏱️)
- Cronómetro activo durante toda la partida
- Formato: MM:SS
- Influye en la puntuación final
- Estadística mostrada al completar todos los niveles

### Mecánicas Principales
- **Sistema de Vidas**: 6 vidas por nivel (antes eran intentos)
- **Sistema de Pistas**: 5 pistas únicas por nivel
- **Contraseña Oculta**: Input con asteriscos para simular campos reales
- **Progresión Automática**: Avanza al siguiente nivel tras completar uno

### Efectos Visuales Mejorados
- **Animación de sacudida**: Cuando la contraseña es incorrecta
- **Animación de éxito**: Escala el texto al acertar
- **Revelación de pistas**: Fade-in suave al revelar cada pista
- **Animación de victoria**: Parpadeo dorado al completar todos los niveles
- **Efecto de game over**: Tinte rojo en la pantalla
- **Animación de progreso**: Bounce al actualizar la barra de similitud

### Estados del Juego
- **Jugando**: Estado activo con vidas disponibles
- **Victoria de Nivel**: Contraseña correcta, avanza al siguiente nivel
- **Victoria Total**: Todos los niveles completados
- **Game Over**: Sin vidas restantes
- **Reinicio**: Botón para volver a empezar desde el nivel 1

### Interfaz de Usuario (UI)
**Barra Superior:**
- 🎯 Indicador de nivel y dificultad
- ⭐ Contador de puntos
- ⏱️ Cronómetro

**Área Central:**
- 💡 Pistas bloqueadas/reveladas
- 🔍 Sistema de análisis con barra de progreso
- 🔐 Campo de entrada de contraseña
- 🔓 Botones de acción (Analizar, Enviar)

**Barra Inferior:**
- ❤️ Indicador de vidas con código de colores
- 💡 Botón de pistas
- 🔄 Botón de reinicio (solo visible al terminar)

## 🎓 Conceptos de Ciberseguridad Enseñados

### Nivel Básico
1. **Complejidad de contraseñas**: Combinación de mayúsculas, minúsculas y números
2. **Longitud mínima**: Importancia de contraseñas de al menos 10-12 caracteres

### Nivel Intermedio
3. **Sustitución de caracteres**: Uso de leetspeak (3 por e, $ por s)
4. **Símbolos especiales**: Importancia de caracteres especiales

### Nivel Avanzado
5. **Contraseñas robustas**: Múltiples capas de complejidad
6. **Impredecibilidad**: Evitar patrones reconocibles
7. **Actualización regular**: Incluir fechas/años dificulta ataques de diccionario

### Mecánicas Educativas
8. **Análisis de patrones**: El sistema de similitud enseña cómo funcionan los ataques de fuerza bruta
9. **Gestión de recursos**: Uso estratégico de pistas y análisis
10. **Presión temporal**: Tomar decisiones bajo tiempo limitado

## 📁 Archivos del Proyecto

### Scripts
- `password_cracker.gd` - Lógica principal mejorada con sistema de niveles, puntuación y análisis

### Escenas
- `PasswordCracker.tscn` - Escena principal con UI completa

### Recursos
- `PasswordCracker.tres` - Tema visual cyberpunk/hacker
- `../../../resources/apps/PasswordCrackerApp.tres` - Configuración de la aplicación

### Iconos
- `../../../assets/textures/password-lock-icon.svg` - Icono de candado personalizado

## 🎯 Cómo Jugar

1. **Inicio**: El juego comienza en el Nivel 1 (Fácil)
2. **Estrategia**: Decide cuándo usar tus recursos (pistas y análisis)
3. **Analizar**: Usa el botón 🔍 Analizar para ver qué tan cerca estás
4. **Pistas**: Usa el botón 💡 Pista si necesitas ayuda (cuesta puntos)
5. **Intentar**: Escribe tu intento y presiona 🔓 ENVIAR
6. **Progresar**: Completa los 3 niveles para ganar
7. **Reiniciar**: Presiona 🔄 Reiniciar para volver a intentarlo

## 📊 Sistema de Puntuación Óptimo

Para obtener la **máxima puntuación**, intenta:
- ✅ Completar cada nivel rápidamente (< 2 minutos)
- ✅ No usar pistas (bonus completo)
- ✅ Usar análisis estratégicamente
- ✅ Mantener todas las vidas posibles
- 🏆 **Puntuación perfecta por nivel**: ~1,000+ puntos
- 🏆 **Puntuación perfecta total**: 3,000+ puntos

## 🆕 Mejoras Implementadas

### Versión 2.0 - Mejoras Mayores
1. ✨ Sistema de 3 niveles progresivos
2. ✨ Sistema de puntuación complejo
3. ✨ Análisis de similitud de contraseñas
4. ✨ Cronómetro y estadísticas de tiempo
5. ✨ Botón de reinicio
6. ✨ Victoria total con pantalla de estadísticas
7. ✨ Barra de progreso visual
8. ✨ Mejores animaciones y efectos
9. ✨ UI rediseñada y más informativa
10. ✨ Penalización por pistas en puntos, no en vidas

## 🔮 Posibles Extensiones Futuras
- Modo infinito con contraseñas generadas aleatoriamente
- Tabla de clasificación (leaderboard)
- Diferentes tipos de ataques (diccionario, rainbow tables)
- Sistema de logros y trofeos
- Modo multijugador competitivo
- Generador de contraseñas seguras
- Tutorial interactivo detallado
- Más niveles con contraseñas más complejas
- Sistema de "hackeo ético" con escenarios reales
- Integración con el sistema de progreso del juego principal

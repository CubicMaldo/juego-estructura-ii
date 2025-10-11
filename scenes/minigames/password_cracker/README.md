# Password Cracker - Minijuego de Ciberseguridad

## Descripción
Password Cracker es un minijuego educativo de ciberseguridad donde el jugador debe descifrar una contraseña utilizando pistas limitadas. El juego enseña conceptos básicos de seguridad de contraseñas de manera interactiva.

## Características del Juego

### Mecánicas Principales
- **Sistema de Intentos**: El jugador tiene 5 intentos para adivinar la contraseña
- **Sistema de Pistas**: 5 pistas disponibles que se revelan progresivamente
- **Penalización**: Cada pista usada cuesta 1 intento
- **Contraseña Oculta**: El input muestra asteriscos para simular un campo de contraseña real

### Contraseña Correcta
`SecurePass123`

### Pistas Disponibles
1. "Empieza con 'S' mayúscula"
2. "Contiene la palabra 'Pass'"
3. "Termina con números del 1 al 3"
4. "Tiene 13 caracteres en total"
5. "Incluye la palabra 'Secure'"

### Efectos Visuales
- **Animación de sacudida**: Cuando la contraseña es incorrecta
- **Animación de éxito**: Escala el texto cuando se acierta
- **Revelación de pistas**: Fade-in suave al revelar cada pista
- **Código de colores**: 
  - Verde: Éxito
  - Rojo: Error o game over
  - Amarillo: Advertencias
  - Azul cian: Pistas reveladas

### Estados del Juego
- **Jugando**: Estado inicial con intentos disponibles
- **Victoria**: Contraseña correcta adivinada
- **Game Over**: Sin intentos restantes

## Conceptos de Ciberseguridad Enseñados
1. **Complejidad de contraseñas**: Uso de mayúsculas, minúsculas y números
2. **Longitud de contraseñas**: Importancia de contraseñas largas
3. **Patrones reconocibles**: Palabras comunes en contraseñas
4. **Ingeniería social**: Cómo las pistas simulan información que un atacante podría obtener

## Archivos Creados

### Scripts
- `scenes/minigames/password_cracker/password_cracker.gd` - Lógica principal del juego

### Escenas
- `scenes/minigames/password_cracker/PasswordCracker.tscn` - Escena principal del minijuego

### Recursos
- `scenes/minigames/password_cracker/PasswordCracker.tres` - Tema visual del juego
- `resources/apps/PasswordCrackerApp.tres` - Configuración de la aplicación para el escritorio

### Iconos
- `assets/textures/password-lock-icon.svg` - Icono del candado para el escritorio

## Integración con el Sistema

El minijuego está completamente integrado en el sistema de escritorio:
1. Aparece como un tercer icono en el escritorio (`App3`)
2. Se puede abrir haciendo doble clic en el icono "Password Cracker"
3. Se ejecuta en un panel de aplicación independiente
4. Utiliza el mismo sistema de paneles que las otras aplicaciones

## Posibles Extensiones Futuras
- Múltiples niveles de dificultad
- Diferentes tipos de contraseñas (hashes, pins, etc.)
- Sistema de puntuación basado en intentos restantes
- Estadísticas de tiempo
- Más variantes de contraseñas aleatorias
- Tutorial interactivo sobre buenas prácticas de contraseñas

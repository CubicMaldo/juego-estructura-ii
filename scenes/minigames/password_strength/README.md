# 🔐 Password Strength Trainer - Entrenador de Contraseñas Seguras

## 📋 Descripción General

El **Password Strength Trainer** es un minijuego educativo interactivo diseñado para enseñar a los usuarios cómo crear contraseñas ultra seguras mediante análisis en tiempo real y retroalimentación instructiva. A diferencia de otros minijuegos, este no evalúa conocimientos previos, sino que entrena activamente al jugador con desafíos progresivos.

## 🎯 Objetivos Educativos

### Conceptos Clave Enseñados:
1. **Longitud de Contraseña**: Por qué importa y cuántos caracteres son suficientes
2. **Complejidad de Caracteres**: Uso de mayúsculas, minúsculas, números y símbolos
3. **Patrones a Evitar**: Palabras comunes, secuencias repetitivas, patrones de teclado
4. **Diversidad de Tipos**: Mezclar diferentes categorías de caracteres
5. **Entropía**: Concepto de aleatoriedad y predictibilidad

## 🎮 Mecánica del Juego

### Sistema de Niveles Progresivos

El juego consta de **5 niveles** con dificultad incremental:

| Nivel | Desafío | Puntuación Mínima |
|-------|---------|-------------------|
| 1 | Crea contraseña de 8+ caracteres | 30 puntos |
| 2 | Incluye mayúsculas y minúsculas (10+ caracteres) | 50 puntos |
| 3 | Añade números (12+ caracteres) | 70 puntos |
| 4 | Incluye símbolos especiales | 85 puntos |
| 5 | Crea contraseña EXCELENTE (15+ caracteres) | 100 puntos |

### Sistema de Puntuación

La contraseña se evalúa en tiempo real con un sistema de 100 puntos:

#### Criterios Positivos:
- **Longitud**: 2 puntos por carácter (máximo 40 puntos)
- **Mayúsculas**: +10 puntos si contiene A-Z
- **Minúsculas**: +10 puntos si contiene a-z
- **Números**: +10 puntos si contiene 0-9
- **Símbolos**: +15 puntos si contiene caracteres especiales (!@#$%^&*())
- **Bonus de Diversidad**: +3 puntos por cada tipo de carácter usado (máximo +15)

#### Penalizaciones:
- **Palabra Común**: -30 puntos (password, 123456, qwerty, etc.)
- **Secuencia Repetitiva**: -15 puntos (aaa, 111, etc.)
- **Patrón de Teclado**: -20 puntos (qwerty, asdfgh, 123456)

### Categorías de Fortaleza

| Puntos | Categoría | Emoji | Color |
|--------|-----------|-------|-------|
| 0-29 | MUY DÉBIL | 😱 | Rojo |
| 30-49 | DÉBIL | 😟 | Naranja |
| 50-69 | REGULAR | 😐 | Amarillo |
| 70-84 | BUENA | 😊 | Verde Lima |
| 85-99 | FUERTE | 💪 | Verde |
| 100 | EXCELENTE | 🔥 | Dorado |

## 💡 Consejos de Seguridad Mostrados

El juego muestra 10 consejos clave durante toda la sesión:

1. 💡 Usa al menos 12 caracteres (idealmente 15+)
2. 🔤 Mezcla mayúsculas y minúsculas
3. 🔢 Incluye números en posiciones aleatorias
4. 🔣 Añade símbolos especiales (!@#$%^&*)
5. 🚫 Evita palabras del diccionario
6. 🔄 No reutilices contraseñas
7. 📝 Usa frases memorables: 'M3Gu$t@L33r!'
8. 🎲 Considera un gestor de contraseñas
9. ❌ Nunca uses: 123456, password, qwerty
10. 🔐 Activa autenticación de dos factores

## 📊 Análisis en Tiempo Real

### Feedback Inmediato

Mientras el usuario escribe, el sistema proporciona:

✅ **Criterios Cumplidos**:
- "✅ Buena longitud (14 caracteres)"
- "✅ Incluye mayúsculas"
- "✅ Incluye símbolos especiales"

❌ **Criterios Faltantes**:
- "❌ Muy corta - usa al menos 12 caracteres"
- "❌ Falta incluir números (0-9)"
- "❌ Falta incluir símbolos (!@#$%)"

⚠️ **Advertencias de Seguridad**:
- "⚠️ Contiene palabra común - evítalas"
- "⚠️ Tiene caracteres repetidos consecutivos"
- "⚠️ Contiene patrón de teclado predecible"

### Barra de Fortaleza Visual

Una barra de progreso dinámica muestra visualmente la fortaleza de 0 a 100, cambiando de color según la puntuación.

## 🛠️ Funcionalidades Técnicas

### Detección de Patrones Débiles

#### Palabras Comunes (16 detectadas):
```
password, contraseña, 123456, qwerty, admin, usuario,
letmein, welcome, monkey, dragon, master, abc123,
iloveyou, password1, 123123, 12345678
```

#### Secuencias Repetitivas:
- Detecta 3+ caracteres consecutivos iguales
- Ejemplos: "aaa", "111", "zzz"

#### Patrones de Teclado:
```
qwerty, asdfgh, zxcvbn, 123456, abcdef
```

### Generador de Contraseñas

El botón "🎲 Generar Ejemplo" crea automáticamente una contraseña segura de 16 caracteres:
- Garantiza al menos 1 mayúscula
- Garantiza al menos 1 minúscula
- Garantiza al menos 1 número
- Garantiza al menos 1 símbolo
- Mezcla aleatoria de todos los tipos

## 🎓 Análisis Detallado Post-Nivel

Al completar cada nivel, el jugador recibe:

### Análisis de Seguridad:
```
• Longitud: 15 caracteres ⭐ EXCELENTE
• Mayúsculas: ✅ Sí
• Minúsculas: ✅ Sí
• Números: ✅ Sí
• Símbolos: ✅ Sí
• Sin palabras comunes ✅
• Sin repeticiones ✅
• Sin patrones predecibles ✅
```

### Sugerencias de Mejora (si no alcanza el mínimo):
```
💡 Sugerencias:
• Añade más caracteres (mín. 12)
• Incluye letras MAYÚSCULAS
• Añade números (0-9)
• Incluye símbolos (!@#$%)
```

## 📈 Sistema de Recompensas

### Puntos por Nivel:
- Puntos base = puntuación de la contraseña (0-100)
- Bonus por nivel = nivel × 10
- **Total por nivel** = puntuación + (nivel × 10)

### Ejemplo:
- Nivel 3 con puntuación 85:
  - Puntos base: 85
  - Bonus: 3 × 10 = 30
  - **Total: 115 puntos**

### Puntuación Final:
Al completar los 5 niveles, el jugador puede obtener entre 500-1000+ puntos totales.

## 🏆 Victoria y Conclusión

Al completar el nivel 5, el jugador recibe:

```
🏆 ¡ENTRENAMIENTO COMPLETADO! 🏆

Has dominado el arte de las contraseñas seguras

📊 Estadísticas finales:
• Desafíos completados: 5/5
• Puntos totales: [puntuación acumulada]

🎓 Lecciones aprendidas:
✅ Longitud mínima 12+ caracteres
✅ Mezclar tipos de caracteres
✅ Evitar palabras comunes
✅ No usar patrones predecibles
✅ Usar gestor de contraseñas

¡Ahora puedes crear contraseñas ultra seguras! 🔐
```

Tras 5 segundos, se reporta el resultado al sistema global y regresa al Desktop.

## 💻 Implementación Técnica

### Archivos del Sistema:

```
assets/scripts/minigames/password_strength/
├── PasswordStrengthTip.gd          # Recurso de consejos
└── PasswordStrengthTip.gd.uid

scenes/minigames/password_strength/
├── password_strength_trainer.gd     # Lógica principal (480 líneas)
├── password_strength_trainer.gd.uid
└── PasswordStrengthTrainer.tscn     # Interfaz visual

resources/apps/
└── PasswordStrengthTrainerApp.tres  # Recurso de aplicación
```

### Estructura de la Interfaz:

```
Control (Root)
└── Panel
    └── VBoxContainer
        ├── Title (Label)
        ├── TopBar (HBoxContainer)
        │   ├── ScoreLabel
        │   └── NivelLabel
        ├── ChallengeContainer
        │   └── ChallengeLabel
        ├── InputContainer (HBoxContainer)
        │   ├── InputLabel
        │   └── PasswordInput (LineEdit)
        ├── StrengthContainer
        │   ├── StrengthLabel
        │   └── StrengthBar (ProgressBar)
        ├── FeedbackContainer
        │   └── FeedbackScroll → FeedbackList
        ├── TipsContainer
        │   └── TipsScroll → TipsList
        ├── ResultadoContainer
        │   └── ResultadoLabel
        └── ButtonContainer (HBoxContainer)
            ├── BtnGenerate
            ├── BtnCheck
            └── BtnSiguiente
```

### Funciones Clave:

| Función | Propósito |
|---------|-----------|
| `calcular_puntuacion()` | Evalúa contraseña y retorna score 0-100 |
| `actualizar_analisis()` | Actualiza UI en tiempo real |
| `mostrar_feedback()` | Genera lista de criterios cumplidos/faltantes |
| `obtener_analisis_detallado()` | Análisis completo post-verificación |
| `obtener_sugerencias()` | Genera consejos personalizados |
| `_on_generate_pressed()` | Genera contraseña segura de ejemplo |
| `tiene_mayusculas()` | Detecta A-Z |
| `tiene_minusculas()` | Detecta a-z |
| `tiene_numeros()` | Detecta 0-9 |
| `tiene_simbolos()` | Detecta !@#$%^&*() |
| `contiene_palabra_comun()` | Verifica contra lista de 16 palabras |
| `tiene_secuencia_repetitiva()` | Detecta AAA, 111, etc. |
| `tiene_patron_teclado()` | Detecta qwerty, asdfgh, etc. |

## 🎨 Características UX

### Retroalimentación Visual:
- **Barra de progreso dinámica**: Muestra fortaleza de 0-100%
- **Colores según fortaleza**: Rojo → Naranja → Amarillo → Verde → Dorado
- **Emojis expresivos**: 😱 😟 😐 😊 💪 🔥
- **Scroll de feedback**: Lista detallada de criterios

### Interactividad:
- **Análisis en tiempo real**: Cada tecla actualiza el feedback
- **Botón generador**: Crea ejemplos de contraseñas seguras
- **Consejos permanentes**: Visibles durante todo el juego
- **Resultados detallados**: Análisis completo tras cada nivel

## 🎯 Aplicación en el Juego

### Configuración en TreeApp:
- **ID**: `password_strength_trainer`
- **Nombre**: "Entrenador de Contraseñas"
- **Icono**: 🔐
- **Categoría**: `ciberseguridad`
- **Tipo**: Aplicación de Pista (`is_desafio = false`)
- **Puntos Iniciales**: 150
- **Penalización por Pista**: 50
- **Tiempo Límite**: 900 segundos (15 minutos)

### Integración:
- Añadido a `TreeAppsDatabase.tres` en el array `pista_apps`
- Icono (App5) añadido al Desktop
- Ruta de escena: `res://scenes/minigames/password_strength/PasswordStrengthTrainer.tscn`

## 📝 Lecciones de Seguridad Real

Este minijuego enseña conceptos aplicables en la vida real:

### 1. **Longitud > Complejidad**
Investigaciones modernas muestran que una contraseña de 15 caracteres simples es más segura que una de 8 caracteres complejos.

### 2. **Frases Memorables**
Técnicas como "M3Gu$t@L33r!" (Me Gusta Leer) son memorables y seguras.

### 3. **Gestores de Contraseñas**
El juego recomienda usar gestores para crear y almacenar contraseñas ultra complejas.

### 4. **Autenticación Multifactor**
Aunque la contraseña sea fuerte, 2FA añade una capa crucial de seguridad.

### 5. **No Reutilización**
Una contraseña única por servicio evita compromisos en cascada.

## 🔧 Posibles Extensiones Futuras

1. **Modo Experto**: Desafío de crear contraseñas de 20+ caracteres
2. **Simulador de Ataques**: Mostrar cuánto tardaría un atacante en romper cada contraseña
3. **Historial de Contraseñas**: Guardar las mejores contraseñas creadas
4. **Competencia de Tiempo**: Crear contraseñas seguras contra reloj
5. **Análisis de Entropía**: Mostrar bits de entropía de cada contraseña
6. **Integración con Haveibeenpwned**: Verificar si la contraseña ha sido filtrada
7. **Modo Multijugador**: Competir por crear la contraseña más segura

## 📚 Referencias de Seguridad

- NIST Special Publication 800-63B (Digital Identity Guidelines)
- OWASP Authentication Cheat Sheet
- Carnegie Mellon University: "The Security of Modern Password Expiration"
- Microsoft Identity Best Practices

---

## 🎮 ¿Cómo Jugar?

1. **Inicia el minijuego** desde el escritorio (icono 🔐)
2. **Lee el desafío** del nivel actual
3. **Escribe una contraseña** en el campo de texto
4. **Observa el análisis** en tiempo real
5. **Usa el generador** si necesitas inspiración
6. **Verifica tu contraseña** cuando creas que cumple el desafío
7. **Lee el análisis detallado** y aprende de los resultados
8. **Avanza al siguiente nivel** hasta completar los 5 desafíos
9. **¡Domina el arte de las contraseñas seguras!** 🔐✨

---

**Desarrollado para el proyecto educativo de Estructuras de Datos II**  
*Enseñando ciberseguridad de forma interactiva y práctica*

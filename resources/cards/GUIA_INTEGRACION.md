# Guía de Integración: Sistema de Phishing Cards

## 📋 Resumen del Sistema

Has expandido tu sistema de cartas para incluir un juego de detección de phishing donde:
- Cada carta muestra un email
- El jugador decide si es phishing o legítimo
- Se acumulan puntos por respuestas correctas
- Se muestra feedback educativo

## 🗂️ Estructura de Archivos Creados

```
resources/cards/
├── PhishingCard.gd          # Resource: datos de una carta
├── CardDatabase.gd          # Resource: colección de cartas
└── README_CREAR_CARTAS.md   # Guía para crear cartas

assets/scripts/cards_stack/
├── Card.gd                  # Expandido con setup_from_data()
├── CardStack.gd             # Expandido con lógica del juego
└── PhishingGameUI.gd        # Nuevo: Controlador de UI
```

## 🎮 Cómo Usar

### 1. Crear Base de Datos de Cartas

**En el Editor de Godot:**
1. Click derecho en FileSystem → **New Resource**
2. Buscar **"PhishingCard"**
3. Llenar los datos del email
4. Guardar como `carta_001.tres`
5. Repetir para crear más cartas

**Crear CardDatabase:**
1. New Resource → **CardDatabase**
2. Arrastrar las PhishingCards al array "cards"
3. Guardar como `PhishingDatabase.tres`

### 2. Configurar CardStack

En el Inspector del nodo CardStack:
```
Card Database: [arrastra PhishingDatabase.tres]
Cards Per Game: 10
Use Balanced Cards: ✓ (para 50% phishing / 50% legítimos)
```

### 3. Actualizar Escena de Carta

Tu escena `Card.tscn` necesita estos nodos con unique names (%):
```
Card (Button)
├── %Title (Label)
├── %Sender (Label)
├── %Subject (Label)
├── %Body (RichTextLabel o Label)
└── %AttachmentIcon (TextureRect - opcional)
```

### 4. Agregar UI de Juego

Crear una escena con:
```gdscript
# Estructura sugerida:
PhishingGame (Control)
├── CardStack (tu nodo existente)
├── UI (Control) - script: PhishingGameUI.gd
│   ├── ScoreLabel (Label)
│   ├── CorrectLabel (Label)
│   ├── IncorrectLabel (Label)
│   ├── PhishingButton (Button)
│   ├── LegitimateButton (Button)
│   └── FeedbackPanel (Panel)
│       ├── FeedbackLabel (Label)
│       └── ExplanationLabel (Label)
```

**Conectar señales:**
- PhishingButton.pressed → PhishingGameUI._on_phishing_button_pressed()
- LegitimateButton.pressed → PhishingGameUI._on_legitimate_button_pressed()

## 🎯 Flujo del Juego

1. **CardStack** carga cartas de la base de datos al iniciar
2. Cada **Card** recibe un `PhishingCard` con `setup_from_data()`
3. Jugador ve el email en la carta superior
4. Jugador presiona botón "Phishing" o "Legítimo"
5. **CardStack** evalúa la respuesta con `check_answer()`
6. Se actualiza el score y se emite señal `card_answered`
7. **PhishingGameUI** muestra feedback y explicación
8. La carta se destruye con efecto dissolve
9. Siguiente carta aparece
10. Al terminar todas las cartas, se emite `game_finished`

## 📊 Señales Disponibles

### Card
```gdscript
signal answered(is_correct: bool, card_data: PhishingCard)
```

### CardStack
```gdscript
signal card_answered(is_correct: bool, card_data: PhishingCard)
signal game_finished(score: int, correct: int, incorrect: int)
```

## 🔧 API Principal

### CardStack
```gdscript
# Cargar juego
card_stack.reset_game()

# Responder carta actual
card_stack.answer_phishing()      # Es phishing
card_stack.answer_legitimate()    # Es legítimo

# Obtener estadísticas
var score = card_stack.current_score
var correct = card_stack.correct_answers
var incorrect = card_stack.incorrect_answers
```

### Card
```gdscript
# Configurar carta
card.setup_from_data(phishing_card_resource)

# Verificar respuesta
var correct = card.check_answer(true)  # true = phishing

# Obtener datos
var data = card.get_card_data()
var is_phish = card.is_phishing()
```

### CardDatabase
```gdscript
# Obtener cartas
var random = database.get_random_card()
var by_difficulty = database.get_cards_by_difficulty(2)
var balanced = database.get_balanced_cards(10)
```

## 🎨 Personalización

### Colores por Dificultad
```gdscript
# En PhishingCard
match difficulty:
	1: card_color = Color.GREEN    # Fácil
	2: card_color = Color.YELLOW   # Normal
	3: card_color = Color.ORANGE   # Difícil
	4: card_color = Color.RED      # Experto
```

### Sistema de Puntos
```gdscript
# En PhishingCard
points_correct: 100   # Puntos por acierto
points_incorrect: -50 # Penalización por error
```

### Categorías
```gdscript
# En PhishingCard
category: "banking"  # banking, social_media, work, shopping, etc.

# Filtrar por categoría
var bank_cards = database.get_cards_by_category("banking")
```

## 🐛 Debugging

Para probar el sistema:
```gdscript
func _ready():
	# Imprimir info de cartas cargadas
	print("Cartas en base de datos: ", card_database.cards.size())
	
	# Ver primera carta
	var first = card_database.cards[0]
	print("Primera carta: ", first.card_title)
	print("Es phishing: ", first.is_phishing)
```

## 📝 Ejemplo de Carta Completa

```gdscript
# archivo: carta_banco_phishing.tres (crear en editor)
card_title = "Alerta de Seguridad"
card_color = Color(1, 0.3, 0.3)  # Rojo
sender_name = "Banco Seguro"
sender_email = "seguridad@banc0segur0.com"  # ← dominios falsos
subject = "URGENTE: Verifica tu cuenta"
email_body = """
Estimado cliente,

Hemos detectado actividad inusual en tu cuenta.
Por tu seguridad, debes verificar tu identidad INMEDIATAMENTE.

Haz clic aquí: [Verificar Ahora]

Si no lo haces en 24 horas, tu cuenta será SUSPENDIDA.

Departamento de Seguridad
"""

is_phishing = true
difficulty = 2
points_correct = 100
points_incorrect = -50

phishing_indicators = [
	"Dominio falso: usa '0' en lugar de 'o'",
	"Urgencia artificial con amenaza",
	"Solicita acción inmediata",
	"Link sospechoso sin HTTPS visible"
]

explanation = """
¡PHISHING! Este email usa tácticas clásicas:
- Dominio falso (banc0segur0 con ceros)
- Crea urgencia artificial
- Amenaza con suspensión
- Los bancos NUNCA piden verificar por email
"""
```

## 🚀 Próximos Pasos

1. Crear 10-20 cartas variadas (50% phishing, 50% legítimos)
2. Diseñar la UI para mostrar el email completo
3. Agregar animaciones de feedback
4. Implementar panel de resultados finales
5. Guardar estadísticas del jugador
6. Agregar tutorial inicial
7. Sistema de niveles/progresión

¡Listo para empezar a crear cartas! 🎉

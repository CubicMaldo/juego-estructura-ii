# Ejemplo de PhishingCard Resource

Para crear cartas en el editor de Godot:

## 1. Crear una nueva PhishingCard:
- Click derecho en FileSystem → New Resource
- Buscar "PhishingCard"
- Guardar en `res://resources/cards/examples/`

## 2. Llenar los datos:

### Ejemplo 1: Email de Phishing (Banco)
```
card_title: "Verificación Urgente"
card_color: #FF5555 (rojo)
sender_name: "Banco Nacional"
sender_email: "no-reply@banc0nacional.com"  # ← 0 en lugar de o
subject: "URGENTE: Verifica tu cuenta en 24 horas"
email_body: |
  Estimado cliente,
  
  Hemos detectado actividad sospechosa en tu cuenta.
  Debes verificar tu identidad INMEDIATAMENTE haciendo clic aquí:
  
  [Verificar Cuenta Ahora]
  
  Si no lo haces en 24 horas, tu cuenta será BLOQUEADA.
  
  Atentamente,
  Departamento de Seguridad

is_phishing: true
difficulty: 2 (Normal)
points_correct: 100
points_incorrect: -50

phishing_indicators:
- "Dominio incorrecto: 'banc0nacional' usa 0 en lugar de o"
- "Urgencia artificial: amenaza de bloqueo en 24h"
- "Solicita acción inmediata sin verificación"
- "Errores ortográficos sutiles"

explanation: |
  Este es un intento clásico de phishing. Los bancos NUNCA
  solicitan información urgente por email ni amenazan con
  bloquear cuentas. El dominio falso usa '0' en lugar de 'o'.
```

### Ejemplo 2: Email Legítimo
```
card_title: "Newsletter Mensual"
card_color: #55FF55 (verde)
sender_name: "Equipo Marketing"
sender_email: "newsletter@empresa-oficial.com"
subject: "Novedades de Marzo 2025"
email_body: |
  ¡Hola!
  
  Te compartimos las novedades de este mes:
  - Nueva funcionalidad en la app
  - Descuentos especiales para miembros
  - Próximos eventos
  
  Puedes revisar más detalles en tu cuenta.
  
  Saludos,
  El equipo

is_phishing: false
difficulty: 1 (Fácil)
points_correct: 50
points_incorrect: -25

explanation: |
  Este es un email legítimo de newsletter. No solicita
  información personal, usa el dominio oficial, y no
  hay urgencia artificial.
```

## 3. Crear CardDatabase:
- New Resource → CardDatabase
- Arrastrar las PhishingCard creadas al array "cards"
- Guardar como `res://resources/cards/PhishingDatabase.tres`

## 4. Conectar en CardStack:
En el inspector del nodo CardStack:
- Asignar la CardDatabase creada a la propiedad "Card Database"
- Ajustar "Cards Per Game" (ej: 10)
- Activar "Use Balanced Cards" para tener 50% phishing / 50% legítimos

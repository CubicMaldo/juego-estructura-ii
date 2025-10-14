# Email Phishing Detector - Minijuego de Ciberseguridad

## 📋 Descripción

Email Phishing Detector es un minijuego educativo donde el jugador actúa como un **filtro de correo inteligente**, analizando emails entrantes y determinando si son correos legítimos o intentos de phishing antes de que lleguen a la bandeja del usuario.

## 🎯 Objetivo

Analizar cada correo electrónico completo (remitente, asunto, cuerpo, enlaces) y clasificarlo correctamente como **LEGÍTIMO** o **PHISHING**.

## 🎮 Mecánicas del Juego

### Información Mostrada

Para cada email verás:
- **Remitente**: Nombre y dirección de correo electrónico
- **Asunto**: Título del correo
- **Cuerpo del mensaje**: Contenido completo del email
- **Enlace** (si aplica): URL incluida en el mensaje

### Controles

- **✅ Email Legítimo**: Marca el correo como seguro (permite pasar)
- **🚨 PHISHING Detectado**: Marca el correo como amenaza (bloquea)
- **💡 Ver Pista**: Muestra ayuda sobre el email actual
- **➡️ Siguiente Email**: Continúa al siguiente email (solo después de responder)

### Sistema de Puntuación

- ✅ **Decisión correcta**: +100 puntos
- ✅ **Sin usar pistas**: +50 puntos bonus (total 150)
- ❌ **Decisión incorrecta**: -1 vida
- 🎯 **Vidas totales**: 3
- 📧 **Emails totales**: 20
- ⏱️ **Tiempo límite**: 10 minutos

### Dificultad Única

Este minijuego **NO tiene niveles de dificultad** - todos los 20 emails están mezclados aleatoriamente, incluyendo desde phishing obvio hasta ataques sofisticados que requieren análisis cuidadoso.

## 🎭 Tipos de Emails Incluidos

### ✅ Emails Legítimos (10 ejemplos)
1. **Confirmación de pedido Amazon** - Envío de paquete legítimo
2. **Newsletter de LinkedIn** - Resumen semanal
3. **Notificación GitHub** - Pull request nueva
4. **Alerta de seguridad Google** - Inicio de sesión desde nuevo dispositivo
5. **Recibo de Uber** - Comprobante de viaje
6. **Newsletter Medium** - Artículos recomendados
7. **Notificación Steam** - Juego en oferta
8. **Mensaje directo Slack** - Notificación de workspace
9. **Certificado Coursera** - Completaste un curso
10. **Resumen Spotify** - Wrapped anual

### 🚨 Emails de Phishing (10 ejemplos)

#### 1. **Suplantación Bancaria**
- Dominio falso con palabra agregada
- Amenaza de suspensión de cuenta
- Solicita verificación urgente

#### 2. **Fraude de Premio Falso**
- Promesa de $50,000 USD
- Solicita información bancaria
- Pide pago de "tarifa administrativa"

#### 3. **Phishing de PayPal**
- Dominio usa número "1" en lugar de letra "l"
- Transacción falsa alarmante
- Urgencia extrema (1 hora)

#### 4. **Phishing de Netflix**
- Dominio falso con guiones
- Amenaza de cancelación inmediata
- HTTP inseguro

#### 5. **Scareware de Microsoft**
- Falsa alerta de virus
- Microsoft NO envía alertas así
- URL acortada sospechosa

#### 6. **Phishing de WhatsApp**
- Solicita código de verificación (MUY PELIGROSO)
- Amenaza de suspensión
- Dominio no oficial

#### 7. **Phishing de Apple ID**
- Solicita contraseña completa
- Apple NUNCA hace esto
- Dominio falso

#### 8. **Envío Falso DHL**
- Solicita pago de aduana por correo
- Urgencia artificial
- Dominio no oficial

#### 9. **Phishing de Criptomonedas**
- Solicita clave privada (NUNCA compartir)
- Transacción falsa alarmante
- Dominio Binance falso

#### 10. **Lotería Falsa de Facebook**
- Facebook NO tiene loterías
- Solicita pago adelantado
- Pide datos bancarios

## 🚩 Señales de Alerta Comunes

### Análisis del Dominio
- ❌ Dominios con palabras extra: `banco-verificacion.com` en lugar de `banco.com`
- ❌ Dominios con números: `paypa1.com` (1 en lugar de l)
- ❌ Extensiones sospechosas: `.net`, `.xyz`, `.tk` cuando debería ser `.com`
- ❌ Subdominios extraños: `verificacion.ejemplo.com.phishing.net`

### Lenguaje del Mensaje
- ⚠️ **URGENTE**, **INMEDIATAMENTE**, **AHORA** en mayúsculas
- ⚠️ Amenazas de suspensión/cierre de cuenta
- ⚠️ Plazos muy cortos (1 hora, 24 horas)
- ⚠️ Ofertas demasiado buenas (premios, loterías)
- ⚠️ Errores gramaticales y ortográficos

### Solicitudes Sospechosas
- 🔴 Contraseñas completas
- 🔴 Códigos de verificación 2FA
- 🔴 Claves privadas de crypto
- 🔴 Información bancaria completa
- 🔴 Pagos adelantados para "reclamar premios"
- 🔴 Respuestas de seguridad

### Enlaces Peligrosos
- 🔗 URLs acortadas: `bit.ly`, `tinyurl.com`
- 🔗 HTTP en lugar de HTTPS
- 🔗 Dominios que no coinciden con el remitente
- 🔗 IPs numéricas: `http://192.168.1.1/login`

## 💡 Reglas de Oro Anti-Phishing

1. **Verifica el dominio del remitente** - Es el indicador #1
2. **Las empresas legítimas NUNCA piden contraseñas por email**
3. **Los premios reales NO requieren pago adelantado**
4. **Desconfía de la urgencia artificial** - Es táctica de presión
5. **Cuando dudes, ve directamente al sitio oficial** - No uses enlaces del email
6. **Activa autenticación de dos factores (2FA)** - Capa extra de protección

## 📁 Archivos del Proyecto

### Scripts
- `EmailResource.gd` - Clase que representa un correo electrónico
- `EmailDatabase.gd` - Base de datos de emails
- `email_phishing_detector.gd` - Lógica principal del juego

### Escenas
- `EmailPhishingDetector.tscn` - Escena principal con UI completa

### Recursos
- `email_database.tres` - 20 emails (10 legítimos, 10 phishing)
- `EmailPhishingDetectorApp.tres` - Configuración de la app

## 🎮 Características

- ✅ **20 emails variados** (10 legítimos + 10 phishing)
- ✅ **10 tipos diferentes de ataques** de phishing
- ✅ **Emails de servicios reales** (Amazon, Google, PayPal, etc.)
- ✅ **Sistema de pistas** educativo
- ✅ **Explicaciones detalladas** después de cada decisión
- ✅ **Análisis de señales de alerta** automático
- ✅ **3 vidas** para margen de error
- ✅ **Temporizador** de 10 minutos
- ✅ **Sistema de puntos** con bonus
- ✅ **Dificultad única progresiva**

## 🚀 Integración

El minijuego está integrado como **aplicación de pistas** en el escritorio del juego, accesible mediante un icono dedicado junto a Password Cracker, Network Defender y SQL Injection Defender.

## 🎓 Valor Educativo

Este minijuego enseña:
- **Identificación de phishing** en situaciones reales
- **Análisis crítico de correos** electrónicos
- **Reconocimiento de dominios** falsos
- **Detección de tácticas de ingeniería social**
- **Verificación de enlaces** antes de hacer clic
- **Protección de información sensible**
- **Conciencia de seguridad digital**

### Casos de Uso Real

Los ejemplos del juego están basados en ataques reales:
- **Phishing bancario** - Ataque más común en Latinoamérica
- **Fraudes de lotería** - Estafas clásicas por email
- **Suplantación de servicios** - PayPal, Netflix, Apple
- **Scareware** - Falsas alertas de virus
- **Phishing de crypto** - Robo de criptomonedas
- **Verificación falsa** - WhatsApp, redes sociales

## 🏆 Consejos para Jugadores

1. 📧 **Lee todo el email** - No solo el asunto
2. 🔍 **Examina el dominio cuidadosamente** - Busca caracteres extraños
3. 🔗 **Pasa el cursor sobre los enlaces** - Verifica a dónde llevan
4. ⚠️ **Desconfía de la urgencia** - Es la táctica #1 de phishing
5. 💰 **Si suena demasiado bueno...** - Probablemente es falso
6. 🔐 **Empresas legítimas usan HTTPS** - Verifica el protocolo
7. 💡 **Usa pistas cuando dudes** - Mejor aprender que fallar
8. 🧠 **Piensa como un atacante** - ¿Qué están tratando de lograr?

## 📊 Estadísticas del Juego

- **Tasa de phishing real**: ~10 emails de los 20 (50%)
- **Balance perfecto**: 50% legítimos, 50% phishing
- **Tiempo promedio por email**: 30 segundos
- **Puntuación perfecta**: 3,000 puntos (20 × 150)
- **Puntuación mínima para ganar**: Completar 20 emails con 1+ vida

¡Conviértete en un experto anti-phishing y protege a los usuarios de amenazas digitales! 📧🛡️

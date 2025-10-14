# Network Defender - Minijuego de Firewall

## Descripción
Network Defender es un minijuego educativo de ciberseguridad donde el jugador actúa como administrador de red y debe identificar y bloquear conexiones sospechosas mientras permite el tráfico legítimo.

## Objetivo
Analizar conexiones de red entrantes y tomar decisiones correctas sobre si permitirlas o bloquearlas basándose en la información proporcionada (IP, puerto, protocolo, proceso).

## Mecánicas del Juego

### Información de Conexión
Cada conexión muestra:
- **IP Address**: Dirección IP de origen
- **Puerto**: Puerto de red utilizado
- **Protocolo**: Tipo de protocolo (HTTPS, SSH, RDP, etc.)
- **Proceso**: Nombre del proceso que realiza la conexión

### Controles
- **🚫 Bloquear**: Bloquea la conexión (usa esto si parece sospechosa)
- **✅ Permitir**: Permite la conexión (usa esto si parece legítima)
- **💡 Pista**: Muestra una pista sobre la conexión actual

### Sistema de Puntuación
- ✅ **Decisión correcta**: +100 puntos
- ✅ **Sin usar pistas**: +50 puntos bonus
- ❌ **Decisión incorrecta**: -1 vida
- 🎯 **Vidas totales**: 5

### Niveles de Dificultad
El juego tiene 3 niveles de dificultad progresivos:
1. **Fácil (Niveles 1-5)**: Conexiones básicas con patrones obvios
2. **Medio (Niveles 6-9)**: Conexiones más sutiles
3. **Difícil (Niveles 10-14)**: Técnicas avanzadas de malware y ataques

## Conceptos de Ciberseguridad Enseñados

### Puertos Comunes
- **443**: HTTPS (navegación segura)
- **22**: SSH (acceso remoto seguro)
- **587**: SMTP (envío de correo)
- **3389**: RDP (escritorio remoto)
- **445**: SMB (compartición de archivos)
- **4444**: Puerto comúnmente usado por malware
- **6667**: IRC (usado por botnets para C&C)
- **8080**: Proxy/Web alternativo
- **9001**: Puerto de Tor

### Señales de Alerta
1. **Procesos sospechosos**: Programas que normalmente no hacen conexiones de red (notepad.exe, calc.exe)
2. **Nombres falsos**: Ejecutables con nombres engañosos (system32.exe cuando debería ser una carpeta)
3. **Puertos inusuales**: Puertos no estándar para servicios conocidos
4. **PowerShell + Red**: PowerShell haciendo conexiones puede indicar scripts maliciosos
5. **Tráfico interno RPC/SMB**: Puede indicar movimiento lateral de atacantes

### Conexiones Legítimas
- Navegadores (chrome.exe, firefox.exe) usando HTTPS (443)
- Clientes de correo usando SMTP/IMAP
- Aplicaciones conocidas (Spotify, Teams, Discord)
- Herramientas de desarrollo (git.exe) usando SSH

## Consejos para Jugadores
1. 📝 Analiza TODOS los campos: IP, puerto, protocolo Y proceso
2. 🔍 Usa las pistas cuando tengas dudas
3. 🧠 Aprende de los errores: cada error muestra la razón correcta
4. ⚡ Los procesos del sistema raramente necesitan acceso a internet
5. 🎯 Puerto + Proceso deben tener sentido juntos

## Archivos del Proyecto

### Scripts
- `ConnectionResource.gd`: Clase que representa una conexión de red
- `NetworkLevelDatabase.gd`: Base de datos de niveles
- `network_defender.gd`: Lógica principal del juego

### Escenas
- `NetworkDefender.tscn`: Escena principal del minijuego

### Recursos
- `network_level_database.tres`: Base de datos con 14 conexiones de ejemplo
- `NetworkDefenderApp.tres`: Configuración de la app para el escritorio

## Integración en el Juego
El minijuego está integrado como una aplicación de "pistas" en el escritorio del juego principal, accesible mediante un ícono dedicado.

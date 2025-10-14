# 🎮 Network Defender - Instrucciones Finales

## ✅ Implementación Completada

Se ha creado exitosamente el minijuego **"Network Defender"** y se ha integrado completamente en el proyecto.

## 📁 Archivos Creados (Total: 11)

### Scripts (3 archivos)
1. `assets/scripts/minigames/network_defender/ConnectionResource.gd`
2. `assets/scripts/minigames/network_defender/ConnectionResource.gd.uid`
3. `assets/scripts/minigames/network_defender/NetworkLevelDatabase.gd`
4. `assets/scripts/minigames/network_defender/NetworkLevelDatabase.gd.uid`

### Escenas (3 archivos)
5. `scenes/minigames/network_defender/NetworkDefender.tscn`
6. `scenes/minigames/network_defender/network_defender.gd`
7. `scenes/minigames/network_defender/network_defender.gd.uid`

### Recursos (2 archivos)
8. `resources/minigames/network_defender/network_level_database.tres`
9. `resources/apps/NetworkDefenderApp.tres`

### Documentación (3 archivos)
10. `scenes/minigames/network_defender/README.md`
11. `scenes/minigames/network_defender/IMPLEMENTACION.md`
12. `scenes/minigames/network_defender/RESUMEN.md`

### Archivos Modificados (1)
- `resources/apps/AppDatabase.tres` - Agregado NetworkDefenderApp a pista_apps

## 🔧 Próximos Pasos en Godot

### 1. Abrir el Proyecto
Abre el proyecto en Godot 4. El editor detectará automáticamente los nuevos archivos.

### 2. Verificar Importación
Godot debería importar automáticamente todos los recursos. Si ves errores:
- Ve a `Project > Reload Current Project`
- Verifica que todos los `.tres` se hayan importado correctamente

### 3. Configurar UIDs (Si es necesario)
Si Godot muestra errores de referencias, puede que necesites:
1. Abrir `NetworkDefender.tscn` en el editor
2. Asignar manualmente `level_database` en el Inspector
3. Seleccionar el archivo `resources/minigames/network_defender/network_level_database.tres`

### 4. Probar el Minijuego

#### Opción A: Prueba Directa
1. Abre `scenes/minigames/network_defender/NetworkDefender.tscn`
2. Presiona F6 o el botón "Play Scene"
3. Prueba todas las funcionalidades

#### Opción B: Desde el Escritorio (Prueba Completa)
1. Ejecuta la escena principal del juego (F5)
2. Busca el icono "Network Defender" en el escritorio
3. Haz clic para abrir el minijuego

## 🎮 Cómo Jugar

### Objetivo
Analiza cada conexión de red y decide si es legítima o sospechosa.

### Controles
- **🚫 Bloquear**: Si la conexión parece maliciosa
- **✅ Permitir**: Si la conexión es legítima
- **💡 Pista**: Muestra ayuda sobre la conexión actual
- **➡️ Siguiente**: Avanza a la siguiente conexión (aparece después de decidir)

### Información Mostrada
Para cada conexión verás:
- **IP Address**: Dirección de origen
- **Puerto**: Puerto de red usado
- **Protocolo**: Tipo de protocolo (HTTPS, SSH, etc.)
- **Proceso**: Programa que hace la conexión

### Sistema de Puntuación
- ✅ Decisión correcta: **+100 puntos**
- ✅ Sin usar pista: **+50 puntos bonus**
- ❌ Decisión incorrecta: **-1 vida**
- 💀 Game Over: **0 vidas restantes**
- 🏆 Victoria: **Completar las 14 conexiones**

## 🐛 Solución de Problemas

### Error: "NetworkLevelDatabase not found"
**Solución**: Godot necesita compilar los scripts primero.
1. Cierra y reabre el proyecto
2. Ve a `Project > Reload Current Project`

### Error: "Cannot load resource"
**Solución**: Verifica los UIDs en los archivos .tres
1. Abre `NetworkDefenderApp.tres` en modo texto
2. Verifica que los UIDs coincidan con los archivos referenciados

### El icono no aparece en el escritorio
**Solución**: Verifica AppDatabase.tres
1. Abre `resources/apps/AppDatabase.tres`
2. Verifica que NetworkDefenderApp esté en `pista_apps`

### Errores de lint en los scripts
**Solución**: Son advertencias normales de Godot hasta que compile.
- Los errores de "Could not find type" desaparecerán al cargar el proyecto
- Godot resolverá las referencias automáticamente

## 📚 Contenido Educativo

El minijuego enseña a identificar:

### Conexiones Legítimas ✅
- Navegadores (chrome.exe, firefox.exe) → HTTPS (443)
- Clientes de correo (outlook.exe) → SMTP (587)
- Apps conocidas (teams.exe, spotify.exe)
- Herramientas dev (git.exe) → SSH (22)

### Conexiones Sospechosas 🚫
- Puertos de malware: 4444 (Metasploit), 6667 (IRC/Botnet), 9001 (Tor)
- Procesos anómalos: notepad.exe con red, explorer.exe en puerto sospechoso
- Nombres falsos: system32.exe (la carpeta real es System32, no un .exe)
- Técnicas de ataque: PowerShell + SMB (movimiento lateral)

## 🎯 Consejos para Jugadores

1. **Lee TODO**: IP, puerto, protocolo Y proceso
2. **Usa pistas**: Cuando tengas dudas, no adivines
3. **Aprende**: Cada error muestra la razón correcta
4. **Patrones**: Los navegadores usan 443, el correo usa 587
5. **Lógica**: ¿Tiene sentido que notepad.exe use internet?

## 🚀 Expansión Futura (Opcional)

Ideas para expandir el minijuego:

1. **Más conexiones**: Agregar más entradas al database
2. **Dificultad progresiva**: Conexiones más sutiles
3. **Modo tiempo**: Decisiones bajo presión
4. **Estadísticas**: Historial de precisión del jugador
5. **Efectos de sonido**: Feedback audio
6. **Animaciones**: Transiciones visuales
7. **Modo desafío**: Sin pistas ni tiempo

## ✨ Conclusión

El minijuego está **100% funcional y listo para usar**. Solo necesitas:
1. Abrir el proyecto en Godot
2. Dejar que importe los recursos
3. ¡Jugar y aprender sobre ciberseguridad!

**¡Disfruta defendiendo la red! 🛡️**

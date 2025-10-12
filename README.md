# Juego Estructura II

Breve descripción
-----------------
Eres un explorador que avanza por un árbol de nodos. En cada nodo puedes enfrentarte a desafíos (minijuegos) para avanzar hasta la meta. El objetivo es alcanzar el nodo final, recolectar pistas y maximizar la puntuación.

Tabla de contenidos
------------------
- Juego
- Controles básicos
- Mecánicas principales
- Consejos rápidos
- Problemas y soluciones
- Soporte para jugadores
- Para desarrolladores
- Arquitectura resumida
- Archivos clave
- Configuración del proyecto
- Contribuir
- Licencia y contacto

Juego
----
Breve introducción al objetivo: avanzar por el árbol de nodos, completar minijuegos y alcanzar el nodo final con la mayor puntuación posible.

Controles básicos
-----------------
- Movimiento: flechas del teclado o botones en pantalla.
- Seleccionar / confirmar: Enter o botón A.
- Accede a los minijuegos al acercarte a un nodo con una app asociada.
- Sigue las instrucciones específicas dentro de cada minijuego.

Mecánicas principales
---------------------
- Navegación: recorres nodos en un árbol; algunos nodos quedan ocultos hasta descubrir otros.
- Pistas: visitar un nodo de tipo "pista" otorga información y puntos.
- Desafíos: al activar un desafío se inicia un minijuego. Ganar desbloquea el avance; perder permite reintentos.
- Puntuación: puntos por visitar nodos y completar retos; consulta el marcador en la interfaz.

Consejos rápidos
----------------
- Explora ramas laterales para encontrar pistas antes de intentar retos importantes.
- Si fallas un minijuego, revisa la pista asociada y reintenta; algunos retos se vuelven más manejables tras descubrir nodos.
- Observa el indicador de sesión del minijuego: si permanece activo, espera un momento antes de moverte.

Problemas comunes y soluciones
------------------------------
- Botones no responden: prueba con el teclado. Si funcionan, la UI puede no actualizar; reinicia la escena o espera tras completar un minijuego.
- Recursos no cargan: verifica que la carpeta `res://resources/apps` exista y contenga `.tres`.
- Bloqueo tras un minijuego: cierra y vuelve a abrir la escena principal.

Soporte y depuración rápida (jugador)
-------------------------------------
Al reportar errores, incluye:
- Acción realizada y nodo donde ocurrió.
- Captura de pantalla del error (si procede).
- Comportamiento esperado vs observado.

Para desarrolladores
--------------------
(Se puede ignorar si solo quieres jugar)

Arquitectura resumida
---------------------
- Orquestador: `TreeAppController` — coordina navegación, visibilidad, lanzamiento de minijuegos y puntuación.
- Comunicación desacoplada: `EventBus` (autoload) — señales globales para UI y servicios.
- Servicios:
  - `ChallengeStateMachine` — administra estados de los retos.
  - `ResourceService` — carga y cachea recursos (AppStats / AppDatabase).
  - `ScoreSystem` — manejo de puntuación y emisión de `EventBus.score_changed`.
- Debug: `assets/scripts/debug/NavigationDebugger.gd` imprime estado de juego (presiona F3 si está adjunto).

Archivos clave
--------------
- `assets/scripts/Global.gd` — entrada global que instancia `TreeAppController`.
- `assets/scripts/arboles/player_interactions/TreeAppController.gd`
- `assets/scripts/core/EventBus.gd` — añadir como Autoload.
- `assets/scripts/core/ChallengeStateMachine.gd`
- `assets/scripts/core/ResourceService.gd`
- `assets/scripts/core/ScoreSystem.gd`

Configuración del proyecto
--------------------------
- Añadir Autoload: `EventBus` → `res://assets/scripts/core/EventBus.gd`

Contribuir
----------
Mantén la separación de responsabilidades (servicios, orquestador, UI). Documenta nuevas señales en `EventBus` y añade pruebas para `ChallengeStateMachine` y `ScoreSystem`.

Licencia y contacto
-------------------
Indica la licencia del proyecto (por ejemplo, MIT). Incluye instrucciones o datos de contacto internos si procede.

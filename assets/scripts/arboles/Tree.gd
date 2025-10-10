class_name Arbol

## Pure tree generation - no game state, no visibility logic

var raiz: TreeNode = null

enum NodosJuego { INICIO = 0, DESAFIO = 1, PISTA = 2, FINAL = 3}

@export var _longitud_minima = 3
@export var _longitud_maxima = 5
@export var _numero_de_pistas = 2
@export var _cantidad_ramas = 4

var rng := RandomNumberGenerator.new()

func generar_arbol_controlado(semilla: int = -1) -> void:
	if semilla == -1:
		rng.randomize()
		print("Semilla:", rng.seed)
	else:
		rng.seed = semilla
	
	# 1. Generar el camino principal
	raiz = TreeNode.new(NodosJuego.INICIO)
	
	var actual = raiz
	var longitud = rng.randi_range(_longitud_minima, _longitud_maxima)
	
	for i in range(1, longitud):
		var nuevo = TreeNode.new(NodosJuego.DESAFIO, actual)
		if rng.randf() < 0.5:
			actual.izquierdo = nuevo
		else:
			actual.derecho = nuevo
		actual = nuevo

	# 2. Generar ramas falsas
	for i in range(_cantidad_ramas):
		_agregar_ramas(i)
	
	# 3. Colocar el nodo FINAL en la hoja más profunda
	var hoja_profunda = _obtener_hoja_mas_profunda()
	if hoja_profunda != null:
		hoja_profunda.tipo = NodosJuego.FINAL
	
	# 4. Colocar pistas
	_colocar_pistas()

func _agregar_ramas(i: int) -> void:
	var camino = _obtener_nodos_preorden_sin_hojas()
	if camino.size() <= 1:
		return

	var padre: TreeNode
	
	if i != 0:
		padre = camino[rng.randi_range(0, camino.size() - 1)]
	else:
		padre = camino[0]
	
	if padre == null or (padre.izquierdo != null and padre.derecho != null):
		return

	# Crear raíz de rama falsa
	var nuevo = TreeNode.new(NodosJuego.DESAFIO, padre)
	if padre.derecho == null:
		padre.derecho = nuevo
	elif padre.izquierdo == null:
		padre.izquierdo = nuevo
	else:
		return

	# Extender la rama
	var profundidad = rng.randi_range(1, 3)
	var actual = nuevo
	for j in range(profundidad):
		var hijo = TreeNode.new(NodosJuego.DESAFIO, actual)
		if rng.randf() < 0.5:
			actual.izquierdo = hijo
		else:
			actual.derecho = hijo
		actual = hijo

func _colocar_pistas() -> void:
	var hojas = _obtener_hojas_validas()
	if hojas.is_empty():
		return

	var max_pistas = min(_numero_de_pistas, hojas.size())
	_mezclar_array(hojas)

	for i in range(max_pistas):
		hojas[i].tipo = NodosJuego.PISTA

func _obtener_hoja_mas_profunda() -> TreeNode: 
	var result = _buscar_hoja_profunda(raiz, 0)
	return result.hoja

func _buscar_hoja_profunda(nodo: TreeNode, depth: int) -> Dictionary:
	if nodo == null:
		return {"hoja": null, "prof": -1}

	if nodo.izquierdo == null and nodo.derecho == null:
		return {"hoja": nodo, "prof": depth}

	var left = _buscar_hoja_profunda(nodo.izquierdo, depth + 1)
	var right = _buscar_hoja_profunda(nodo.derecho, depth + 1)

	if left.prof > right.prof:
		return left
	else:
		return right

func _obtener_nodos_preorden_sin_hojas() -> Array:
	var lista: Array = []
	_recorrer_preorden_sin_hojas(raiz, lista)
	return lista

func _recorrer_preorden_sin_hojas(nodo: TreeNode, lista: Array) -> void:
	if nodo == null:
		return
	
	if not (nodo.izquierdo == null and nodo.derecho == null):
		lista.append(nodo)
	
	_recorrer_preorden_sin_hojas(nodo.izquierdo, lista)
	_recorrer_preorden_sin_hojas(nodo.derecho, lista)

func _obtener_hojas_validas() -> Array:
	var hojas = []
	_colectar_hojas(raiz, hojas)
	var hojas_validas = []
	for hoja in hojas:
		if hoja != raiz and hoja.tipo == NodosJuego.DESAFIO:
			hojas_validas.append(hoja)
	return hojas_validas

func _colectar_hojas(nodo: TreeNode, hojas: Array) -> void:
	if nodo == null:
		return
	if nodo.izquierdo == null and nodo.derecho == null:
		hojas.append(nodo)
	else:
		_colectar_hojas(nodo.izquierdo, hojas)
		_colectar_hojas(nodo.derecho, hojas)

func _mezclar_array(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp

# Debug utilities - no coupling to game state
func imprimir_arbol(nodo: TreeNode = raiz, prefijo: String = "", es_izq: bool = true) -> void:
	if nodo == null:
		return
	
	imprimir_arbol(nodo.derecho, prefijo + ("│   " if es_izq else "    "), false)
	print(prefijo + ("└── " if es_izq else "┌── ") + _tipo_to_string(nodo.tipo))
	imprimir_arbol(nodo.izquierdo, prefijo + ("    " if es_izq else "│   "), true)

func _tipo_to_string(tipo: int) -> String:
	match tipo:
		NodosJuego.INICIO: return "INICIO"
		NodosJuego.DESAFIO: return "DESAFIO"
		NodosJuego.PISTA: return "PISTA"
		NodosJuego.FINAL: return "FINAL"
		_: return str(tipo)

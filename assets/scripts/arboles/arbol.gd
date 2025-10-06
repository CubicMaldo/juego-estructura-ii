class_name Arbol
var raiz: Nodo = null

# Parámetros configurables
var _longitud_minima = 4
var _longitud_maxima = 7
var _cantidad_ramas = 6

# Generador global con semilla opcional
var rng := RandomNumberGenerator.new()

func generar_arbol_controlado(semilla: int = -1) -> void:
	# Si no se pasa semilla, se randomiza
	
	if semilla == -1:
		rng.randomize()
		print("Semilla:", rng.seed)
	else:
		rng.seed = semilla

	# 1. Generar el camino principal con longitud aleatoria
	raiz = Nodo.new(1,true)
	
	var actual = raiz
	var longitud = rng.randi_range(_longitud_minima, _longitud_maxima)

	for i in range(1, longitud):
		var nuevo = Nodo.new(0)
		if rng.randf() < 0.5:
			actual.izquierdo = nuevo
		else:
			actual.derecho = nuevo
		actual = nuevo

	# 2. Generar ramas falsas
	for i in range(_cantidad_ramas):
		_agregar_ramas(i)
	
	raiz.hijosVistos()
	# 3. Colocar el nodo 3 en la hoja más profunda
	var hoja_profunda = _obtener_hoja_mas_profunda()
	if hoja_profunda != null:
		hoja_profunda.tipo = 3
	# 4. Colocar pistas en otras ramas falsas
	_colocar_pistas()


func _agregar_ramas(i: int) -> void:
	var camino = obtener_nodos_preorden()
	if camino.size() <= 1:
		return

	var padre: Nodo

	# Elegir candidato inicial
	if i != 0:
		padre = camino[rng.randi_range(0, camino.size() - 1)]
	else:
		padre = camino[0]

	# 🔹 Si el padre es una hoja, buscar otro que no lo sea
	var intentos = 0
	while _es_hoja(padre) and intentos < 10:
		padre = camino[rng.randi_range(0, camino.size() - 1)]
		intentos += 1

	if padre == null or (padre.izquierdo != null and padre.derecho != null):
		return

	# Crear nodo raíz de la rama falsa
	var nuevo = Nodo.new(0)
	if padre.derecho == null:
		padre.derecho = nuevo
	elif padre.izquierdo == null:
		padre.izquierdo = nuevo
	else:
		return

	# 🔹 Extender la rama con profundidad aleatoria
	var profundidad = rng.randi_range(1, 3)
	var actual = nuevo
	for j in range(profundidad):
		var hijo = Nodo.new(0)
		if rng.randf() < 0.5:
			actual.izquierdo = hijo
		else:
			actual.derecho = hijo
		actual = hijo


func _es_hoja(nodo: Nodo) -> bool:
	if nodo == null:
		return false
	return nodo.izquierdo == null and nodo.derecho == null


func _colocar_pistas() -> void:
	var hojas = _obtener_hojas_validas()
	if hojas.is_empty():
		return

	var max_pistas = min(2, hojas.size())
	_mezclar_array(hojas)

	for i in range(max_pistas):
		hojas[i].tipo = 2

func _obtener_hoja_mas_profunda() -> Nodo: 
	var result = _buscar_hoja_profunda(raiz, 0)
	return result.hoja


func _buscar_hoja_profunda(nodo: Nodo, depth: int) -> Dictionary:
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

# Utilidades previas
func obtener_nodos_preorden() -> Array:
	var lista: Array = []
	_recorrer_preorden(raiz, lista)
	return lista


func _recorrer_preorden(nodo: Nodo, lista: Array) -> void:
	if nodo == null:
		return
	
	lista.append(nodo)
	_recorrer_preorden(nodo.izquierdo, lista)
	_recorrer_preorden(nodo.derecho, lista)


func _obtener_hojas_validas() -> Array:
	var hojas = []
	_colectar_hojas(raiz, hojas)
	var hojas_validas = []
	for hoja in hojas:
		if hoja != raiz and hoja.tipo == 0:
			hojas_validas.append(hoja)
	return hojas_validas

func _colectar_hojas(nodo: Nodo, hojas: Array) -> void:
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

func imprimir_arbol(nodo: Nodo = raiz, prefijo: String = "", es_izq: bool = true):
	if nodo == null:
		return
	
	# Primero imprime el derecho
	imprimir_arbol(nodo.derecho, prefijo + ("│   " if es_izq else "    "), false)
	
	# Imprime actual
	print(prefijo + ("└── " if es_izq else "┌── ") + str(nodo.tipo))
	
	# Luego imprime el izquierdo
	imprimir_arbol(nodo.izquierdo, prefijo + ("    " if es_izq else "│   "), true)
	
func imprimir_arbol_vistos(nodo: Nodo = raiz, prefijo: String = "", es_izq: bool = true):
	if nodo == null:
		return
	
	# 🔹 Solo imprime si el nodo ha sido visto
	if nodo.visto:
		# Primero imprime el derecho
		imprimir_arbol_vistos(nodo.derecho, prefijo + ("│   " if es_izq else "    "), false)
		
		# Imprime el nodo actual
		print(prefijo + ("└── " if es_izq else "┌── ") + str(nodo.tipo))
		
		# Luego imprime el izquierdo
		imprimir_arbol_vistos(nodo.izquierdo, prefijo + ("    " if es_izq else "│   "), true)

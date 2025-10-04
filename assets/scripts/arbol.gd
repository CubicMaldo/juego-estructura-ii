class_name Arbol
var raiz: Nodo = null


func generar_arbol_aleatorio(cantidad: int) -> void:
	if cantidad <= 0:
		return

	raiz = Nodo.new(1)
	
	# Early return for single node tree
	if cantidad == 1:
		return

	var nodos = [raiz]
	var contador = 2
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Pre-filter nodes that can accept children for better performance
	while contador <= cantidad:
		var nodos_validos = _obtener_nodos_con_espacio(nodos)
		
		if nodos_validos.is_empty():
			# Safety check - should not happen with proper tree growth
			push_warning("No se pueden agregar más nodos. Ábol incompleto.")
			break
		
		var padre = nodos_validos[rng.randi_range(0, nodos_validos.size() - 1)]
		var nuevo = Nodo.new(0)
		
		# Assign to available child position
		if padre.izquierdo == null:
			padre.izquierdo = nuevo
		else:
			padre.derecho = nuevo
		
		nodos.append(nuevo)
		contador += 1

	# Mark leaves with specific values in one optimized pass
	_marcar_hojas_especiales([3, 2, 2])


func _obtener_nodos_con_espacio(nodos: Array) -> Array:
	var nodos_validos = []
	for nodo in nodos:
		if nodo.izquierdo == null or nodo.derecho == null:
			nodos_validos.append(nodo)
	return nodos_validos


func _marcar_hojas_especiales(valores: Array) -> void:
	# Collect all valid leaf nodes once
	var hojas_validas = _obtener_hojas_validas()
	
	if hojas_validas.size() < valores.size():
		push_warning("No hay suficientes hojas para marcar todos los valores. Hojas: %d, Valores: %d" % [hojas_validas.size(), valores.size()])
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Shuffle and assign values efficiently
	_mezclar_array(hojas_validas, rng)
	
	for i in range(min(valores.size(), hojas_validas.size())):
		hojas_validas[i].dato = valores[i]


func _obtener_hojas_validas() -> Array:
	var hojas = []
	_colectar_hojas(raiz, hojas)
	
	var hojas_validas = []
	for hoja in hojas:
		if hoja != raiz and hoja.dato == 0:
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


func _mezclar_array(array: Array, rng: RandomNumberGenerator) -> void:
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
	print(prefijo + ("└── " if es_izq else "┌── ") + str(nodo.dato))
	
	# Luego imprime el izquierdo
	imprimir_arbol(nodo.izquierdo, prefijo + ("    " if es_izq else "│   "), true)


# Additional utility methods
func obtener_estadisticas() -> Dictionary:
	var stats = {
		"total_nodos": 0,
		"hojas": 0,
		"nodos_con_3": 0,
		"nodos_con_2": 0,
		"nodos_con_1": 0,
		"nodos_con_0": 0
	}
	_contar_estadisticas(raiz, stats)
	return stats


func _contar_estadisticas(nodo: Nodo, stats: Dictionary) -> void:
	if nodo == null:
		return
	
	stats.total_nodos += 1
	
	if nodo.izquierdo == null and nodo.derecho == null:
		stats.hojas += 1
	
	match nodo.dato:
		3: stats.nodos_con_3 += 1
		2: stats.nodos_con_2 += 1
		1: stats.nodos_con_1 += 1
		0: stats.nodos_con_0 += 1
	
	_contar_estadisticas(nodo.izquierdo, stats)
	_contar_estadisticas(nodo.derecho, stats)

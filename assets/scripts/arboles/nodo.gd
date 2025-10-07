class_name Nodo

var dato
var tipo : int

var visto : bool
var visitado : bool

var padre : Nodo
var izquierdo : Nodo
var derecho : Nodo

func _init(_valor : int , _visto : bool = false, _padre : Nodo = null):
	self.tipo = _valor
	self.visto = _visto
	self.padre = _padre

func hijosVistos():
	if self.izquierdo != null:
		self.izquierdo.visto = true
	if self.derecho != null:
		self.derecho.visto = true

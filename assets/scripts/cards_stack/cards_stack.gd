extends Control

# Exports
@export var offset: float = 30.0
@export var scale_between_cards: float = 0.05
@export var anim_duration: float = 0.45
@export var anim_duration_offset: float = 0.15

# State
var first_card : Card
var first_card_pos: Vector2
var first_card_scale: Vector2
var last_card : Card

# Tweens
var tween: Tween
var tween_last_card: Tween
var tween_bg: Tween

# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	_setup_card_signals()
	_cache_card_properties()  # <-- RENOMBRADO
	_cards_setup()
	await _initial_setup_delay()

func _setup_card_signals() -> void:
	for c in %Cards.get_children():
		c.put_back.connect(on_card_put_back.bind(c))
		c.destroyed.connect(on_card_destroyed.bind(c))

func _cache_card_properties() -> void:  # <-- RENOMBRADO Y EXPANDIDO
	first_card = _get_card_at_index(_get_card_count() - 1)
	first_card_pos = first_card.position
	first_card_scale = first_card.scale
	last_card = _get_card_at_index(0)  # <-- CACHEAR ÚLTIMA CARTA

func _cards_setup():
	pass

func _get_card_count() -> int:
	return %Cards.get_child_count()

func _get_card_at_index(index: int) -> Card:  # <-- CAMBIAR TIPO DE RETORNO
	return %Cards.get_child(index)

func _initial_setup_delay() -> void:
	await get_tree().create_timer(0.5).timeout
	
	tween_bg_color(first_card.color)
	
	update_cards()
	
	await tween.finished
	_save_original_positions()

func _save_original_positions() -> void:
	for c in %Cards.get_children():
		c.original_position = c.global_position

# ============================================
# ANIMATION - BACKGROUND
# ============================================

func tween_bg_color(new_color: Color) -> void:
	_kill_tween_if_running(tween_bg)
	tween_bg = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_bg.tween_property($BG, "color", new_color, anim_duration * 2.0)

# ============================================
# ANIMATION - CARDS
# ============================================

func update_cards(_thrown: bool = false, animated: bool = true) -> void:
	_kill_tween_if_running(tween)
	tween = _create_parallel_tween()
	
	var child_count: int = _get_card_count()
	
	# Actualizar referencias de cartas
	first_card = _get_card_at_index(child_count - 1)
	last_card = _get_card_at_index(0)
	
	for i in range(child_count - 1, -1, -1):
		var card: Card = _get_card_at_index(i)
		_update_single_card(card, i, child_count, card == first_card, animated)

func _update_single_card(card: Card, index: int, total_cards: int, is_top: bool, animated: bool) -> void:
	card.disabled = not is_top
	
	var multiplier: float = total_cards - 1 - index
	var card_offset: Vector2 = _calculate_card_offset(multiplier)
	var card_scale: Vector2 = _calculate_card_scale(multiplier)
	
	if animated:
		_animate_card_transform(card, card_offset, card_scale, multiplier)
	else:
		_set_card_transform_immediate(card, card_offset, card_scale)

func _calculate_card_offset(multiplier: float) -> Vector2:
	return Vector2(0, offset * multiplier)

func _calculate_card_scale(multiplier: float) -> Vector2:
	return Vector2(scale_between_cards, scale_between_cards) * multiplier

func _animate_card_transform(card: Card, offset_vec: Vector2, scale_vec: Vector2, multiplier: float) -> void:
	var duration: float = anim_duration + (anim_duration_offset * multiplier)
	tween.tween_property(card, "position", first_card_pos - offset_vec, duration)
	tween.tween_property(card, "scale", first_card_scale - scale_vec, duration)

func _set_card_transform_immediate(card: Card, offset_vec: Vector2, scale_vec: Vector2) -> void:
	card.position = first_card_pos - offset_vec
	card.scale = first_card_scale - scale_vec

# ============================================
# CARD INTERACTIONS
# ============================================

func on_card_put_back(which: Card) -> void:
	print("Put back: ", which.get_name())
	
	_update_bg_for_previous_card()
	_animate_card_return(which)
	_schedule_card_reorder(which)

func _update_bg_for_previous_card() -> void:
	var previous_card: Card = _get_card_at_index(_get_card_count() - 2)
	tween_bg_color(previous_card.color)

func _animate_card_return(card: Card) -> void:
	_kill_tween_if_running(tween_last_card)
	tween_last_card = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var target_pos: Vector2 = $TopPoint.global_position - (card.size / 2.0)
	var target_scale: Vector2 = Vector2(0.8, 0.8)
	
	tween_last_card.tween_property(card, "global_position", target_pos, anim_duration / 2.0)
	tween_last_card.parallel().tween_property(card, "scale", target_scale, anim_duration / 2.0)

func _schedule_card_reorder(card: Card) -> void:
	tween_last_card.tween_callback(%Cards.move_child.bind(card, 0))
	tween_last_card.tween_callback(update_cards.bind(true))

func on_card_destroyed(which: Card) -> void:
	print("Destroyed: ", which.name)
# ============================================
# VISUAL SETTINGS
# ============================================

func set_cards_3D(state: bool) -> void:
	for c in %Cards.get_children():
		c.is_3D = state

func _on_check_button_toggled(toggled_on: bool) -> void:
	set_cards_3D(toggled_on)

# ============================================
# HELPERS
# ============================================

func _kill_tween_if_running(tween_ref: Tween) -> void:
	if tween_ref and tween_ref.is_running():
		tween_ref.kill()

func _create_parallel_tween() -> Tween:
	return create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)

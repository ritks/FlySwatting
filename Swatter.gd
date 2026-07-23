extends Area2D

signal flies_swatted(count: int)

enum State { IDLE, COUNTDOWN }

const BAR_SIZE := Vector2(50.0, 8.0)
const BAR_MARGIN := 20.0
const TIMER_LABEL_SIZE := Vector2(90.0, 30.0)

@onready var timer_label: Label = $TimerLabel

var state: State = State.IDLE
var active_head: SwatterHead
var time_left: float = 0.0
var bar_offset: Vector2
var swat_center_offset: Vector2

func _ready() -> void:
	for child in get_children():
		if child is SwatterHead:
			active_head = child
			break
	_refresh_active_head_metrics()

func _refresh_active_head_metrics() -> void:
	swat_center_offset = active_head.collision_shape.position

	var sprite_half_height := 0.0
	if active_head.sprite.texture:
		sprite_half_height = active_head.sprite.texture.get_height() * active_head.sprite.scale.y / 2.0
	bar_offset = Vector2(-BAR_SIZE.x / 2.0, -sprite_half_height - BAR_MARGIN)
	timer_label.position = bar_offset + Vector2(
		BAR_SIZE.x / 2.0 - TIMER_LABEL_SIZE.x / 2.0,
		-TIMER_LABEL_SIZE.y - 6.0
	)

func _process(delta: float) -> void:
	var target := get_global_mouse_position() - swat_center_offset
	var weight := 1.0 - exp(-active_head.kit.follow_speed * delta)
	global_position = global_position.lerp(target, weight)

	if state == State.COUNTDOWN:
		time_left = max(time_left - delta, 0.0)
		timer_label.text = "%.2f" % time_left
		if time_left <= 0.0:
			_do_swat()

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if state != State.IDLE:
			return

		var pickup := _pickup_at_mouse()
		if pickup:
			_swap_head(pickup)
			return

		state = State.COUNTDOWN
		time_left = active_head.kit.swat_time
		timer_label.text = "%.2f" % time_left
		timer_label.visible = true

func _pickup_at_mouse() -> SwatterHead:
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	for result in get_world_2d().direct_space_state.intersect_point(params, 32):
		var collider: Object = result["collider"]
		if collider is SwatterHead and collider.is_in_group("swatter_pickup"):
			return collider
	return null

func _swap_head(new_head: SwatterHead) -> void:
	var slot := new_head.get_parent()
	var old_head := active_head

	slot.remove_child(new_head)
	add_child(new_head)
	new_head.position = Vector2.ZERO
	new_head.remove_from_group("swatter_pickup")
	new_head.add_to_group("swatter")

	remove_child(old_head)
	slot.add_child(old_head)
	old_head.position = Vector2.ZERO
	old_head.remove_from_group("swatter")
	old_head.add_to_group("swatter_pickup")

	active_head = new_head
	_refresh_active_head_metrics()

func _do_swat() -> void:
	state = State.IDLE
	timer_label.visible = false

	active_head.modulate = Color(0.3, 1.0, 0.3)
	var tw := create_tween()
	tw.tween_property(active_head, "modulate", Color(1, 1, 1), 0.2)

	var count := 0
	for area in active_head.get_overlapping_areas():
		if area.is_in_group("fly"):
			area.queue_free()
			count += 1
	if count > 0:
		flies_swatted.emit(count)

func _draw() -> void:
	if state == State.IDLE:
		return
	var pct := time_left / active_head.kit.swat_time
	draw_rect(Rect2(bar_offset, BAR_SIZE), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(bar_offset, Vector2(BAR_SIZE.x * pct, BAR_SIZE.y)), Color(1, 0.3, 0.2, 1))
	draw_rect(Rect2(bar_offset, BAR_SIZE), Color(1, 1, 1, 1), false, 1.0)

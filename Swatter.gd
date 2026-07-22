extends Area2D

signal flies_swatted(count: int)

enum State { IDLE, CHARGING, WINDUP }

const MAX_CHARGE := 4.0
const MIN_CHARGE := 1.0
const BAR_SIZE := Vector2(50.0, 8.0)
const BAR_OFFSET := Vector2(-BAR_SIZE.x / 2.0, -110.0)

var state: State = State.IDLE
var charge_amount: float = 0.0

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

	match state:
		State.CHARGING:
			charge_amount = min(charge_amount + delta, MAX_CHARGE)
		State.WINDUP:
			charge_amount = max(charge_amount - delta, 0.0)
			if charge_amount <= 0.0:
				_do_swat()

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and state == State.IDLE:
			state = State.CHARGING
			charge_amount = 0.0
		elif not event.pressed and state == State.CHARGING:
			if charge_amount >= MIN_CHARGE:
				state = State.WINDUP
			else:
				state = State.IDLE
				charge_amount = 0.0

func _do_swat() -> void:
	state = State.IDLE

	modulate = Color(0.3, 1.0, 0.3)
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

	var count := 0
	for area in get_overlapping_areas():
		if area.is_in_group("fly"):
			area.queue_free()
			count += 1
	if count > 0:
		flies_swatted.emit(count)

func _draw() -> void:
	if state == State.IDLE:
		return
	var pct := charge_amount / MAX_CHARGE
	draw_rect(Rect2(BAR_OFFSET, BAR_SIZE), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(BAR_OFFSET, Vector2(BAR_SIZE.x * pct, BAR_SIZE.y)), Color(0, 1, 0, 1))
	draw_rect(Rect2(BAR_OFFSET, BAR_SIZE), Color(1, 1, 1, 1), false, 1.0)

extends Area2D

signal flies_swatted(count: int)

enum State { IDLE, COUNTDOWN }

const SWAT_TIME := 3.0
const BAR_SIZE := Vector2(50.0, 8.0)
const BAR_MARGIN := 20.0
const TIMER_LABEL_SIZE := Vector2(90.0, 30.0)
const FOLLOW_SPEED := 10.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_label: Label = $TimerLabel

var state: State = State.IDLE
var time_left: float = 0.0
var bar_offset: Vector2

func _ready() -> void:
	var sprite_half_height := 0.0
	if sprite.texture:
		sprite_half_height = sprite.texture.get_height() * sprite.scale.y / 2.0
	bar_offset = Vector2(-BAR_SIZE.x / 2.0, -sprite_half_height - BAR_MARGIN)
	timer_label.position = bar_offset + Vector2(
		BAR_SIZE.x / 2.0 - TIMER_LABEL_SIZE.x / 2.0,
		-TIMER_LABEL_SIZE.y - 6.0
	)

func _process(delta: float) -> void:
	var weight := 1.0 - exp(-FOLLOW_SPEED * delta)
	global_position = global_position.lerp(get_global_mouse_position(), weight)

	if state == State.COUNTDOWN:
		time_left = max(time_left - delta, 0.0)
		timer_label.text = "%.2f" % time_left
		if time_left <= 0.0:
			_do_swat()

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and state == State.IDLE:
			state = State.COUNTDOWN
			time_left = SWAT_TIME
			timer_label.text = "%.2f" % time_left
			timer_label.visible = true

func _do_swat() -> void:
	state = State.IDLE
	timer_label.visible = false

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
	var pct := time_left / SWAT_TIME
	draw_rect(Rect2(bar_offset, BAR_SIZE), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(bar_offset, Vector2(BAR_SIZE.x * pct, BAR_SIZE.y)), Color(1, 0.3, 0.2, 1))
	draw_rect(Rect2(bar_offset, BAR_SIZE), Color(1, 1, 1, 1), false, 1.0)

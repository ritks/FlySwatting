extends Area2D

const MIN_SPEED := 90.0
const MAX_SPEED := 220.0
const JITTER_MIN := 0.2
const JITTER_MAX := 0.5
const EDGE_MARGIN := 10.0
const LEVEL_MIN_X := -1920.0
const LEVEL_MAX_X := 3840.0
const HOVER_SPEED_MULT := 2.5

var velocity := Vector2.ZERO
var jitter_timer := 0.0

func _ready() -> void:
	add_to_group("fly")
	_pick_new_velocity()

func _process(delta: float) -> void:
	jitter_timer -= delta
	if jitter_timer <= 0.0:
		_pick_new_velocity()

	var speed_mult := 1.0
	for area in get_overlapping_areas():
		if area.is_in_group("swatter"):
			speed_mult = HOVER_SPEED_MULT
			break

	position += velocity * speed_mult * delta

	var vp := get_viewport_rect().size
	position.x = clamp(position.x, LEVEL_MIN_X + EDGE_MARGIN, LEVEL_MAX_X - EDGE_MARGIN)
	position.y = clamp(position.y, EDGE_MARGIN, vp.y - EDGE_MARGIN)

func _pick_new_velocity() -> void:
	var angle := randf() * TAU
	var speed := randf_range(MIN_SPEED, MAX_SPEED)
	velocity = Vector2.RIGHT.rotated(angle) * speed
	jitter_timer = randf_range(JITTER_MIN, JITTER_MAX)

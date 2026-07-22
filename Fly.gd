extends Area2D

const MIN_SPEED := 40.0
const MAX_SPEED := 100.0
const JITTER_MIN := 0.3
const JITTER_MAX := 0.8
const EDGE_MARGIN := 10.0

var velocity := Vector2.ZERO
var jitter_timer := 0.0

func _ready() -> void:
	add_to_group("fly")
	_pick_new_velocity()

func _process(delta: float) -> void:
	jitter_timer -= delta
	if jitter_timer <= 0.0:
		_pick_new_velocity()

	position += velocity * delta

	var vp := get_viewport_rect().size
	position.x = clamp(position.x, EDGE_MARGIN, vp.x - EDGE_MARGIN)
	position.y = clamp(position.y, EDGE_MARGIN, vp.y - EDGE_MARGIN)

func _pick_new_velocity() -> void:
	var angle := randf() * TAU
	var speed := randf_range(MIN_SPEED, MAX_SPEED)
	velocity = Vector2.RIGHT.rotated(angle) * speed
	jitter_timer = randf_range(JITTER_MIN, JITTER_MAX)

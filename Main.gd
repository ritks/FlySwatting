extends Node2D

const FLY_SCENE: PackedScene = preload("res://Fly.tscn")
const MAX_FLIES := 8
const SPAWN_MARGIN := 20.0
const LEVEL_MIN_X := -1920.0
const LEVEL_MAX_X := 3840.0
const EDGE_PAN_ZONE := 0.1
const PAN_SPEED := 800.0

var score := 0

@onready var swatter: Area2D = $Swatter
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var spawn_timer: Timer = $SpawnTimer
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	swatter.flies_swatted.connect(_on_flies_swatted)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_update_score_label()

func _process(delta: float) -> void:
	var vp := get_viewport_rect().size
	var mouse_x := get_viewport().get_mouse_position().x
	var pan_dir := 0.0
	if mouse_x < vp.x * EDGE_PAN_ZONE:
		pan_dir = -1.0
	elif mouse_x > vp.x * (1.0 - EDGE_PAN_ZONE):
		pan_dir = 1.0

	if pan_dir != 0.0:
		camera.position.x = clamp(
			camera.position.x + pan_dir * PAN_SPEED * delta,
			LEVEL_MIN_X + vp.x / 2.0,
			LEVEL_MAX_X - vp.x / 2.0
		)

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("fly").size() >= MAX_FLIES:
		return
	var fly := FLY_SCENE.instantiate()
	add_child(fly)
	var vp := get_viewport_rect().size
	var view_min := camera.position - vp / 2.0
	var view_max := camera.position + vp / 2.0
	fly.position = Vector2(
		randf_range(view_min.x + SPAWN_MARGIN, view_max.x - SPAWN_MARGIN),
		randf_range(view_min.y + SPAWN_MARGIN, view_max.y - SPAWN_MARGIN)
	)

func _on_flies_swatted(count: int) -> void:
	score += count
	_update_score_label()

func _update_score_label() -> void:
	score_label.text = "Score: %d" % score

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		var window := get_window()
		if window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN

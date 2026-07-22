extends Node2D

const FLY_SCENE: PackedScene = preload("res://Fly.tscn")
const MAX_FLIES := 8
const SPAWN_MARGIN := 20.0

var score := 0

@onready var swatter: Area2D = $Swatter
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	swatter.flies_swatted.connect(_on_flies_swatted)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_update_score_label()

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("fly").size() >= MAX_FLIES:
		return
	var fly := FLY_SCENE.instantiate()
	add_child(fly)
	var vp := get_viewport_rect().size
	fly.position = Vector2(
		randf_range(SPAWN_MARGIN, vp.x - SPAWN_MARGIN),
		randf_range(SPAWN_MARGIN, vp.y - SPAWN_MARGIN)
	)

func _on_flies_swatted(count: int) -> void:
	score += count
	_update_score_label()

func _update_score_label() -> void:
	score_label.text = "Score: %d" % score

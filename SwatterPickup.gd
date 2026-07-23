extends Area2D

@export var kit: SwatterKit

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("swatter_pickup")
	sprite.texture = kit.texture
	sprite.scale = kit.sprite_scale

	var shape := collision_shape.shape as RectangleShape2D
	shape.size = kit.collision_size
	collision_shape.position = kit.collision_offset

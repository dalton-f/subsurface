extends Node3D

@onready var sprinkler: MeshInstance3D = $SpaceFarmLargeSprinkler/Sprinkler

var rotation_speed: float

func _ready() -> void:
	rotation_speed = 10
	
	var tween := create_tween()
	
	tween.set_loops()
	
	tween.tween_property(
		sprinkler,
		"rotation:y",
		TAU,
		rotation_speed
	).as_relative()

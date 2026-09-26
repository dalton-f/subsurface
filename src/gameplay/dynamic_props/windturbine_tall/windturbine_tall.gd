extends Node3D

@onready var windturbine_tall_fan: MeshInstance3D = $WindturbineTall/WindturbineTallFan

var rotation_speed: float

func _ready() -> void:
	rotation_speed = 1
	
	var tween := create_tween()
	
	tween.set_loops()
	
	tween.tween_property(
		windturbine_tall_fan,
		"rotation:z",
		TAU,
		rotation_speed
	).as_relative()
